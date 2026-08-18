import QtQuick
import QtQuick.Layouts
import QtShadcn

// Card 页：组合结构 / size / 完整卡片示例全展示
Column {
    id: root
    width: parent.width
    padding: 24
    spacing: theme.spacingLg

    QtShadcnTheme { id: theme }

    Text {
        text: qsTr("ShadcnCard")
        color: theme.foreground
        font.pixelSize: 20
        font.bold: true
    }

    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        text: qsTr("纯组合组件：Card = CardHeader / CardContent / CardFooter，对齐 shadcn/ui 组合方式。")
        color: theme.mutedForeground
        font.pixelSize: 13
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }

    // ── 基础结构 ──
    SectionTitle { text: qsTr("组合结构") }
    ShadcnCard {
        width: 420

        ShadcnCardHeader {
            ShadcnCardTitle { text: qsTr("Card Title") }
            ShadcnCardDescription { text: qsTr("Card Description — 描述文本，灰字。") }
        }
        ShadcnCardContent {
            Text {
                width: parent.width
                text: qsTr("Card Content — 内容区，可放任意业务内容。")
                color: theme.foreground
                font.pixelSize: 14
                wrapMode: Text.WordWrap
            }
        }
        ShadcnCardFooter {
            ShadcnButton { text: qsTr("取消"); variant: ShadcnButton.Variant.Outline; size: ShadcnButton.Size.Small }
            ShadcnButton { text: qsTr("确定"); size: ShadcnButton.Size.Small }
        }
    }

    // ── size=sm ──
    SectionTitle { text: qsTr("Size Small（内边距 16px）") }
    ShadcnCard {
        size: ShadcnCard.Size.Small
        width: 420

        ShadcnCardHeader {
            ShadcnCardTitle { text: qsTr("小号卡片") }
            ShadcnCardDescription { text: qsTr("size=\"sm\" 使用更紧凑的 spacing(4) 内边距。") }
        }
        ShadcnCardContent {
            ShadcnButton { text: qsTr("紧凑按钮"); size: ShadcnButton.Size.Small }
        }
    }

    // ── 仅 Header + Content ──
    SectionTitle { text: qsTr("任意组合（Header + Content）") }
    ShadcnCard {
        width: 420

        ShadcnCardHeader {
            ShadcnCardTitle { text: qsTr("只读信息") }
            ShadcnCardDescription { text: qsTr("无 Footer 的纯展示卡片。") }
        }
        ShadcnCardContent {
            Row {
                spacing: theme.spacingMd
                Column {
                    spacing: 4
                    Text { text: qsTr("条目 A"); color: theme.mutedForeground; font.pixelSize: 13 }
                    Text { text: qsTr("条目 B"); color: theme.mutedForeground; font.pixelSize: 13 }
                }
                Column {
                    spacing: 4
                    Text { text: qsTr("值 1"); color: theme.foreground; font.pixelSize: 13 }
                    Text { text: qsTr("值 2"); color: theme.foreground; font.pixelSize: 13 }
                }
            }
        }
    }

    SectionTitle { text: qsTr("QML 用法") }
    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
        font.pixelSize: 12
        color: theme.mutedForeground
        text: "ShadcnCard {\n    ShadcnCardHeader {\n        ShadcnCardTitle { text: \"标题\" }\n        ShadcnCardDescription { text: \"描述\" }\n    }\n    ShadcnCardContent { ... }\n    ShadcnCardFooter { ... }\n}"
    }
}
