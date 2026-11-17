// Component 里访问外层 root / theme，显式声明后静态分析能确认来源
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtTest
import QtShadcn

// ShadcnAccordion：组合结构、单选/多选/collapsible 语义、分隔线、
// 高度动画是否真在逐帧推进、键盘可达、收起态内容不可交互。
//
// ── 等待手法（版本兼容，两次踩坑后定型）──────────────────────────
// tryVerify 的签名在 6.8 是 (condition, timeout, message)、6.11 多了一个
// retryInterval，参数个数一变就报 "message argument must be a string" /
// "timeout argument must be a number"，而且 6.11 上返回值是 undefined。
// 这里一律用自带轮询 waitUntil()：靠 wait() 推进事件循环（QML 动画由事件循环
// 驱动，忙等一帧都不走），条件成立即返回，再用 verify 报可读的失败信息。
// 动画断言同理：不断言「第 N 帧是多少」，只在动画窗口内逐帧找「严格介于起止值
// 之间」的中间值（照 tst_ShadcnFadeZoomTransition 的定版），对启动延迟免疫，
// 同时保留抓「动画被删掉」的能力。
Item {
    id: root
    width: 600
    height: 900

    QtShadcnTheme {
        id: theme
    }

    // 三行手风琴（默认语义：单选 + collapsible=false）
    Component {
        id: basicComp
        ShadcnAccordion {
            id: acc

            objectName: "acc"
            width: 400

            ShadcnAccordionItem {
                objectName: "itemA"
                value: "a"
                ShadcnAccordionTrigger {
                    objectName: "trigA"
                    text: qsTr("Item A")
                }
                ShadcnAccordionContent {
                    objectName: "contA"
                    Text {
                        objectName: "bodyA"
                        Layout.fillWidth: true
                        text: qsTr("Content of A")
                        color: theme.mutedForeground
                    }
                }
            }
            ShadcnAccordionItem {
                objectName: "itemB"
                value: "b"
                ShadcnAccordionTrigger { objectName: "trigB"; text: qsTr("Item B") }
                ShadcnAccordionContent {
                    objectName: "contB"
                    Text { Layout.fillWidth: true; text: qsTr("Content of B") }
                }
            }
            ShadcnAccordionItem {
                objectName: "itemC"
                value: "c"
                ShadcnAccordionTrigger { objectName: "trigC"; text: qsTr("Item C") }
                ShadcnAccordionContent {
                    objectName: "contC"
                    Text { Layout.fillWidth: true; text: qsTr("Content of C") }
                }
            }
        }
    }

    Component {
        id: multiComp
        ShadcnAccordion {
            objectName: "acc"
            multiple: true
            width: 400
            ShadcnAccordionItem {
                objectName: "itemA"
                value: "a"
                ShadcnAccordionTrigger { objectName: "trigA"; text: "A" }
                ShadcnAccordionContent { objectName: "contA"; Text { Layout.fillWidth: true; text: "aa" } }
            }
            ShadcnAccordionItem {
                objectName: "itemB"
                value: "b"
                ShadcnAccordionTrigger { objectName: "trigB"; text: "B" }
                ShadcnAccordionContent { objectName: "contB"; Text { Layout.fillWidth: true; text: "bb" } }
            }
        }
    }

    Component {
        id: collapsibleComp
        ShadcnAccordion {
            objectName: "acc"
            collapsible: true
            width: 400
            ShadcnAccordionItem {
                objectName: "itemA"
                value: "a"
                ShadcnAccordionTrigger { objectName: "trigA"; text: "A" }
                ShadcnAccordionContent { objectName: "contA"; Text { Layout.fillWidth: true; text: "aa" } }
            }
        }
    }

    // 内容里放一个真按钮：验证收起态的内容吃不掉点击
    Component {
        id: interactiveComp
        ShadcnAccordion {
            objectName: "acc"
            collapsible: true
            width: 400
            ShadcnAccordionItem {
                objectName: "itemA"
                value: "a"
                ShadcnAccordionTrigger { objectName: "trigA"; text: "A" }
                ShadcnAccordionContent {
                    objectName: "contA"
                    ShadcnButton {
                        objectName: "innerButton"
                        text: qsTr("Inside")
                    }
                }
            }
        }
    }

    SignalSpy {
        id: toggledSpy

        signalName: "toggled"
    }

    SignalSpy {
        id: clickSpy

        signalName: "clicked"
    }

    TestCase {
        id: tc
        name: "ShadcnAccordion"
        when: windowShown

        property var acc: null

        function init() {
            acc = createTemporaryObject(basicComp, root)
            verify(!!acc, "accordion created")
            wait(20)
        }

        function cleanup() {
            if (acc !== null)
                acc.destroy()
            acc = null
        }

        function byName(name) {
            return findChild(acc, name)
        }

        // 轮询等条件成立（上限 ~3s），不依赖 tryVerify 的签名
        function waitUntil(cond, what) {
            for (let i = 0; i < 300; ++i) {
                if (cond())
                    return true
                wait(10)
            }
            return cond()
        }

        // 在动画窗口内逐帧找「严格介于 from 与 to 之间」的值
        function sawBetween(getter, from, to) {
            const lo = Math.min(from, to)
            const hi = Math.max(from, to)
            for (let i = 0; i < 200; ++i) {
                wait(5)
                const v = getter()
                if (v > lo + 0.5 && v < hi - 0.5)
                    return true
            }
            return false
        }

        // 默认全收起：value 为空、三行 expanded=false，行高只剩 trigger + 分隔线
        function test_default_all_collapsed() {
            compare(acc.value, "", "默认 value 为空 = 无展开项")
            compare(acc.multiple, false)
            compare(acc.collapsible, false)
            const a = byName("itemA")
            const b = byName("itemB")
            const c = byName("itemC")
            compare(a.expanded, false)
            compare(b.expanded, false)
            compare(c.expanded, false)
            const contA = byName("contA")
            compare(contA.height, 0, "收起的内容区高度 0")
            verify(a.height > 0, "行本身仍有 trigger 高度: " + a.height)
            compare(acc.height, a.height + b.height + c.height,
                    "根高 = 三行之和（派生链单向，动画中间值也要成立）")
        }

        // 点 trigger 展开：value 回写、内容高度到自然高、chevron 双图标互斥
        function test_click_opens_and_swaps_chevrons() {
            const contA = byName("contA")
            const host = findChild(contA, "contentHost")
            verify(host !== null, "contentHost 存在")
            const target = host.height
            verify(target > 0, "内容自然高应大于 0，实测 " + target)

            mouseClick(byName("trigA"))
            verify(waitUntil(function() { return acc.value === "a"; }, "value 回写"))
            verify(waitUntil(function() { return byName("itemA").expanded; }, "展开"))
            verify(waitUntil(function() { return contA.height === target; }, "到自然高"))

            // 官方是「双图标切换」而不是旋转：收起态 down 可见 / up 隐藏，展开相反
            const trigA = byName("trigA")
            const down = findChild(trigA, "chevronDown")
            const up = findChild(trigA, "chevronUp")
            verify(!!down && !!up, "两个 chevron 都在")
            compare(down.visible, false, "展开态 chevron-down 隐藏")
            compare(up.visible, true, "展开态 chevron-up 显示")
            compare(up.size, 16, "图标 size-4 = 16px")
            compare(down.name, "chevron-down")
            compare(up.name, "chevron-up")
        }

        // 单选：点另一项自动收起前项
        function test_single_select_closes_previous() {
            mouseClick(byName("trigA"))
            verify(waitUntil(function() { return byName("itemA").expanded; }, "A 展开"))
            mouseClick(byName("trigB"))
            verify(waitUntil(function() { return byName("itemB").expanded; }, "B 展开"))
            verify(waitUntil(function() { return !byName("itemA").expanded; }, "A 自动收起"))
            compare(acc.value, "b", "单选 value 只有一个值")
            const hostA = findChild(byName("contA"), "contentHost")
            compare(hostA.visible, false, "前项收起后内容不可见")
        }

        // collapsible=false（默认）：点已展开项不收起
        function test_collapsible_false_keeps_open() {
            mouseClick(byName("trigA"))
            verify(waitUntil(function() { return byName("itemA").expanded; }, "A 展开"))
            mouseClick(byName("trigA"))
            wait(40)
            compare(byName("itemA").expanded, true,
                    "collapsible=false 时点已展开项应保持不变")
            compare(acc.value, "a")
        }

        // collapsible=true：点已展开项可收起（可全收）
        function test_collapsible_true_can_close_all() {
            const accC = createTemporaryObject(collapsibleComp, root, { y: 500 })
            verify(!!accC, "created")
            wait(20)
            const t = findChild(accC, "trigA")
            mouseClick(t)
            verify(waitUntil(function() { return accC.value === "a"; }, "展开"))
            mouseClick(t)
            verify(waitUntil(function() { return accC.value === ""; },
                               "collapsible=true 应能收起"))
            accC.destroy()
        }

        // multiple：两项可同时展开，value 是数组；再点一项只移除自己
        function test_multiple_keeps_both_open() {
            const accM = createTemporaryObject(multiComp, root, { y: 500 })
            verify(!!accM, "created")
            wait(20)
            mouseClick(findChild(accM, "trigA"))
            mouseClick(findChild(accM, "trigB"))
            verify(waitUntil(function() {
                return findChild(accM, "itemA").expanded && findChild(accM, "itemB").expanded;
            }, "两项同时展开"))
            const v = accM.value
            verify(Array.isArray(v), "多选 value 应为数组，实测 " + v)
            compare(v.length, 2)
            mouseClick(findChild(accM, "trigA"))
            verify(waitUntil(function() { return !findChild(accM, "itemA").expanded; }, "移除 A"))
            compare(findChild(accM, "itemB").expanded, true, "移除一项不该影响另一项")
            accM.destroy()
        }

        // 官方 not-last:border-b：末行无分隔线，其余行 1px theme.border
        function test_border_on_every_row_except_last() {
            const sepA = findChild(byName("itemA"), "separator")
            const sepB = findChild(byName("itemB"), "separator")
            const sepC = findChild(byName("itemC"), "separator")
            verify(!!sepA && !!sepB && !!sepC, "三行都有 separator 元素")
            compare(sepA.visible, true, "第一行有底部分隔线")
            compare(sepB.visible, true, "第二行有底部分隔线")
            compare(sepC.visible, false, "末行无分隔线（not-last）")
            compare(sepA.height, 1, "分隔线 1px")
            compare(sepC.height, 1, "元素高度恒为 1，末行用 visible 收起")
            compare(sepA.color.toString(), theme.border.toString(), "分隔线色 = theme.border")
            compare(byName("itemC").__isLast, true)
            compare(byName("itemA").__isLast, false)
        }

        // 高度动画真在推进（展开 + 收起两个方向都采样）
        function test_height_animation_in_progress() {
            const contA = byName("contA")
            const target = findChild(contA, "contentHost").height
            verify(target > 0, "自然高 " + target)

            mouseClick(byName("trigA"))
            verify(sawBetween(function() { return contA.height; }, 0, target),
                   "展开应采到 (0, 自然高) 之间的中间值；采不到说明动画被删或被布局接管")
            verify(waitUntil(function() { return contA.height === target; }, "到位"))

            mouseClick(byName("trigB"))
            verify(sawBetween(function() { return contA.height; }, target, 0),
                   "收起同样应有中间高度")
            verify(waitUntil(function() { return contA.height === 0; }, "收到 0"))
        }

        // 收起态：外层高 0 + clip: true，内容宿主仍是自然高
        function test_collapsed_content_clipped_not_shrunk() {
            const contA = byName("contA")
            const host = findChild(contA, "contentHost")
            compare(contA.height, 0, "收起态外层高 0")
            verify(contA.clip, "内容区必须 clip（官方 overflow-hidden），否则收起态内容溢出可见")
            verify(host.height > 0, "内容宿主仍是自然高: " + host.height)
            compare(host.visible, false, "收起后内容宿主不可见（不参与命中测试）")
        }

        // 收起后内容吃不掉点击：先展开证明内容可交互，收起后同一坐标不再命中
        function test_collapsed_content_not_clickable() {
            const accI = createTemporaryObject(interactiveComp, root, { y: 500 })
            verify(!!accI, "created")
            wait(20)
            const btn = findChild(accI, "innerButton")
            verify(!!btn, "内容里有按钮")
            const itemA = findChild(accI, "itemA")
            clickSpy.target = btn
            clickSpy.clear()

            // 展开：此时内容可交互
            mouseClick(findChild(accI, "trigA"))
            verify(waitUntil(function() { return itemA.expanded; }, "点 trigger 应展开"))
            wait(260)   // 等高度动画走完，内容宿主才 visible
            const pt = btn.mapToItem(accI, btn.width / 2, btn.height / 2)
            mouseClick(accI, pt.x, pt.y)
            verify(waitUntil(function() { return clickSpy.count === 1; },
                              "展开态内容里的按钮应能收到点击"))

            // 收起（collapsible=true 才收得掉）：同一坐标再点，什么都不该命中
            clickSpy.clear()
            mouseClick(findChild(accI, "trigA"))
            verify(waitUntil(function() { return !itemA.expanded; }, "应能收起"))
            wait(260)
            mouseClick(accI, pt.x, pt.y)
            wait(30)
            compare(clickSpy.count, 0, "收起态内容里的按钮不应收到点击")
            compare(itemA.expanded, false, "点收起态内容也不应触发开合（clip + 祖先不可见拦住）")
            clickSpy.target = null
            accI.destroy()
        }

        // 键盘可达：trigger 可聚焦，Enter / Space 切换开合
        function test_keyboard_focus_and_activation() {
            const trigA = byName("trigA")
            trigA.forceActiveFocus()
            verify(waitUntil(function() { return trigA.activeFocus; }, "trigger 应可用键盘聚焦"))
            keyClick(Qt.Key_Return)
            verify(waitUntil(function() { return acc.value === "a"; }, "Enter 应展开"))

            const accC = createTemporaryObject(collapsibleComp, root, { y: 500 })
            verify(!!accC, "created")
            wait(20)
            const t2 = findChild(accC, "trigA")
            t2.forceActiveFocus()
            keyClick(Qt.Key_Space)
            verify(waitUntil(function() { return accC.value === "a"; }, "Space 应展开"))
            keyClick(Qt.Key_Space)
            verify(waitUntil(function() { return accC.value === ""; },
                              "collapsible=true 时再按 Space 应收起"))
            accC.destroy()
        }

        // toggled 信号：展开/收起各发一次，带值与方向
        function test_toggled_signal() {
            toggledSpy.target = acc
            toggledSpy.clear()
            mouseClick(byName("trigA"))
            verify(waitUntil(function() { return toggledSpy.count >= 1; }, "展开应发 toggled"))
            compare(toggledSpy.signalArguments[0][0], "a")
            compare(toggledSpy.signalArguments[0][1], true, "opened = true")

            toggledSpy.clear()
            mouseClick(byName("trigB"))
            verify(waitUntil(function() { return toggledSpy.count >= 1; }, "切到 B 应发 toggled"))
            compare(toggledSpy.signalArguments[0][0], "b")
            compare(toggledSpy.signalArguments[0][1], true)
            toggledSpy.target = null
        }

        // 禁用项（aria-disabled）：点不动 + opacity-50
        function test_disabled_trigger() {
            const trigA = byName("trigA")
            trigA.enabled = false
            wait(20)
            compare(trigA.opacity, 0.5, "禁用态 opacity-50")
            mouseClick(trigA)
            wait(40)
            compare(acc.value, "", "禁用项不可开合")
            trigA.enabled = true
        }
    }
}
