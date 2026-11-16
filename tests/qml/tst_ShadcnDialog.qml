import QtQuick
import QtTest
import QtShadcn

// ShadcnDialog：对齐 shadcn v4 base 的规格锁
//
// 对齐依据（apps/v4/registry/styles/style-nova.css）：
//   .cn-dialog-content  { bg-popover ring-1 ring-foreground/10 gap-4 rounded-xl p-4
//                         max-w-[calc(100%-2rem)] sm:max-w-sm text-sm }
//   .cn-dialog-overlay  { bg-black/10 backdrop-blur-xs }   ← blur 未实现，仅压暗
//   .cn-dialog-footer   { bg-muted/50 -mx-4 -mb-4 rounded-b-xl border-t p-4 }
//   .cn-dialog-header   { gap-2 }
//   .cn-dialog-close    { absolute top-2 right-2; Button icon-sm = size-7(28) }
//
// 圆角从 14 直接写死改为 theme.radiusXl 派生、去掉 shadow-xl 改 ring、遮罩 50%→10%
// 这几处都是「肉眼看着差不多、实际已经偏了」的地方，用测试钉住，免得下次又漂回去。
Item {
    id: root
    width: 640
    height: 640

    QtShadcnTheme { id: theme }

    Component {
        id: withFooterComp
        ShadcnDialog {
            ShadcnDialogContent {
                ShadcnDialogHeader {
                    ShadcnDialogTitle { text: "标题" }
                    ShadcnDialogDescription { text: "描述" }
                }
                footer: ShadcnDialogFooter {
                    ShadcnButton { text: "确定" }
                }
            }
        }
    }

    Component {
        id: noFooterComp
        ShadcnDialog {
            ShadcnDialogContent {
                ShadcnDialogHeader {
                    ShadcnDialogTitle { text: "标题" }
                }
            }
        }
    }

    Component {
        id: headerComp
        ShadcnDialogHeader {
            ShadcnDialogTitle { text: "标题" }
            ShadcnDialogDescription { text: "描述" }
        }
    }

    // 40 行正文，用来撑出滚动
    Component {
        id: longBodyComp
        ShadcnDialog {
            ShadcnDialogContent {
                maxHeight: 200
                ShadcnDialogHeader { ShadcnDialogTitle { text: "长内容" } }
                Repeater {
                    model: 40
                    Text { text: "一行比较长的正文内容用于撑高"; font.pixelSize: 14 }
                }
            }
        }
    }

    // 正文高度带小数（文本换行后的隐式高度经常如此），用来锁「小数高度不能让
    // 滚动条误判为溢出」——这是「弹窗右侧总有一条竖线」的实际成因
    Component {
        id: fractionalComp
        ShadcnDialog {
            ShadcnDialogContent {
                ShadcnDialogHeader { ShadcnDialogTitle { text: "小数高度" } }
                Item {
                    width: 10
                    height: 51.4
                }
            }
        }
    }

    // contentItem 的第一个子项就是 ShadcnDialogContent（单子节点是有意设计：
    // 多子节点时 QQC.Popup 无法从 content.implicitHeight 推导高度）

    TestCase {
        name: "ShadcnDialogSpec"
        when: windowShown

        // 辅助函数必须写在 TestCase 内部：verify/fail 是 TestCase 的成员，
        // 放到外层 Item 上会 ReferenceError（verify is not defined）
        //
        // contentItem 的第一个子项就是 ShadcnDialogContent（单子节点是有意设计：
        // 多子节点时 QQC.Popup 无法从 content.implicitHeight 推导高度）
        function contentOf(dialog) {
            verify(dialog && dialog.contentItem, "dialog 创建失败")
            var c = dialog.contentItem.children[0]
            verify(c, "content 缺失")
            return c
        }

        // 递归按 objectName 找子项（关闭钮埋在三层 anchors 结构里）
        function findByName(item, name) {
            if (item.objectName === name)
                return item
            var kids = item.children || []
            for (var i = 0; i < kids.length; ++i) {
                var hit = findByName(kids[i], name)
                if (hit)
                    return hit
            }
            return null
        }

        function test_overlayOpacity() {
            // 对齐 bg-black/10；Qt Basic 默认遮罩是 50%，差 40 个百分点
            var dlg = createTemporaryObject(withFooterComp, root)
            compare(dlg.overlayOpacity, 0.10)

            // 值要真能透传到自绘遮罩，而不是写死常量
            dlg.overlayOpacity = 0.3
            compare(dlg.overlayOpacity, 0.3)
        }

        function test_backgroundRingAndRadius() {
            var dlg = createTemporaryObject(withFooterComp, root)
            var bg = dlg.background
            verify(bg, "background 缺失")

            // rounded-xl = --radius×1.4（shadcn v4 在 @theme 里重定义的刻度，不是
            // Tailwind 默认的 0.75rem=12）。这里断言「等于主题派生值」而不是写死
            // 数字：写死会让按钮（同样改成派生）与弹窗各自漂移。
            compare(bg.radius, theme.radiusXl)
            compare(bg.radius, Math.round(theme.radius * 1.4))

            // ring-1 ring-foreground/10：1px + 前景色 10%，light/dark 同一档
            compare(bg.border.width, 1)
            compare(Math.round(bg.border.color.a * 100), 10)

            // 新版用 ring 取代 shadow-xl，背景不再挂 layer + MultiEffect
            compare(bg.layer.enabled, false)
        }

        function test_headerGap() {
            var header = createTemporaryObject(headerComp, root)
            compare(header.spacing, 8)   // cn-dialog-header gap-2
        }

        function test_closeButtonFollowsProperty() {
            var dlg = createTemporaryObject(withFooterComp, root)
            var content = contentOf(dlg)
            var btn = findByName(content, "closeButton")
            verify(btn, "找不到 closeButton")

            compare(content.showCloseButton, true)   // showCloseButton 默认 true

            // 必须先 open 再断言 visible：Popup 未打开时 contentItem 整棵子树可见性为
            // false，读到的是「弹窗没显示」，无法区分「关闭钮被隐藏」。
            dlg.open()
            tryCompare(dlg, "visible", true)
            compare(btn.visible, true)

            // Dialog.showCloseButton 透传到 Content，并实际作用到关闭钮
            dlg.showCloseButton = false
            compare(content.showCloseButton, false)
            compare(btn.visible, false)

            // 关掉再打开要能恢复（binding 没被破坏）
            dlg.showCloseButton = true
            compare(btn.visible, true)

            dlg.close()
        }

        function test_contentFillsBackground() {
            var dlg = createTemporaryObject(withFooterComp, root)

            // T.Dialog 默认 padding=12 会把 contentItem 向内缩 12px，footer 的
            // muted 条四周出现空隙（看起来像对话框外面又套了一层 padding）。
            // padding 被改回 12 时，下面两条会同时挂掉。
            compare(dlg.padding, 0)
            compare(dlg.contentItem.x, 0)
            compare(dlg.contentItem.y, 0)
            compare(dlg.contentItem.width, dlg.background.width)
        }

        function test_closeButtonClosesDialog() {
            var dlg = createTemporaryObject(withFooterComp, root)
            var content = contentOf(dlg)
            var btn = findByName(content, "closeButton")

            // cn-dialog-close 用 Button icon-sm = size-7(28)，定位 absolute top-2 right-2
            compare(btn.width, 28)
            compare(btn.height, 28)
            compare(btn.x, content.width - 28 - 8)
            compare(btn.y, 8)

            dlg.open()
            tryCompare(dlg, "visible", true)

            mouseClick(btn)
            tryCompare(dlg, "visible", false)
        }

        function test_footerMakesDialogTaller() {
            var withFooter = contentOf(createTemporaryObject(withFooterComp, root))
            var noFooter = contentOf(createTemporaryObject(noFooterComp, root))
            verify(withFooter.implicitHeight > noFooter.implicitHeight,
                   "有 footer 的对话框应更高: " + withFooter.implicitHeight
                   + " vs " + noFooter.implicitHeight)
        }

        // bodyScroll 里的滚动条（ShadcnScrollBar 没有 objectName，按属性特征认）
        function scrollBarOf(flickable) {
            for (var i = 0; i < flickable.children.length; ++i) {
                var c = flickable.children[i]
                if (c.size !== undefined && c.policy !== undefined)
                    return c
            }
            return null
        }

        // 视口高度必须不小于 contentHeight，且 thumb 必须真的不显示。
        // 曾经的真实 bug：footerBar 的 1px bottomMargin 没算进 implicitHeight，
        // 于是视口比内容矮 1px，右侧贴着边框出现一条竖灰条。
        // 只看高度不够——thumb 的显示条件曾经基于 size < 1.0，小数高度会让
        // size 变成 0.998x 从而「内容放得下也显示」，所以这里断言 thumb 本身。
        function test_noScrollBarWhenContentFits() {
            var cases = [
                { name: "有 footer", comp: withFooterComp },
                { name: "无 footer", comp: noFooterComp },
                { name: "小数高度", comp: fractionalComp }
            ]
            for (var i = 0; i < cases.length; ++i) {
                var content = contentOf(createTemporaryObject(cases[i].comp, root))
                var fl = findByName(content, "bodyScroll")
                verify(fl, cases[i].name + ": 找不到 bodyScroll")
                verify(fl.height >= fl.contentHeight, cases[i].name + ": 视口高度不应小于内容高度: "
                       + fl.height + " < " + fl.contentHeight)
                var bar = scrollBarOf(fl)
                verify(bar, cases[i].name + ": 滚动条缺失")
                compare(bar.contentItem.visible, false,
                        cases[i].name + ": 内容放得下时 thumb 不应显示 (size=" + bar.size + ")")
            }
        }

        function test_scrollsWhenContentOverflows() {
            var content = contentOf(createTemporaryObject(longBodyComp, root))
            var fl = findByName(content, "bodyScroll")
            verify(fl.contentHeight > fl.height, "长内容应超出视口")
            var bar = scrollBarOf(fl)
            verify(bar, "滚动条缺失")
            verify(bar.size < 1, "内容溢出时 thumb 应按比例缩短，实际 size=" + bar.size)
        }
    }
}
