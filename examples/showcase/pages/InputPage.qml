import QtQuick
import QtQuick.Layouts
import QtShadcn

// Input 页：基础 / 尺寸 / 状态 / 组合（结合 Card）
Column {
    id: root
    width: parent.width
    padding: 24
    spacing: theme.spacingLg

    QtShadcnTheme { id: theme }

    Text {
        text: qsTr("ShadcnInput")
        color: theme.foreground
        font.pixelSize: 20
        font.bold: true
    }

    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        text: qsTr("基于 QQC.TextField（Basic style）：h-9(36px) + 6px 圆角 + bg-input/50 + 聚焦 border-ring + 3px 焦点环。")
        color: theme.mutedForeground
        font.pixelSize: 13
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }

    // ── 基础 ──
    SectionTitle { text: qsTr("Basic") }
    ShadcnInput {
        width: 320
        placeholderText: qsTr("请输入用户名")
    }

    // ── Disabled ──
    SectionTitle { text: qsTr("Disabled") }
    ShadcnInput {
        width: 320
        enabled: false
        placeholderText: qsTr("禁用状态")
    }

    // ── 组合（Input 嵌入 Card）──
    SectionTitle { text: qsTr("Card + Input + Button 组合") }
    ShadcnCard {
        width: 420

        ShadcnCardHeader {
            ShadcnCardTitle { text: qsTr("登录") }
            ShadcnCardDescription { text: qsTr("输入账号密码后提交。") }
        }
        ShadcnCardContent {
            Column {
                width: parent.width
                spacing: theme.spacingSm
                ShadcnInput {
                    width: parent.width
                    placeholderText: qsTr("邮箱")
                }
                ShadcnInput {
                    width: parent.width
                    placeholderText: qsTr("密码")
                    echoMode: TextInput.Password
                }
            }
        }
        ShadcnCardFooter {
            ShadcnButton { text: qsTr("忘记密码"); variant: ShadcnButton.Variant.Link; size: ShadcnButton.Size.Small }
            Item { Layout.fillWidth: true }   // 占位推右
            ShadcnButton { text: qsTr("登录"); size: ShadcnButton.Size.Small }
        }
    }

    SectionTitle { text: qsTr("QML 用法") }
    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
        font.pixelSize: 12
        color: theme.mutedForeground
        text: "ShadcnInput {\n    placeholderText: \"请输入\"\n    echoMode: TextInput.Password\n    onAccepted: ...\n}"
    }
}
