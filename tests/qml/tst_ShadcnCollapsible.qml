// Component 里访问外层 root / theme，显式声明后静态分析能确认来源
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtTest
import QtShadcn

// ShadcnCollapsible：单个可开合区。官方 registry 里它是零样式透传（三件套都只
// 转发到 Base UI 的 CollapsiblePrimitive），所以这里断言的是「语义 + 复用的
// Accordion 同源视觉」：默认收起、点击切换 open/toggled、动画与收起态裁剪、
// 键盘可达、Item 变体下末行无分隔线。
//
// 等待手法同 tst_ShadcnAccordion：用轮询 waitUntil + wait() 推进事件循环，
// 不用 tryVerify 的可变签名（6.8 / 6.11 参数个数不同）。
Item {
    id: root
    width: 600
    height: 900

    QtShadcnTheme {
        id: theme
    }

    // 直接三段式（Trigger/Content 是 Collapsible 自己的组件）
    Component {
        id: basicComp
        ShadcnCollapsible {
            id: col

            objectName: "col"
            width: 400

            ShadcnCollapsibleTrigger {
                objectName: "trig"
                text: qsTr("Filters")
            }
            ShadcnCollapsibleContent {
                objectName: "cont"
                Text {
                    objectName: "body"
                    Layout.fillWidth: true
                    text: qsTr("Region / Status / Owner")
                    color: theme.mutedForeground
                }
            }
        }
    }

    // Item 变体（想要行分隔线时套一层 AccordionItem，语义一样）
    Component {
        id: itemComp
        ShadcnCollapsible {
            objectName: "col"
            width: 400
            ShadcnAccordionItem {
                objectName: "item"
                ShadcnAccordionTrigger { objectName: "trig"; text: qsTr("More") }
                ShadcnAccordionContent {
                    objectName: "cont"
                    Text { Layout.fillWidth: true; text: qsTr("detail") }
                }
            }
        }
    }

    // 收起态里放按钮，验证内容吃不掉点击
    Component {
        id: interactiveComp
        ShadcnCollapsible {
            objectName: "col"
            width: 400
            ShadcnCollapsibleTrigger { objectName: "trig"; text: qsTr("Filters") }
            ShadcnCollapsibleContent {
                objectName: "cont"
                ShadcnButton { objectName: "innerButton"; text: qsTr("Apply") }
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
        name: "ShadcnCollapsible"
        when: windowShown

        property var col: null

        function init() {
            col = createTemporaryObject(basicComp, root)
            verify(!!col, "collapsible created")
            wait(20)
        }

        function cleanup() {
            if (col !== null)
                col.destroy()
            col = null
        }

        function byName(name) {
            return findChild(col, name)
        }

        function waitUntil(cond, what) {
            for (let i = 0; i < 300; ++i) {
                if (cond())
                    return true
                wait(10)
            }
            return cond()
        }

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

        // 默认收起：open=false，内容外层高 0，trigger 显示 chevron-down
        function test_default_closed() {
            compare(col.open, false, "默认收起")
            const cont = byName("cont")
            compare(cont.height, 0, "收起态内容外层高 0")
            compare(cont.expanded, false)
            const trig = byName("trig")
            compare(trig.expanded, false)
            compare(findChild(trig, "chevronDown").visible, true)
            compare(findChild(trig, "chevronUp").visible, false)
            verify(col.height > 0, "行高只剩 trigger: " + col.height)
        }

        // 点 trigger 展开 → 再点收起（open 两向受控）
        function test_click_opens_then_closes() {
            const cont = byName("cont")
            const host = findChild(cont, "contentHost")
            verify(!!host, "复用 Accordion 的 contentHost")
            const target = host.height
            verify(target > 0, "内容自然高 " + target)

            mouseClick(byName("trig"))
            verify(waitUntil(function() { return col.open; }, "点 trigger 应展开"))
            verify(waitUntil(function() { return cont.height === target; }, "到自然高"))
            const trig = byName("trig")
            compare(findChild(trig, "chevronDown").visible, false, "展开态 down 隐藏")
            compare(findChild(trig, "chevronUp").visible, true, "展开态 up 显示")

            mouseClick(trig)
            verify(waitUntil(function() { return !col.open; }, "再点应收起"))
            verify(waitUntil(function() { return cont.height === 0; }, "收到 0"))
            // Collapsible 没有 collapsible=false 这一档：单块区域总能全收
        }

        // 宿主直接写 open（受控 API）也生效
        function test_open_is_controlled_property() {
            col.open = true
            verify(waitUntil(function() { return byName("cont").height > 0; }, "写入 open 应展开"))
            col.open = false
            verify(waitUntil(function() { return byName("cont").height === 0; }, "写回 false 应收起"))
        }

        // toggled 信号带方向
        function test_toggled_signal() {
            toggledSpy.target = col
            toggledSpy.clear()
            mouseClick(byName("trig"))
            verify(waitUntil(function() { return toggledSpy.count >= 1; }, "展开应发 toggled"))
            compare(toggledSpy.signalArguments[0][0], true, "opened = true")
            toggledSpy.clear()
            mouseClick(byName("trig"))
            verify(waitUntil(function() { return toggledSpy.count >= 1; }, "收起应发 toggled"))
            compare(toggledSpy.signalArguments[0][0], false, "opened = false")
            toggledSpy.target = null
        }

        // 高度动画真在推进（两个方向都采样）
        function test_height_animation_in_progress() {
            const cont = byName("cont")
            const target = findChild(cont, "contentHost").height
            verify(target > 0, "自然高 " + target)

            mouseClick(byName("trig"))
            verify(sawBetween(function() { return cont.height; }, 0, target),
                   "展开应采到中间高度；采不到说明动画被删或被布局接管")
            verify(waitUntil(function() { return cont.height === target; }, "到位"))

            mouseClick(byName("trig"))
            verify(sawBetween(function() { return cont.height; }, target, 0),
                   "收起同样应有中间高度")
            verify(waitUntil(function() { return cont.height === 0; }, "收到 0"))
        }

        // 收起态内容不可交互、靠 clip 隐藏而不是挤扁
        function test_collapsed_content_clipped_and_not_clickable() {
            const accI = createTemporaryObject(interactiveComp, root, { y: 500 })
            verify(!!accI, "created")
            wait(20)
            const btn = findChild(accI, "innerButton")
            verify(!!btn, "内容里有按钮")
            const cont = findChild(accI, "cont")
            const host = findChild(cont, "contentHost")
            compare(cont.height, 0)
            verify(cont.clip, "内容区必须 clip（官方 overflow-hidden）")
            verify(host.height > 0, "内容宿主仍是自然高: " + host.height)
            compare(host.visible, false, "收起后内容宿主不可见")

            clickSpy.target = btn
            clickSpy.clear()

            // 先展开：此时内容可交互，并记下按钮中心坐标（收起后该点已不属于任何可点区）
            mouseClick(findChild(accI, "trig"))
            verify(waitUntil(function() { return accI.open; }, "展开"))
            wait(260)
            const pt = btn.mapToItem(accI, btn.width / 2, btn.height / 2)
            mouseClick(accI, pt.x, pt.y)
            verify(waitUntil(function() { return clickSpy.count === 1; },
                              "展开态内容里的按钮应能收到点击"))

            // 收起后同一坐标再点：什么都不该命中，也不该顺带展开
            clickSpy.clear()
            mouseClick(findChild(accI, "trig"))
            verify(waitUntil(function() { return !accI.open; }, "应能收起"))
            wait(260)
            mouseClick(accI, pt.x, pt.y)
            wait(30)
            compare(clickSpy.count, 0, "收起态内容里的按钮不应收到点击")
            compare(accI.open, false, "点收起态内容不应触发开合")
            clickSpy.target = null
            accI.destroy()
        }

        // 键盘可达：可聚焦 + Enter/Space 切换
        function test_keyboard_focus_and_activation() {
            // 聚焦内部真实按钮：CollapsibleTrigger 是 Item 包装，自己不可聚焦
            const trig = findChild(byName("trig"), "collapsibleInnerTrigger")
            verify(!!trig, "内层按钮存在")
            trig.forceActiveFocus()
            verify(waitUntil(function() { return trig.activeFocus; }, "trigger 应可键盘聚焦"))
            keyClick(Qt.Key_Return)
            verify(waitUntil(function() { return col.open; }, "Enter 应展开"))
            keyClick(Qt.Key_Space)
            verify(waitUntil(function() { return !col.open; }, "Space 应收起"))
        }

        // Item 变体：open 经 AccordionItem 传导；单行 = 末行 = 无分隔线
        function test_item_variant_and_separator() {
            const colI = createTemporaryObject(itemComp, root, { y: 500 })
            verify(!!colI, "created")
            wait(20)
            const item = findChild(colI, "item")
            compare(item.expanded, false, "无根 Accordion 时行态跟 Collapsible.open")
            mouseClick(findChild(colI, "trig"))
            verify(waitUntil(function() { return item.expanded; }, "Item 变体应能展开"))
            verify(waitUntil(function() { return findChild(colI, "cont").height > 0; }, "内容有高度"))

            const sep = findChild(item, "separator")
            verify(!!sep, "行内有 separator 元素")
            compare(item.__isLast, true, "Collapsible 里的单行是末行")
            compare(sep.visible, false, "末行无分隔线（not-last:border-b）")
            colI.destroy()
        }

        // 复用同源实现：Collapsible 的 trigger/content 内部就是 Accordion 的那两个组件
        function test_reuses_accordion_parts() {
            const trig = byName("trig")
            const inner = findChild(trig, "collapsibleInnerTrigger")
            verify(!!inner, "CollapsibleTrigger 复用 ShadcnAccordionTrigger")
            compare(inner.__isShadcnAccordionTrigger, true)
            const cont = byName("cont")
            const panel = findChild(cont, "collapsibleInnerContent")
            verify(!!panel, "CollapsibleContent 复用 ShadcnAccordionContent")
            compare(panel.__isShadcnAccordionContent, true)
            // 认亲要跳过包装层：内层 trigger 仍找到 Collapsible 根
            compare(inner.__item === col, true, "内层 trigger 应认到 Collapsible 根")
        }
    }
}
