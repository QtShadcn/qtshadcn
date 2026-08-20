import QtQuick
import QtShadcn

// 状态圆点：用户/服务/任务的健康状态指示器
//
// 用法：
//   ShadcnStatusDot {
//       status: ShadcnStatusDot.Status.Online
//       size: 8
//       border: true   // 叠放在彩色背景上时用，描边让圆点边缘清晰
//   }
Item {
    id: root

    enum Status { None, Online, Offline, Busy, Away, Success, Warning, Danger }

    property int status: ShadcnStatusDot.Status.Offline
    property int size: 8
    property bool border: false

    QtShadcnTheme { id: theme }

    // 语义色表（与 Tailwind 官方值一致，light/dark 下对比度都 ≥ AA；
    // Offline/Busy/Away 直接走 theme.mutedForeground 天然适配主题）。
    // 将来 theme 补 success/warning/danger token 时，这里替换成 theme 语义色即可，API 不变。
    readonly property color _c:
        status === ShadcnStatusDot.Status.Online || status === ShadcnStatusDot.Status.Success
            ? "#22c55e"
        : status === ShadcnStatusDot.Status.Warning
          || status === ShadcnStatusDot.Status.Away
          || status === ShadcnStatusDot.Status.Busy
            ? "#f59e0b"
        : status === ShadcnStatusDot.Status.Danger
            ? "#ef4444"
        : status === ShadcnStatusDot.Status.Offline
            ? theme.mutedForeground
        : "transparent" // None

    implicitWidth: size
    implicitHeight: size
    visible: status !== ShadcnStatusDot.Status.None

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root._c
        border.width: root.border ? 1 : 0
        border.color: theme.card   // 描边色用卡片底色（Avatar/卡片底一致），而不是固定白
    }
}
