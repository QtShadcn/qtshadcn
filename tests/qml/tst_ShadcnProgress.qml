import QtQuick
import QtTest
import QtShadcn

// ShadcnProgress：value → 已填充宽度
Item {
    id: root
    width: 500
    height: 300

    QtShadcnTheme { id: theme }

    Component {
        id: progressComp
        ShadcnProgress {
            width: 200
            height: 12
        }
    }

    TestCase {
        name: "ShadcnProgress"
        when: windowShown

        function indicatorOf(bar) {
            const indicator = findChild(bar, "progressIndicator")
            verify(!!indicator, "Object exists")
            return indicator
        }

        function test_half_value_fills_half_width() {
            const bar = createTemporaryObject(progressComp, root, { value: 0.5 })
            verify(!!bar, "Component exists")
            compare(bar.value, 0.5)

            const indicator = indicatorOf(bar)
            tryVerify(function() {
                return Math.abs(indicator.width - bar.contentItem.width * 0.5) <= 2
            })
        }

        function test_zero_and_full() {
            const empty = createTemporaryObject(progressComp, root, { value: 0 })
            verify(!!empty, "Component exists")
            tryVerify(function() { return indicatorOf(empty).width <= 1 })

            const full = createTemporaryObject(progressComp, root, { value: 1 })
            verify(!!full, "Component exists")
            tryVerify(function() {
                return Math.abs(indicatorOf(full).width - full.contentItem.width) <= 2
            })
        }

        // 轨道与填充色走 token
        function test_track_and_fill_colors() {
            const bar = createTemporaryObject(progressComp, root, { value: 0.3 })
            verify(!!bar, "Component exists")
            compare(indicatorOf(bar).color.toString(), theme.primary.toString())
            compare(bar.background.color.toString(), theme.muted.toString())
        }
    }
}
