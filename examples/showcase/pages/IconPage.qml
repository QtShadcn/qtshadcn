import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// Icon 页：lucide 图标集展示（C++ IconRegistry + QML ShadcnIcon）
// 展示全部已注册图标 + 尺寸切换 + 颜色/主题变色（dark/light 随动）
Item {
    id: root

    QtShadcnTheme {
        id: theme
    }

    // 当前演示尺寸 / 颜色
    property int iconSize: 24
    property color iconColor: theme.foreground

    // 标题区（固定）
    Column {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        anchors.topMargin: 40

        spacing: theme.spacingLg

        Text {
            text: qsTr("ShadcnIcon")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        // 文档站跳转链接
        Text {
            text: qsTr("查看文档 ›")
            color: theme.primary
            font.pixelSize: 12
            font.underline: iconDocHover.containsMouse
            MouseArea {
                id: iconDocHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Qt.openUrlExternally("https://qtshadcn.ryanuo.cc/components/icon")
            }
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("C++ IconRegistry 加载 lucide svg（image://icons/<name>?color=...），currentColor 动态替换实现随主题变色。当前注册 %1 个图标。").arg(IconRegistry.names.length)
            color: theme.mutedForeground
            font.pixelSize: 13
        }
    }

    // 内容区
    ScrollView {
        id: sv

        anchors.top: header.bottom
        anchors.topMargin: 20
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

            // ── 尺寸切换 ──
            SectionTitle {
                text: qsTr("Size")
            }
            Row {
                spacing: theme.spacingSm
                Repeater {
                    model: [16, 24, 32, 48]
                    delegate: ShadcnButton {
                        required property int modelData
                        text: modelData.toString()
                        size: ShadcnButton.Size.Small
                        variant: root.iconSize === modelData
                                 ? ShadcnButton.Variant.Primary : ShadcnButton.Variant.Outline
                        onClicked: root.iconSize = modelData
                    }
                }
                ShadcnIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "sun"
                    size: root.iconSize
                    color: root.iconColor
                }
            }

            // ── 颜色演示（随主题变色）──
            SectionTitle {
                text: qsTr("Color（dark/light 随动）")
            }
            Row {
                spacing: theme.spacingSm
                Repeater {
                    model: [
                        { label: "foreground", color: theme.foreground },
                        { label: "primary", color: theme.primary },
                        { label: "mutedForeground", color: theme.mutedForeground },
                        { label: "destructive", color: theme.destructive },
                        { label: "accent", color: theme.accentForeground }
                    ]
                    delegate: ShadcnButton {
                        required property var modelData
                        text: modelData.label
                        size: ShadcnButton.Size.Small
                        variant: root.iconColor.toString() === modelData.color.toString()
                                 ? ShadcnButton.Variant.Primary : ShadcnButton.Variant.Outline
                        onClicked: root.iconColor = modelData.color
                    }
                }
            }
            Row {
                spacing: theme.spacingSm
                ShadcnIcon { name: "check"; size: root.iconSize; color: root.iconColor }
                ShadcnIcon { name: "star"; size: root.iconSize; color: root.iconColor }
                ShadcnIcon { name: "trash-2"; size: root.iconSize; color: root.iconColor }
                ShadcnIcon { name: "settings"; size: root.iconSize; color: root.iconColor }
                ShadcnIcon { name: "bell"; size: root.iconSize; color: root.iconColor }
            }

            // ── 全部图标网格 ──
            SectionTitle {
                text: qsTr("All Icons（%1）").arg(IconRegistry.names.length)
            }
            Flow {
                width: parent.width
                spacing: 12

                Repeater {
                    model: IconRegistry.names

                    delegate: Item {
                        required property string modelData

                        width: 88
                        height: 76

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            // 注意：不能加 Behavior on color + transparent↔muted 插值——
                            // transparent 是 RGBA(0,0,0,0)，与不透明色逐帧插值会经过半透明灰，
                            // hover 进出"闪灰"+ 动画期间重绘子项抖动。hover 应即时变色（shadcn 同）。
                            color: hoverArea.containsMouse ? theme.muted : "transparent"
                        }
                        Column {
                            anchors.centerIn: parent
                            spacing: 8
                            ShadcnIcon {
                                anchors.horizontalCenter: parent.horizontalCenter
                                name: modelData
                                size: 24
                                color: root.iconColor
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData
                                color: theme.mutedForeground
                                font.pixelSize: 10
                            }
                        }
                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    }
                }
            }
        }
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}
