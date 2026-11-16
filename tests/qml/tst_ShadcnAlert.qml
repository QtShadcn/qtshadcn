import QtQuick
import QtTest
import QtShadcn

// ShadcnAlert：variant 决定底色/描边/前景，内容决定隐式尺寸
Item {
    id: root
    width: 600
    height: 400

    QtShadcnTheme { id: theme }

    Component {
        id: alertComp
        ShadcnAlert {
            width: 320
            title: qsTr("提示")
            description: qsTr("操作已成功完成")
        }
    }

    TestCase {
        name: "ShadcnAlert"
        when: windowShown

        // 默认：muted 底 + border 描边
        function test_default_variant_colors() {
            const alert = createTemporaryObject(alertComp, root)
            verify(!!alert, "Component exists")
            compare(alert.color.toString(), theme.muted.toString())
            compare(alert.border.color.toString(), theme.border.toString())
        }

        // destructive：10% 红底 + 30% 红描边
        function test_destructive_variant_is_translucent_red() {
            const alert = createTemporaryObject(alertComp, root, {
                variant: ShadcnAlert.Variant.Destructive
            })
            verify(!!alert, "Component exists")

            const bg = alert.color
            verify(Math.abs(bg.a - 0.1) < 0.01)
            verify(bg.r > 0.5)

            const border = alert.border.color
            verify(Math.abs(border.a - 0.3) < 0.01)
        }

        // warning / success 走各自 token
        function test_warning_and_success_use_tokens() {
            const warning = createTemporaryObject(alertComp, root, {
                variant: ShadcnAlert.Variant.Warning
            })
            verify(!!warning, "Component exists")
            compare(warning.color.r.toFixed(3), theme.warning.r.toFixed(3))
            verify(Math.abs(warning.color.a - 0.1) < 0.01)

            const success = createTemporaryObject(alertComp, root, {
                variant: ShadcnAlert.Variant.Success
            })
            verify(!!success, "Component exists")
            compare(success.color.r.toFixed(3), theme.success.r.toFixed(3))
        }

        // 有标题+描述时高度大于纯内边距，宽度按内容撑开
        function test_implicit_size_follows_content() {
            const alert = createTemporaryObject(alertComp, root)
            verify(!!alert, "Component exists")
            tryVerify(function() { return alert.implicitHeight > 24 })
            verify(alert.implicitWidth > 24)

            const empty = createTemporaryObject(alertComp, root, {
                title: "",
                description: ""
            })
            verify(!!empty, "Component exists")
            tryVerify(function() { return empty.implicitHeight < alert.implicitHeight })
        }
    }
}
