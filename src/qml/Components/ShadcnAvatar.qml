import QtQuick
import QtShadcn

// 圆形头像组件：首字母 / 图标 / 图片 三选一；右下角可选状态小圆点
//
// 用法：
//   ShadcnAvatar {
//       size: ShadcnAvatar.Size.Medium
//       text: "Ryan"
//       status: ShadcnStatusDot.Status.Online
//   }
//
//   ShadcnAvatar { iconName: "user" }
//   ShadcnAvatar { source: "file:/path/to/photo.png"; size: ShadcnAvatar.Size.Large }
Item {
    id: root

    enum Size { XSmall, Small, Medium, Large, XLarge }

    property int size: ShadcnAvatar.Size.Medium
    // 显示内容，按优先级：source > iconName > text（首字母）
    property url source: ""
    property string iconName: ""
    property string text: ""

    property color bgColor: theme.primary
    property color textColor: theme.primaryForeground
    property color iconColor: theme.primaryForeground

    property int status: ShadcnStatusDot.Status.None

    QtShadcnTheme { id: theme }

    // Size 枚举 → 像素直径
    readonly property int _diameter:
        size === ShadcnAvatar.Size.XSmall ? 24 :
        size === ShadcnAvatar.Size.Small  ? 32 :
        size === ShadcnAvatar.Size.Large  ? 56 :
        size === ShadcnAvatar.Size.XLarge ? 72 : 44   // Medium

    implicitWidth: _diameter
    implicitHeight: _diameter

    // 是否使用某种内容模式（source / icon / text 三选一）
    readonly property bool _useImage: root.source.toString().length > 0
    readonly property bool _useIcon:  !_useImage && root.iconName.length > 0

    // 视觉底：圆形填充（根是 Item 不 clip，方便 status 点越界）
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: width / 2
        color: root.bgColor
        clip: _useImage   // 只有图片模式需要 clip 保证圆形裁切

        // 模式一：图片
        Image {
            anchors.fill: parent
            visible: root._useImage
            source: root.source
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            sourceSize.width: parent.width * 2   // Retina 清晰
            sourceSize.height: parent.height * 2
        }

        // 模式二：图标（无图片时）
        ShadcnIcon {
            visible: root._useIcon
            anchors.centerIn: parent
            name: root.iconName
            size: Math.max(12, Math.round(root._diameter * 0.5))
            color: root.iconColor
        }

        // 模式三：首字母（无图片也无图标时）
        Text {
            visible: !root._useImage && !root._useIcon && root.text.length > 0
            anchors.centerIn: parent
            text: root.text.charAt(0).toUpperCase()
            color: root.textColor
            font.pixelSize: Math.max(12, Math.round(root._diameter * 0.5))
            font.weight: Font.Bold
        }
    }

    // 状态覆盖层：右下角，大小约为头像直径 ÷4，带 1px 描边贴合头像底
    ShadcnStatusDot {
        id: statusDot
        visible: root.status !== ShadcnStatusDot.Status.None
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: Math.max(0, -1)
        anchors.bottomMargin: Math.max(0, -1)
        status: root.status
        size: Math.max(6, Math.round(root._diameter / 4))
        border: true
    }
}
