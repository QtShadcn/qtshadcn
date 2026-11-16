import QtQuick
import QtTest
import QtShadcn

// ShadcnInput：高度、占位文本、聚焦描边、输入
Item {
    id: root
    width: 500
    height: 300

    QtShadcnTheme { id: theme }

    Component {
        id: inputComp
        ShadcnInput {
            width: 240
            placeholderText: qsTr("请输入")
        }
    }

    TestCase {
        name: "ShadcnInput"
        when: windowShown

        function test_defaults() {
            const input = createTemporaryObject(inputComp, root)
            verify(!!input, "Component exists")
            compare(input.implicitHeight, 36)
            compare(input.placeholderText, qsTr("请输入"))
            compare(input.placeholderTextColor.toString(), theme.mutedForeground.toString())
        }

        // 未聚焦：描边透明；聚焦后描边变 ring 色（focus 依赖，需显式设置）
        function test_focus_changes_border_color() {
            const input = createTemporaryObject(inputComp, root)
            verify(!!input, "Component exists")
            compare(input.background.border.color.toString(), "#00000000")

            input.focus = true
            tryVerify(function() {
                return input.background.border.color.toString() === theme.ring.toString()
            })
        }

        // 背景是 input 色 50% 透明
        function test_background_is_half_transparent_input() {
            const input = createTemporaryObject(inputComp, root)
            verify(!!input, "Component exists")

            const bg = input.background.color
            verify(Math.abs(bg.a - 0.5) < 0.01)
            compare(bg.r.toFixed(3), theme.input.r.toFixed(3))
            compare(bg.g.toFixed(3), theme.input.g.toFixed(3))
        }

        // 文本写入路径：走编辑 API（insert）而不是按键事件。
        // 离屏下 keyClick 不携带 text（实测 text 保持空），Qt 6.11 已移除 keyClicks，
        // 因此键盘输入本身在无窗口环境无法断言，这里覆盖的是文本编辑链路。
        function test_text_editing() {
            const input = createTemporaryObject(inputComp, root)
            verify(!!input, "Component exists")

            input.forceActiveFocus()
            tryVerify(function() { return input.activeFocus })

            input.insert(0, "abc")
            tryCompare(input, "text", "abc")
            compare(input.length, 3)

            input.remove(0, input.length)
            tryCompare(input, "text", "")
        }

        // 禁用态半透明
        function test_disabled_is_dimmed() {
            const input = createTemporaryObject(inputComp, root, { enabled: false })
            verify(!!input, "Component exists")
            compare(input.opacity, 0.5)
        }
    }
}
