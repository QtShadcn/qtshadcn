import QtQuick
import QtTest
import QtShadcn

// ShadcnBadge：6 个 variant 的底色 / 前景 / 描边契约
//
// 回归锁定：destructive 是 v4 风格「10% 透明红底 + 红字」，
// 曾是实心红底；浅色背景曾因 QVariant 中转取不到 .r/.g/.b 变成黑色。
Item {
    id: root
    width: 500
    height: 400

    QtShadcnTheme { id: theme }

    Component {
        id: badgeComp
        ShadcnBadge {
            text: qsTr("New")
        }
    }

    TestCase {
        name: "ShadcnBadge"
        when: windowShown

        function badgeBackground(badge) {
            const bg = findChild(badge, "badgeBackground")
            verify(!!bg, "Object exists")
            return bg
        }

        function test_implicit_size() {
            const badge = createTemporaryObject(badgeComp, root)
            verify(!!badge, "Component exists")
            compare(badge.implicitHeight, 20)

            const label = findChild(badge, "badgeText")
            verify(!!label, "Object exists")
            verify(Math.abs(badge.implicitWidth - (label.implicitWidth + 16)) <= 1)
        }

        function test_default_variant_color() {
            const badge = createTemporaryObject(badgeComp, root)
            verify(!!badge, "Component exists")

            const bg = badgeBackground(badge)
            compare(bg.color.toString(), theme.primary.toString())

            const label = findChild(badge, "badgeText")
            compare(label.color.toString(), theme.primaryForeground.toString())
        }

        function test_secondary_variant_color() {
            const badge = createTemporaryObject(badgeComp, root, {
                variant: ShadcnBadge.Variant.Secondary
            })
            verify(!!badge, "Component exists")
            compare(badgeBackground(badge).color.toString(), theme.secondary.toString())
        }

        // destructive：半透明红底（不是实心红），文字用 destructive 色
        function test_destructive_variant_is_translucent_red() {
            const badge = createTemporaryObject(badgeComp, root, {
                variant: ShadcnBadge.Variant.Destructive
            })
            verify(!!badge, "Component exists")

            const bg = badgeBackground(badge).color
            verify(Math.abs(bg.a - 0.1) < 0.01)
            verify(bg.r > 0.5)
            verify(bg.g < 0.3)

            const label = findChild(badge, "badgeText")
            compare(label.color.toString(), theme.destructive.toString())
        }

        // outline：无底色 + 1px 描边
        function test_outline_variant_has_border() {
            const badge = createTemporaryObject(badgeComp, root, {
                variant: ShadcnBadge.Variant.Outline
            })
            verify(!!badge, "Component exists")

            const bg = badgeBackground(badge)
            compare(bg.border.width, 1)
            compare(bg.color.toString(), "#00000000")
            compare(bg.border.color.toString(), theme.border.toString())
        }

        // ghost：无底色也无描边
        function test_ghost_variant_is_flat() {
            const badge = createTemporaryObject(badgeComp, root, {
                variant: ShadcnBadge.Variant.Ghost
            })
            verify(!!badge, "Component exists")

            const bg = badgeBackground(badge)
            compare(bg.border.width, 0)
            compare(bg.color.toString(), "#00000000")
        }
    }
}
