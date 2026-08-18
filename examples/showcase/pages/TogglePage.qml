import QtQuick
import QtShadcn

// Toggle 页：切换按钮（outline + checkable）+ 多选/单选组
Column {
    id: root
    width: parent.width
    padding: 24
    spacing: theme.spacingLg

    QtShadcnTheme { id: theme }

    Text {
        text: qsTr("ShadcnToggle / ShadcnToggleGroup")
        color: theme.foreground
        font.pixelSize: 20
        font.bold: true
    }

    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        text: qsTr("ShadcnToggle = outline 样式 + checkable，选中时 accent 背景；ToggleGroup 默认多选，exclusive: true 单选。")
        color: theme.mutedForeground
        font.pixelSize: 13
    }

    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }

    SectionTitle { text: qsTr("单独切换") }
    Row {
        spacing: theme.spacingSm
        ShadcnToggle { text: qsTr("粗体") }
        ShadcnToggle { text: qsTr("斜体"); checked: true }
    }

    SectionTitle { text: qsTr("多选组") }
    ShadcnToggleGroup {
        ShadcnToggle { text: qsTr("左") }
        ShadcnToggle { text: qsTr("中"); checked: true }
        ShadcnToggle { text: qsTr("右") }
    }

    SectionTitle { text: qsTr("单选组（exclusive）") }
    ShadcnToggleGroup {
        exclusive: true
        ShadcnToggle { text: qsTr("单选 1"); checked: true }
        ShadcnToggle { text: qsTr("单选 2") }
        ShadcnToggle { text: qsTr("单选 3") }
    }

    SectionTitle { text: qsTr("QML 用法") }
    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
        font.pixelSize: 12
        color: theme.mutedForeground
        text: "ShadcnToggle { text: \"粗体\" }\n\nShadcnToggleGroup {\n    exclusive: true     // 单选\n    ShadcnToggle { text: \"单选 1\"; checked: true }\n}"
    }
}
