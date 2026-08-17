import QtQuick
import QtQuick.Window
import QtShadcn

// M1 验证载体：Design Token 色板页
// - 展示全部颜色语义 token
// - mode 切换按钮 → theme.mode = "dark"/"light" → 全局随动
Window {
    id: root
    width: 520
    height: 720
    visible: true
    title: "QtShadcn Showcase — Theme (M1)"

    QtShadcnTheme {
        id: theme
    }

    color: theme.background

    Column {
        anchors.centerIn: parent
        spacing: theme.spacingLg

        // 标题
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "QtShadcn — Design Tokens"
            color: theme.foreground
            font.pixelSize: 22
            font.bold: true
        }

        // 色板：每个语义 token 一块
        Repeater {
            model: ["background", "foreground", "primary", "primaryForeground",
                    "secondary", "secondaryForeground", "muted", "mutedForeground",
                    "accent", "accentForeground", "destructive", "destructiveForeground",
                    "border", "ring"]

            delegate: Row {
                spacing: theme.spacingMd

                Rectangle {
                    width: 48
                    height: 24
                    radius: theme.radius / 2
                    border.width: 1
                    border.color: theme.tokens["border"]
                    color: theme.tokens[modelData]
                }

                Text {
                    width: 180
                    verticalAlignment: Text.AlignVCenter
                    text: modelData
                    color: theme.foreground
                    font.pixelSize: 13
                }

                Text {
                    width: 90
                    verticalAlignment: Text.AlignVCenter
                    text: theme.tokens[modelData]
                    color: theme.mutedForeground
                    font.pixelSize: 13
                }
            }
        }

        // 形状与间距示例
        Row {
            spacing: theme.spacingLg

            // radius 演示：4 种圆角
            Row {
                spacing: theme.spacingSm
                Repeater {
                    model: [4, 8, 12, 16]
                    delegate: Rectangle {
                        width: 40
                        height: 40
                        radius: modelData
                        color: theme.secondary
                        border.width: 1
                        border.color: theme.border
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: theme.secondaryForeground
                            font.pixelSize: 11
                        }
                    }
                }
            }

            // spacing 演示：间距刻度
            Row {
                spacing: 2
                anchors.verticalCenter: parent.verticalCenter
                Repeater {
                    model: [4, 8, 12, 16, 24]
                    delegate: Rectangle {
                        width: modelData + 6
                        height: 40
                        color: theme.accent
                        radius: 2
                    }
                }
            }
        }

        // mode 切换按钮（token 自绘，M2 之前暂用原生交互）
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 140
            height: 36
            radius: theme.radius
            color: theme.primary

            Text {
                anchors.centerIn: parent
                text: theme.mode === "dark" ? "切换到 Light" : "切换到 Dark"
                color: theme.primaryForeground
                font.pixelSize: 13
            }

            MouseArea {
                anchors.fill: parent
                onClicked: theme.mode = theme.mode === "dark" ? "light" : "dark"
            }
        }
    }
}
