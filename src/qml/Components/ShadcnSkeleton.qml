// src/qml/Components/ShadcnSkeleton.qml
import QtQuick
import QtShadcn

// shadcn/ui 风格骨架屏（M6）
// 用法:
//   ShadcnSkeleton { width: 200; height: 16 }
//   ShadcnSkeleton { width: 40; height: 40; radius: 20 }  // 圆形
Rectangle {
    id: root

    QtShadcnTheme { id: theme }

    color: theme.muted
    // 圆角来自 Rectangle 自带属性（不要再声明同名 property，会覆盖基类属性）
    radius: 4

    // 闪烁动画
    // 注：700ms 是「呼吸一次的周期」，属循环动画，不归 theme 的 duration* 管
    // （那几档是过渡时长，语义是「状态 A 到状态 B 用多久」）。同理见 Spinner 的旋转周期。
    SequentialAnimation on opacity {
        loops: Animation.Infinite
        running: true
        NumberAnimation { to: 0.5; duration: 700; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
    }
}
