import QtQuick
import QtQuick.Layouts
import QtShadcn

// 用户信息卡片：头像(ShadcnAvatar + status 覆盖层) + 名称 + 在线/离线文字 + 会员标签
ShadcnCard {
    id: card

    QtShadcnTheme { id: theme }

    property string userName: "Ryan"
    property bool online: true

    ShadcnCardContent {
        RowLayout {
            spacing: theme.spacingMd

            // 头像：使用 QtShadcn 库的 ShadcnAvatar
            // 右下角状态小圆点由 Avatar 的 status 属性直接提供
            ShadcnAvatar {
                id: avatar
                size: ShadcnAvatar.Size.Medium
                text: card.userName
                status: card.online ? ShadcnStatusDot.Status.Online : ShadcnStatusDot.Status.Offline
                bgColor: theme.primary
                textColor: theme.primaryForeground
            }

            // 名称 + 在线/离线说明
            ColumnLayout {
                spacing: 2

                Text {
                    text: card.userName
                    color: theme.foreground
                    font.pixelSize: 15
                    font.bold: true
                }

                Text {
                    text: card.online ? qsTr("在线") : qsTr("离线")
                    color: theme.mutedForeground
                    font.pixelSize: 12
                }
            }

            Item { Layout.fillWidth: true }

            // 会员标签
            ShadcnBadge {
                text: "Pro"
                variant: ShadcnBadge.Variant.Secondary
            }
        }
    }
}
