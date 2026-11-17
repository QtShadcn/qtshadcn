import QtQuick
import QtTest
import QtShadcn

// ShadcnHoverCard：规格锁 + 悬停时序
//
// 对齐依据（https://ui.shadcn.com/r/styles/base-nova/hover-card.json，
// 底层 Base UI PreviewCard）：
//   hover-card-content: w-64(256) rounded-lg bg-popover p-2.5(10) text-sm
//                       ring-1 ring-foreground/10 shadow-md，fade/zoom-95 100ms
//                       side="bottom" sideOffset=4 align="center" alignOffset=4
//   Root/Trigger: delay=600 / closeDelay=300（Base UI PreviewCard 默认值，
//                       registry 的 json 不含数值，从 base-ui 文档核实）
//
// 时序类断言全部走 tryVerify/tryCompare（超时上限给足，判据是「最终达到」
// 而不是「第 N ms 恰好在第几帧」—— tst_ShadcnFadeZoomTransition 的 CI 教训）。
Item {
    id: root
    width: 700
    height: 500

    QtShadcnTheme { id: theme }

    Component {
        id: basicComp
        ShadcnHoverCard {
            objectName: "hc"
            ShadcnHoverCardTrigger { text: "悬停我"; width: 90; height: 32 }
            ShadcnHoverCardContent {
                Text { objectName: "line1"; text: "简介第一行" }
                Text { objectName: "line2"; text: "简介第二行" }
            }
        }
    }

    // 短延时版：时序用例都拿它跑（600/300 默认值测一遍即可，逐条等 1s 会拖慢套件）
    Component {
        id: fastComp
        ShadcnHoverCard {
            objectName: "hc"
            delay: 60
            closeDelay: 40
            ShadcnHoverCardTrigger { text: "快点"; width: 90; height: 32 }
            ShadcnHoverCardContent {}
        }
    }

    TestCase {
        name: "ShadcnHoverCard"
        when: windowShown

        // 触发项默认摆在 (120, 200)：离边够远，卡片翻不到边界
        function place(hc) {
            const trig = hc.trigger
            trig.x = 120
            trig.y = 200
            return trig
        }

        // ── 规格锚点 ──
        function test_content_spec() {
            const hc = createTemporaryObject(basicComp, root)
            const c = hc.content
            verify(!!c, "content collected")

            compare(c.panelWidth, 256, "registry w-64（与 popover 的 w-72 不同）")
            compare(c.width, 256)
            compare(c.panelPadding, 10, "registry p-2.5")
            compare(c.contentSpacing, 0, "hover-card content 没有 flex-col gap-2.5")
            compare(c.radius, theme.radiusLg, "rounded-lg 走 token")
            compare(c.color, theme.popover, "bg-popover")
            compare(c.border.width, 1, "ring-1")
            compare(c.border.color,
                    Qt.rgba(theme.foreground.r, theme.foreground.g, theme.foreground.b, 0.10),
                    "ring-foreground/10")
            compare(c.side, "bottom")
            compare(c.align, "center")
            // Base UI PreviewCard 的 delay/closeDelay 默认值
            compare(hc.delay, 600)
            compare(hc.closeDelay, 300)
            // alignOffset=4 是 registry 里 hover-card 与 popover（默认 0）的另一处差异
            compare(c.alignOffset, 4, "Content.alignOffset 应透传")
        }

        // trigger 默认样式：官方 hover-card 触发项就是链接
        function test_trigger_defaults() {
            const hc = createTemporaryObject(basicComp, root)
            const trig = hc.trigger
            compare(trig.variant, ShadcnButton.Variant.Link)
            compare(trig.objectName, "trigger")
        }

        // ── 时序：openDelay ──
        function test_open_delay() {
            const hc = createTemporaryObject(fastComp, root)
            const trig = place(hc)
            compare(hc.showing, false)

            mouseMove(trig, trig.width / 2, trig.height / 2)
            // 刚进入立刻读：delay 未到，不许已经打开
            wait(10)
            verify(!hc.showing, "delay 未到就打开 = 时序缺陷")
            // 最终要开（上限 2s 给足，判据是「达到过」）
            tryCompare(hc, "showing", true, 2000)
            tryCompare(hc.popup, "visible", true)

            mouseMove(root, 600, 450)   // 彻底移开，收尾
            tryCompare(hc, "showing", false)
        }

        // 快速划过不该弹：离开时 delay 计时器必须被取消
        function test_quick_pass_does_not_open() {
            const hc = createTemporaryObject(fastComp, root)
            const trig = place(hc)
            mouseMove(trig, 20, 16)
            wait(10)                       // 进（delay=60，还没到）
            mouseMove(root, 600, 450)      // 出
            wait(300)                      // 远超 delay + closeDelay
            verify(!hc.showing, "扫过触发项后不该弹出")
            verify(!hc.popup.visible)
        }

        // ── 时序：closeDelay ──
        function test_close_delay() {
            const hc = createTemporaryObject(fastComp, root)
            const trig = place(hc)
            mouseMove(trig, 20, 16)
            tryCompare(hc, "showing", true, 2000)

            mouseMove(root, 500, 60)   // 离开触发项（注意：不能路过卡片区域，
                                       // 从触发项向左下离开）
            wait(10)
            verify(hc.showing, "closeDelay 未到就关 = 时序缺陷")
            tryCompare(hc, "showing", false, 2000)
            tryCompare(hc.popup, "visible", false)
        }

        // 指针移进卡片 → 取消关闭计时（Base UI closeDelay 的原始动机）
        function test_hover_into_content_keeps_open() {
            const hc = createTemporaryObject(basicComp, root)
            hc.delay = 40
            hc.closeDelay = 60
            const trig = place(hc)
            trig.x = 300
            trig.y = 60
            mouseMove(trig, 20, 16)
            tryCompare(hc, "showing", true, 2000)

            // 卡片在触发项下方（bottom + 4px），指针从触发项「往下」挪进卡片
            wait(20)
            mouseMove(hc.content, hc.content.width / 2, 8)
            tryCompare(hc, "pointerInside", true, 500)

            wait(300)   // 远超 closeDelay：若没取消计时器，早就关了
            verify(hc.showing, "指针进卡片后必须保持打开")

            mouseMove(root, 600, 450)
            tryCompare(hc, "showing", false, 2000)
        }

        // ── 强制开关（无鼠标场景） ──
        function test_forced_open() {
            const hc = createTemporaryObject(basicComp, root)
            place(hc)
            hc.open = true
            tryCompare(hc.popup, "visible", true)
            hc.open = false
            tryCompare(hc.popup, "visible", false)
        }

        // ── 关闭路径 ──
        function test_escape_closes_and_suppresses_reopen() {
            const hc = createTemporaryObject(basicComp, root)
            hc.delay = 40
            const trig = place(hc)
            mouseMove(trig, 20, 16)
            tryCompare(hc, "showing", true, 2000)

            keyClick(Qt.Key_Escape)
            tryCompare(hc.popup, "visible", false)
            // 指针还停在触发项上：不许立刻弹回（关不掉的抖动 = 缺 _dismissed 抑制）
            wait(300)
            verify(!hc.showing, "Esc 后指针未离开就重开 = 抖动缺陷")

            // 移开再回来：必须能再次打开（抑制只到「离开过一次」为止）
            mouseMove(root, 600, 450)
            wait(60)
            mouseMove(trig, 20, 16)
            tryCompare(hc, "showing", true, 2000)
            mouseMove(root, 600, 450)
            tryCompare(hc, "showing", false, 2000)
        }

        function test_press_outside_closes() {
            const hc = createTemporaryObject(basicComp, root)
            hc.delay = 40
            const trig = place(hc)
            mouseMove(trig, 20, 16)
            tryCompare(hc, "showing", true, 2000)

            mouseClick(root, 640, 470)
            tryCompare(hc.popup, "visible", false)
            verify(!hc.showing, "点外后 hover 态必须复位")
            mouseMove(root, 640, 471)   // 确保悬停状态清干净
        }

        // ── 定位（与 Popover 共用弹层件，这里只钉 HoverCard 的默认值生效） ──
        function test_position_below() {
            const hc = createTemporaryObject(basicComp, root)
            hc.delay = 40
            const trig = place(hc)
            mouseMove(trig, 20, 16)
            tryCompare(hc, "showing", true, 2000)
            wait(150)

            compare(hc.placement.resolvedSide, "bottom")
            const trigBottom = trig.mapToItem(hc.popup.parent, 0, trig.height).y
            compare(hc.popup.y, trigBottom + 4, "sideOffset=4 生效")
            mouseMove(root, 600, 450)
        }

        // 贴底翻转免费送（同一套定位器）
        function test_flip_when_no_space_below() {
            const hc = createTemporaryObject(basicComp, root)
            hc.delay = 40
            const trig = place(hc)
            trig.x = 300
            trig.y = root.height - 36
            mouseMove(trig, 20, 16)
            tryCompare(hc, "showing", true, 2000)
            wait(150)

            compare(hc.placement.resolvedSide, "top", "贴底必须翻到上方")
            verify(hc.popup.y + hc.popup.height <= trig.y + 1,
                   "翻转后应在触发项上方，y=" + hc.popup.y)
            mouseMove(root, 600, 450)
        }

        // ── 内容透传：子项挂进弹层、面板尺寸驱动弹层 ──
        function test_content_children_passthrough() {
            const hc = createTemporaryObject(basicComp, root)
            const line1 = findChild(hc, "line1")
            const line2 = findChild(hc, "line2")
            verify(!!line1 && !!line2, "子项保留在树里")
            compare(hc.content.parent, findChild(hc.popup, "popoverHolder"))

            hc.open = true
            tryCompare(hc.popup, "visible", true)
            // 面板高度 = 两行文字 + p-2.5×2（hover-card 无 gap）
            const expect = 10 * 2 + line1.height + line2.height
            verify(Math.abs(hc.content.height - expect) <= 1,
                   "无 gap 的面板高度期望 " + expect + " 实际 " + hc.content.height)
            compare(hc.popup.height, hc.content.height)
            hc.open = false
        }

        // ── 过渡与 Popover 同源 ──
        function test_enter_has_fade_transition() {
            const hc = createTemporaryObject(basicComp, root)
            hc.open = true
            let sawIntermediate = false
            for (let i = 0; i < 60; ++i) {
                wait(5)
                const v = hc.popup.opacity
                if (v > 0.001 && v < 0.999) {
                    sawIntermediate = true
                    break
                }
            }
            verify(sawIntermediate, "弹层没有 fade 过渡")
            tryCompare(hc.popup, "opacity", 1.0)
            hc.open = false
        }

        function test_duration_goes_through_motion_token() {
            const hc = createTemporaryObject(basicComp, root)
            compare(hc.transitionDurationMs, theme.durationInstant)
            hc.reducedMotion = true
            compare(hc.transitionDurationMs, 0, "reducedMotion 打开后时长必须归零")
        }
    }
}
