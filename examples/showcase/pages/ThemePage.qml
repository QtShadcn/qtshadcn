import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// Theme 页：Design Token 色板 + 明暗说明
Item {
    id: root

    QtShadcnTheme {
        id: theme
    }

    // 标题区（固定，不随内容滚动）
    Column {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24

        spacing: theme.spacingLg

        Text {
            text: qsTr("Theme — Design Tokens")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("语义化 token 由 C++ ThemeManager 持有，QML 声明式绑定。切换明暗（右上角 ☾/☀）或主题色（色块）时，下方色板与所有组件全局随动。")
            color: theme.mutedForeground
            font.pixelSize: 13
        }
    }

    // 内容区（放不下才滚）：anchors 占满标题区以下剩余空间
    // 注：height: parent.height - y 会因 y 自引用形成绑定循环（高度塌缩 implicitHeight）
    ScrollView {
        id: sv

        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 24
        anchors.rightMargin: 24

        clip: true

        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        Column {
            width: sv.availableWidth
            spacing: theme.spacingLg

            // 色板：色块 + token 名 + 当前值
            Repeater {
                model: ["background", "foreground", "primary", "primaryForeground", "secondary", "secondaryForeground", "muted", "mutedForeground", "accent", "accentForeground", "destructive", "destructiveForeground", "border", "ring"]

                delegate: RowLayout {
                    required property var modelData
                    spacing: theme.spacingMd

                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 24
                        radius: theme.radius / 2
                        border.width: 1
                        border.color: theme.tokens["border"]
                        color: theme.tokens[modelData]
                    }

                    Text {
                        Layout.preferredWidth: 180
                        verticalAlignment: Text.AlignVCenter
                        text: modelData
                        color: theme.foreground
                        font.pixelSize: 13
                    }

                    Text {
                        Layout.preferredWidth: 90
                        verticalAlignment: Text.AlignVCenter
                        text: theme.tokens[modelData]
                        color: theme.mutedForeground
                        font.pixelSize: 13
                    }
                }
            }

            Text {
                text: qsTr("形状与间距：radius = %1，spacing xs/sm/md/lg/xl = %2/%3/%4/%5/%6").arg(theme.radius).arg(theme.spacingXs).arg(theme.spacingSm).arg(theme.spacingMd).arg(theme.spacingLg).arg(theme.spacingXl)
                color: theme.mutedForeground
                font.pixelSize: 13
            }
        }
    }
}
