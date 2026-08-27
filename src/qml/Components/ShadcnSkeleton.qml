// src/qml/Components/ShadcnSkeleton.qml
import QtQuick
import QtShadcn

// shadcn/ui 风格骨架屏（M6）
// 用法:
//   ShadcnSkeleton { width: 200; height: 16 }
//   ShadcnSkeleton { width: 40; height: 40; radius: 20 }  // 圆形
Rectangle {
    id: root

    property int radius: 4

    QtShadcnTheme { id: theme }

    color: theme.muted

    // 闪烁动画
    SequentialAnimation on opacity {
        loops: Animation.Infinite
        running: true
        NumberAnimation { to: 0.5; duration: 700; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
    }
}
