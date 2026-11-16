pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtShadcn
import QtTest

// ShadcnScrollArea：内容尺寸推导 + 滚动条策略透传
//
// 内部是 ScrollView，它对**单个内容根**才会用该根的 implicitWidth/Height
// 推导 contentWidth/Height；多个并列子项时推导不出，滚动范围退化为 0。
// 这个行为容易被误认为封装缺陷，所以用用例明确锁住「单根能滚」这件事。
Item {
    id: root
    width: 500
    height: 500

    // 30 行 × 20px = 600 > 视口 100 → 必须出现竖条
    Component {
        id: tallComp
        ShadcnScrollArea {
            width: 200
            height: 100
            Column {
                width: 200
                Repeater {
                    model: 30
                    Rectangle {
                        width: 200
                        height: 20
                        color: "#cccccc"
                    }
                }
            }
        }
    }

    // 单行 20px < 视口 100 → AsNeeded 下竖条不出现
    Component {
        id: shortComp
        ShadcnScrollArea {
            width: 200
            height: 100
            Column {
                width: 200
                Rectangle {
                    width: 200
                    height: 20
                    color: "#cccccc"
                }
            }
        }
    }

    TestCase {
        name: "ShadcnScrollArea"
        when: windowShown

        // 单内容根时 contentHeight 由根的 implicitHeight 推导
        function test_content_height_from_single_root() {
            const area = createTemporaryObject(tallComp, root)
            verify(!!area, "ScrollArea exists")
            tryCompare(area, "contentHeight", 600)
        }

        // 内容溢出 → thumb 可见（断言 thumb 而非 bar，理由见 tst_ShadcnScrollBar）
        function test_shows_vertical_bar_on_overflow() {
            const area = createTemporaryObject(tallComp, root)
            const bar = findChild(area, "verticalBar")
            verify(!!bar, "vertical bar exists")
            tryVerify(function() { return bar.size < 1.0 }, 3000, "thumb shorter than track")
            const thumb = findChild(bar, "thumb")
            verify(!!thumb, "thumb exists")
            compare(thumb.visible, true, "thumb visible on overflow")
        }

        // 内容放得下 → thumb 隐藏
        function test_hides_vertical_bar_when_fits() {
            const area = createTemporaryObject(shortComp, root)
            const bar = findChild(area, "verticalBar")
            verify(!!bar, "vertical bar exists")
            tryCompare(bar, "size", 1.0)
            const thumb = findChild(bar, "thumb")
            verify(!!thumb, "thumb exists")
            compare(thumb.visible, false, "thumb hidden when content fits")
        }

        // verticalPolicy 透传到内部 ScrollBar：AlwaysOff 时控件本身不可见
        function test_vertical_policy_passthrough() {
            const area = createTemporaryObject(tallComp, root,
                                               { verticalPolicy: ScrollBar.AlwaysOff })
            const bar = findChild(area, "verticalBar")
            verify(!!bar, "vertical bar exists")
            tryCompare(bar, "visible", false)
        }

        // AlwaysOn：内容**放得下**时也要显示 thumb，否则 AlwaysOn 退化成 AsNeeded
        function test_policy_always_on_forces_thumb_when_fits() {
            const area = createTemporaryObject(shortComp, root,
                                               { verticalPolicy: ScrollBar.AlwaysOn })
            const bar = findChild(area, "verticalBar")
            verify(!!bar, "vertical bar exists")
            tryCompare(area, "contentHeight", 20)   // 内容没溢出
            tryCompare(bar, "visible", true)
            const thumb = findChild(bar, "thumb")
            tryCompare(thumb, "visible", true)
        }

        // 滚动位置可改变（内容确实能滚，不是只有条）
        function test_scroll_changes_position() {
            const area = createTemporaryObject(tallComp, root)
            const bar = findChild(area, "verticalBar")
            verify(!!bar, "vertical bar exists")
            tryCompare(area, "contentHeight", 600)

            area.contentY = 200
            tryCompare(area, "contentY", 200)
            compare(bar.position > 0, true, "thumb moved down")
        }

        // 横向溢出时水平条出现
        function test_horizontal_bar_on_overflow() {
            const comp = Qt.createQmlObject(
                "import QtQuick\n" +
                "import QtShadcn\n" +
                "ShadcnScrollArea {\n" +
                "    width: 100; height: 100\n" +
                "    Column {\n" +
                "        Rectangle { width: 400; height: 20; color: '#ccc' }\n" +
                "    }\n" +
                "}\n", root, "wideArea")
            verify(!!comp, "wide ScrollArea exists")
            const bar = findChild(comp, "horizontalBar")
            verify(!!bar, "horizontal bar exists")
            tryVerify(function() { return bar.size < 1.0 }, 3000, "horizontal thumb shorter than track")
            const thumb = findChild(bar, "thumb")
            verify(!!thumb, "thumb exists")
            compare(thumb.visible, true, "horizontal thumb visible")
        }
    }
}
