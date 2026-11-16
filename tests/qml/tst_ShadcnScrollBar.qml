pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtShadcn
import QtTest

// ShadcnScrollBar：样式 token 化 + attach 到滚动容器的行为
//
// 这个组件存在的原因是库里有三处各自附着**默认样式**的 ScrollBar
// （Textarea 的 Flickable、DialogContent 的 ScrollView、Table 的 TableView），
// 滚条样式散落各处，改一次得改三处。这里锁的是「样式确实来自 theme token」
// 与「几何符合 shadcn 的 w-2.5 + p-px」，不是锁 Qt 内部的布局算法。
Item {
    id: root
    width: 400
    height: 400

    QtShadcnTheme { id: theme }

    // 内容溢出（contentHeight 500 > 视口 100）
    Component {
        id: overflowComp
        Flickable {
            width: 100
            height: 100
            contentWidth: 100
            contentHeight: 500
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ShadcnScrollBar { objectName: "vbar" }
            ScrollBar.horizontal: ShadcnScrollBar {
                objectName: "hbar"
                orientation: Qt.Horizontal
                policy: ScrollBar.AlwaysOff
            }
        }
    }

    // 内容不溢出
    Component {
        id: fitsComp
        Flickable {
            width: 100
            height: 100
            contentWidth: 100
            contentHeight: 50
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ShadcnScrollBar { objectName: "vbar" }
        }
    }

    // 亚像素溢出：内容比视口多 0.4px（文本换行后的隐式高度常带小数）
    Component {
        id: subpixelComp
        Flickable {
            width: 100
            height: 100
            contentWidth: 100
            contentHeight: 100.4
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ShadcnScrollBar { objectName: "vbar" }
        }
    }

    // 真的溢出几像素（超过 1px 阈值）
    Component {
        id: slightComp
        Flickable {
            width: 100
            height: 100
            contentWidth: 100
            contentHeight: 104
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ShadcnScrollBar { objectName: "vbar" }
        }
    }

    // 横向溢出，用于测水平条的轴向几何
    Component {
        id: wideComp
        Flickable {
            width: 100
            height: 100
            contentWidth: 500
            contentHeight: 100
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.horizontal: ShadcnScrollBar {
                objectName: "hbar"
                orientation: Qt.Horizontal
            }
        }
    }

    TestCase {
        name: "ShadcnScrollBar"
        when: windowShown

        // 竖直条占宽 = shadcn w-2.5 = 10px
        function test_vertical_bar_width() {
            const f = createTemporaryObject(overflowComp, root)
            verify(!!f, "Flickable exists")
            const sb = findChild(f, "vbar")
            verify(!!sb, "vertical scrollbar exists")
            tryCompare(sb, "width", 10)
            compare(sb.vertical, true, "orientation is vertical")
        }

        // thumb 宽 8 = 轨道 10 − 两侧 p-px（1 + 1）
        function test_thumb_inset_by_padding() {
            const f = createTemporaryObject(overflowComp, root)
            const sb = findChild(f, "vbar")
            verify(!!sb, "vertical scrollbar exists")
            tryCompare(sb, "width", 10)
            const thumb = findChild(sb, "thumb")
            verify(!!thumb, "thumb Rectangle exists")
            tryCompare(thumb, "width", 8)
        }

        // thumb 颜色来自 theme.border（shadcn: bg-border），不是硬编码灰
        function test_thumb_color_from_token() {
            const f = createTemporaryObject(overflowComp, root)
            const sb = findChild(f, "vbar")
            const thumb = findChild(sb, "thumb")
            verify(!!thumb, "thumb Rectangle exists")
            compare(thumb.color.toString(), theme.border.toString())
        }

        // 全圆角 rounded-full = 短边一半
        function test_thumb_fully_rounded() {
            const f = createTemporaryObject(overflowComp, root)
            const sb = findChild(f, "vbar")
            const thumb = findChild(sb, "thumb")
            tryCompare(thumb, "width", 8)
            compare(thumb.radius, thumb.width / 2)
        }

        // AsNeeded：内容放得下时 thumb 隐藏
        //
        // 注意断言的是 thumb.visible 而不是 bar.visible —— 实测 Qt 默认
        // ScrollBar 在 AsNeeded + size=1 时 bar.visible 依然是 true，
        // 「隐藏」是靠 contentItem 的 visible: size < 1.0 实现的。
        // 断错对象会得到一个永远为真的假绿。
        function test_as_needed_hides_thumb_when_fits() {
            const f = createTemporaryObject(fitsComp, root)
            const sb = findChild(f, "vbar")
            verify(!!sb, "vertical scrollbar exists")
            tryCompare(sb, "size", 1.0)
            const thumb = findChild(sb, "thumb")
            verify(!!thumb, "thumb Rectangle exists")
            compare(thumb.visible, false, "thumb hidden when content fits")
        }

        // AsNeeded：内容溢出时 thumb 显示，且短于轨道
        function test_as_needed_shows_thumb_when_overflow() {
            const f = createTemporaryObject(overflowComp, root)
            const sb = findChild(f, "vbar")
            verify(!!sb, "vertical scrollbar exists")
            tryVerify(function() { return sb.size < 1.0 }, 3000, "thumb shorter than track")
            const thumb = findChild(sb, "thumb")
            verify(!!thumb, "thumb Rectangle exists")
            compare(thumb.visible, true, "thumb visible on overflow")
        }

        // 亚像素溢出（0.4px）不该显示 thumb：
        // 曾经只看 size < 1.0，内容高度带小数时 size 会变成 0.996，
        // 结果「内容明明放得下」也画出一根几乎撑满全高的条——
        // 肉眼就是「右边一直有条竖线」。判定改成「溢出 > 1px」。
        function test_subpixel_overflow_hides_thumb() {
            const f = createTemporaryObject(subpixelComp, root)
            const sb = findChild(f, "vbar")
            verify(!!sb, "vertical scrollbar exists")
            tryCompare(sb, "height", 100)
            verify(sb.size < 1.0, "size 应略小于 1（正是误判的来源），实际 " + sb.size)
            const thumb = findChild(sb, "thumb")
            compare(thumb.visible, false, "0.4px 溢出不应显示 thumb")
        }

        // 真溢出几像素时仍然要显示
        function test_real_overflow_still_shows_thumb() {
            const f = createTemporaryObject(slightComp, root)
            const sb = findChild(f, "vbar")
            const thumb = findChild(sb, "thumb")
            tryCompare(sb, "height", 100)
            compare(thumb.visible, true, "4px 溢出应显示 thumb")
        }

        // 水平条换轴：轨道高 10、thumb 高 8
        function test_horizontal_bar_geometry() {
            const f = createTemporaryObject(wideComp, root)
            const sb = findChild(f, "hbar")
            verify(!!sb, "horizontal scrollbar exists")
            tryCompare(sb, "height", 10)
            compare(sb.vertical, false, "orientation is horizontal")
            const thumb = findChild(sb, "thumb")
            tryCompare(thumb, "height", 8)
        }
    }
}
