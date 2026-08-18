import QtQuick
import QtQuick.Shapes

// 加载指示器：Shape 画 270° 弧线 + RotationAnimator（渲染线程动画）
// 规范：动画内容禁用 Canvas（JS 重绘在主线程），用 Shape
Item {
    id: root

    implicitWidth: 16
    implicitHeight: 16

    property color color: "#888888"

    Shape {
        id: shape
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            strokeColor: root.color
            strokeWidth: 2
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            startX: root.width / 2
            startY: 2

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.width / 2 - 2
                radiusY: root.height / 2 - 2
                startAngle: -90      // 顶部缺口
                sweepAngle: 270      // 270° 弧
            }
        }
    }

    // RotationAnimator：渲染线程动画，不走 QML 引擎每帧回传
    RotationAnimator {
        target: shape
        from: 0
        to: 360
        duration: 700
        loops: Animation.Infinite
        running: root.visible
    }
}
