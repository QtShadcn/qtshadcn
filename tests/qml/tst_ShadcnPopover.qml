import QtQuick
import QtTest
import QtShadcn

// ShadcnPopover：对齐 registry popover.json 的规格锁 + 弹层行为
//
// 对齐依据（https://ui.shadcn.com/r/styles/base-nova/popover.json）：
//   popover-content: w-72(288) rounded-lg bg-popover p-2.5(10) gap-2.5(10) text-sm(14)
//                    ring-1 ring-foreground/10 shadow-md，fade/zoom-95 duration-100
//                    align="center" alignOffset=0 side="bottom" sideOffset=4
//   popover-header:  flex flex-col gap-0.5(2) text-sm
//   popover-title:   font-medium
//   popover-description: text-muted-foreground
//
// 钉住三类东西：① 尺寸 / 圆角 / 描边这些「肉眼看着差不多、实际已经偏了」的锚点；
// ② 定位参数从 Content 透传到 ShadcnPopupPosition（贴边翻转是定位器的能力，这里验证
// Popover 真的接上了它，而不是又手写 y = height + 4）；③ overlay 层的可见性门与
// 两条关闭路径（点外 / Esc）。
Item {
    id: root
    width: 700
    height: 500

    QtShadcnTheme { id: theme }

    Component {
        id: basicComp
        ShadcnPopover {
            objectName: "popover"
            ShadcnPopoverTrigger {
                text: "打开"
            }
            ShadcnPopoverContent {
                ShadcnPopoverHeader {
                    objectName: "head"
                    ShadcnPopoverTitle { objectName: "title"; text: "标题" }
                    ShadcnPopoverDescription { objectName: "desc"; text: "描述" }
                }
                Text { objectName: "body"; text: "正文" }
            }
        }
    }

    // 可摆放位置的版本：定位断言都用它（触发项几何确定）
    Component {
        id: edgeComp
        ShadcnPopover {
            objectName: "popover"
            ShadcnPopoverTrigger { text: "边"; width: 80; height: 32 }
            ShadcnPopoverContent {}
        }
    }

    // 隐藏宿主：Popup 在 window overlay 层，不受父项 visible 约束，
    // 组件必须自己查祖先链（截图串页的回归锁）
    Component {
        id: hiddenHostComp
        Item {
            objectName: "hiddenHost"
            width: 200
            height: 100
            ShadcnPopover {
                objectName: "popover"
                ShadcnPopoverTrigger { text: "藏起来" }
                ShadcnPopoverContent {}
            }
        }
    }

    TestCase {
        name: "ShadcnPopover"
        when: windowShown

        function test_content_spec_defaults() {
            const p = createTemporaryObject(basicComp, root)
            verify(!!p, "popover created")
            const c = p.content
            verify(!!c, "content collected")
            verify(!!p.trigger, "trigger collected")

            compare(c.panelWidth, 288, "registry w-72")
            compare(c.panelPadding, 10, "registry p-2.5")
            compare(c.contentSpacing, 10, "registry gap-2.5")
            compare(c.width, 288)
            // height = p-2.5×2 + Header(Title+gap+Desc) + gap + 正文行
            // 行高随字体环境浮动，用「头部块 + 间距 + 正文块」的构成式断言代替魔数
            const header = findChild(p, "head")
            const body = findChild(p, "body")
            verify(!!header && !!body, "header/body created")
            const expect = 10 * 2 + header.height + 10 + body.height
            verify(Math.abs(c.height - expect) <= 1,
                   "height 构成 = p + Header + gap-2.5 + body，期望 " + expect + " 实际 " + c.height)
            compare(c.radius, theme.radiusLg, "rounded-lg 必须走 token 而不是像素")
            compare(c.color, theme.popover, "bg-popover")
            compare(c.border.width, 1, "ring-1")
            compare(c.border.color,
                    Qt.rgba(theme.foreground.r, theme.foreground.g, theme.foreground.b, 0.10),
                    "ring-foreground/10")
            // registry 的默认定位参数
            compare(c.side, "bottom")
            compare(c.align, "center")
            compare(c.alignOffset, 0)
            compare(c.sideOffset, 4)
        }

        function test_header_title_description() {
            const p = createTemporaryObject(basicComp, root)
            const head = findChild(p, "head")
            const title = findChild(p, "title")
            const desc = findChild(p, "desc")
            verify(!!head && !!title && !!desc, "header parts 收集成功")

            compare(head.spacing, 2, "registry header gap-0.5")
            compare(title.font.weight, Font.Medium, "font-medium")
            compare(title.color, theme.popoverForeground)
            compare(desc.color, theme.mutedForeground, "text-muted-foreground")
            compare(title.font.pixelSize, 14, "text-sm")
            compare(desc.font.pixelSize, 14, "text-sm")
        }

        // 内容必须真的挂进弹层（而不是留在 root 里被本地布局吃掉）
        function test_content_mounted_in_popup() {
            const p = createTemporaryObject(basicComp, root)
            const holder = findChild(p.popup, "popoverHolder")
            verify(!!holder, "找不到内容挂接点")
            compare(p.content.parent, holder, "Content 应挂在弹层里")
            // 挂接后弹层尺寸由 Content 决定
            compare(holder.implicitWidth, p.content.width)
            compare(holder.implicitHeight, p.content.height)
        }

        function test_trigger_click_opens() {
            const p = createTemporaryObject(basicComp, root)
            const trig = p.trigger
            compare(p.open, false)
            compare(p.popup.visible, false)

            mouseClick(trig)
            tryCompare(p, "open", true)
            tryCompare(p.popup, "visible", true)
            p.open = false
            tryCompare(p.popup, "visible", false)
        }

        // 打开后再点触发项：必须干净关闭（open=false 且弹层不可见）。
        // 回归点：Popup 的 CloseOnPressOutside 会先复位 open，按钮 toggle 又翻一次 ——
        // 两者叠加时容易「点了但没关」或「关了又开」。锁最终状态，不锁中间过程。
        function test_second_click_closes() {
            const p = createTemporaryObject(basicComp, root)
            mouseClick(p.trigger)
            tryCompare(p, "open", true)
            wait(150)

            mouseClick(p.trigger)
            wait(300)
            compare(p.open, false, "再次点击触发项应关闭")
            compare(p.popup.visible, false, "再次点击后弹层必须不可见")
        }

        function test_programmatic_open() {
            const p = createTemporaryObject(basicComp, root)
            p.open = true
            tryCompare(p.popup, "visible", true)
            p.open = false
            tryCompare(p.popup, "visible", false)
        }

        // ── 关闭路径 ──
        function test_press_outside_closes() {
            const p = createTemporaryObject(edgeComp, root)
            const trig = p.trigger
            trig.x = 300
            trig.y = 40
            p.open = true
            tryCompare(p.popup, "visible", true)

            mouseClick(root, 650, 470)   // 远离触发项和弹层的空白处
            tryCompare(p.popup, "visible", false)
            compare(p.open, false, "外部点击后 open 必须复位")
        }

        function test_escape_closes() {
            const p = createTemporaryObject(edgeComp, root)
            p.open = true
            tryCompare(p.popup, "visible", true)

            keyClick(Qt.Key_Escape)
            tryCompare(p.popup, "visible", false)
            compare(p.open, false, "Esc 后 open 必须复位")
        }

        // ── 定位（ShadcnPopupPosition 透传） ──
        function test_position_below_with_sideOffset() {
            const p = createTemporaryObject(edgeComp, root)
            const trig = p.trigger
            trig.x = 300
            trig.y = 40
            p.open = true
            tryCompare(p.popup, "visible", true)
            wait(150)

            compare(p.placement.resolvedSide, "bottom", "空间充足应保持 bottom")
            const trigBottom = trig.mapToItem(p.popup.parent, 0, trig.height).y
            compare(p.popup.y, trigBottom + 4, "sideOffset=4 必须真的生效")
            // align=center：面板水平中线对齐触发项水平中线
            const trigLeft = trig.mapToItem(p.popup.parent, 0, 0).x
            const expect = Math.round(trigLeft + (trig.width - p.content.width) / 2)
            verify(Math.abs(p.popup.x - expect) <= 1,
                   "align=center 期望 x=" + expect + " 实际 " + p.popup.x)
            p.open = false
        }

        // 贴底翻转：接上 ShadcnPopupPosition 就免费送，这里锁「真的接上了」
        function test_flip_when_no_space_below() {
            const p = createTemporaryObject(edgeComp, root)
            const trig = p.trigger
            trig.x = 300
            trig.y = root.height - 36    // 下方只剩 ~4px 空间
            p.open = true
            tryCompare(p.popup, "visible", true)
            wait(150)

            compare(p.placement.resolvedSide, "top", "贴底必须翻到上方")
            verify(p.popup.y + p.popup.height <= trig.y + 1,
                   "翻转后弹层应在触发项上方，y=" + p.popup.y)
            verify(p.popup.y >= 0, "不得越出顶边")
            p.open = false
        }

        // 四个定位参数挂在 Content 上（registry 就这么设计），根组件读走透传
        function test_side_and_align_passthrough() {
            const p = createTemporaryObject(edgeComp, root)
            const trig = p.trigger
            trig.x = 300
            trig.y = 200
            p.content.side = "top"
            p.content.align = "end"
            p.content.alignOffset = 20
            p.content.sideOffset = 12

            p.open = true
            tryCompare(p.popup, "visible", true)
            wait(150)

            compare(p.placement.side, "top", "Content.side 应透传到定位器")
            compare(p.placement.align, "end", "Content.align 应透传到定位器")
            compare(p.placement.sideOffset, 12, "Content.sideOffset 应透传到定位器")
            compare(p.placement.resolvedSide, "top")
            const trigTop = trig.mapToItem(p.popup.parent, 0, 0).y
            verify(Math.abs(p.popup.y + p.popup.height - (trigTop - 12)) <= 1,
                   "side=top 应贴在触发项上方 12px，y=" + p.popup.y)
            // align=end：右缘对齐触发项右缘，alignOffset 再往右推 20
            const trigRightX = trig.mapToItem(p.popup.parent, trig.width, 0).x
            const expectX = trigRightX - p.content.width + 20
            verify(Math.abs(p.popup.x - expectX) <= 1,
                   "align=end + alignOffset=20 期望 x=" + expectX + " 实际 " + p.popup.x)
            p.open = false
        }

        // ── overlay 可见性门（截图串页回归） ──
        function test_hidden_host_hides_popup() {
            const host = createTemporaryObject(hiddenHostComp, root)
            verify(!!host, "host created")
            const p = findChild(host, "popover")
            verify(!!p, "popover in host")

            host.visible = false
            p.open = true
            wait(120)
            verify(!p.popup.visible,
                   "宿主不可见时弹层不得显示（Popup 在 overlay 层不受父项 visible 约束）")

            host.visible = true
            tryCompare(p.popup, "visible", true)
            p.open = false
            host.visible = false
        }

        // ── 过渡：必须走公共淡入缩放件 ──
        function test_enter_has_fade_transition() {
            const p = createTemporaryObject(basicComp, root)
            p.open = true
            // 逐帧采样：窗口内出现过严格中间值即证明在插值（对启动延迟免疫，
            // 采样策略同 tst_ShadcnFadeZoomTransition 的定版）
            let sawIntermediate = false
            for (let i = 0; i < 60; ++i) {
                wait(5)
                const v = p.popup.opacity
                if (v > 0.001 && v < 0.999) {
                    sawIntermediate = true
                    break
                }
            }
            verify(sawIntermediate, "弹层没有 fade 过渡（enter 未接 ShadcnFadeZoomTransition）")
            tryCompare(p.popup, "opacity", 1.0)
            p.open = false
        }

        // 时长必须走 durationInstant token 且经 motionDuration 折算。
        // reducedMotion 是**调用方接线**的公开属性（QtShadcnTheme 每组件一个实例、
        // 跨实例不共享），所以这里翻组件自己的 reducedMotion，而不是某个 theme 实例。
        function test_duration_goes_through_motion_token() {
            const p = createTemporaryObject(basicComp, root)
            compare(p.transitionDurationMs, theme.durationInstant,
                    "弹层时长必须是 durationInstant token")

            p.reducedMotion = true
            compare(p.transitionDurationMs, 0, "reducedMotion 打开后时长必须归零")
        }
    }
}
