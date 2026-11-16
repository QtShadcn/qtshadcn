import QtQuick
import QtTest
import QtShadcn

// ShadcnSkeleton：圆角来自 Rectangle 基类属性
// 回归锁定：曾声明 `property int radius: 4` 覆盖基类属性，导致
// 「radius: 20 画圆形」静默失效（qmllint property-override 抓出）。
Item {
    id: root
    width: 400
    height: 300

    Component {
        id: skeletonComp
        ShadcnSkeleton {
            width: 40
            height: 40
        }
    }

    TestCase {
        name: "ShadcnSkeleton"
        when: windowShown

        function test_default_radius() {
            const item = createTemporaryObject(skeletonComp, root)
            verify(!!item, "Component exists")
            compare(item.radius, 4)
        }

        function test_radius_is_effective() {
            const item = createTemporaryObject(skeletonComp, root, { radius: 20 })
            verify(!!item, "Component exists")
            compare(item.radius, 20)
        }
    }
}
