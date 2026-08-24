import QtQuick
import QtQuick.Layouts
import QtShadcn

// 项目卡片：图标 + 名称 + 描述 + 状态 Badge
ShadcnCard {
    id: card

    QtShadcnTheme { id: theme }

    property string projectName: ""
    property string projectDescription: ""
    property string projectStatus: ""

    // 状态 → Badge variant 映射（status 是数据值，用字面量比较）
    function statusVariant() {
        if (projectStatus === "进行中")
            return ShadcnBadge.Variant.Default
        if (projectStatus === "已完成")
            return ShadcnBadge.Variant.Secondary
        if (projectStatus === "待开始")
            return ShadcnBadge.Variant.Outline
        return ShadcnBadge.Variant.Default
    }

    ShadcnCardContent {
        RowLayout {
            spacing: theme.spacingMd

            // 项目图标
            Rectangle {
                width: 36
                height: 36
                radius: theme.radius
                color: theme.muted

                ShadcnIcon {
                    anchors.centerIn: parent
                    name: "folder"
                    size: 16
                    color: theme.foreground
                }
            }

            // 名称 + 描述
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: card.projectName
                    color: theme.foreground
                    font.pixelSize: 14
                    font.bold: true
                }
                Text {
                    Layout.fillWidth: true
                    text: card.projectDescription
                    color: theme.mutedForeground
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }
            }

            // 状态 Badge
            ShadcnBadge {
                text: card.projectStatus
                variant: card.statusVariant()
            }
        }
    }
}
