import QtQuick
import QtShadcn

// 总览页：项目简介 + 组件状态
Column {
    id: root
    width: parent.width
    padding: 24
    spacing: theme.spacingLg

    QtShadcnTheme { id: theme }

    Text {
        text: qsTr("QtShadcn — Showcase")
        color: theme.foreground
        font.pixelSize: 22
        font.bold: true
    }

    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        text: qsTr("Qt 6 / QML 可组合 UI 组件库，对齐 shadcn/ui 设计哲学：Design Token → Component → Composition → Theme。左侧菜单按组件浏览，右上角可切换主题色与明暗模式（全局生效）。")
        color: theme.mutedForeground
        font.pixelSize: 13
    }

    Text {
        text: qsTr("组件状态")
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }

    // 状态列表：名称 + 状态标签
    Repeater {
        model: [
            { name: "Theme（Design Token 系统）", status: "✅ M1 完成" },
            { name: "ShadcnButton", status: "✅ M2 完成" },
            { name: "ShadcnButtonGroup", status: "✅ M2 完成" },
            { name: "ShadcnToggle / ShadcnToggleGroup", status: "✅ M2 完成" },
            { name: "ShadcnSpinner", status: "✅ M2 完成" },
            { name: "Input / Card / Badge / Switch / Tabs / Dialog", status: "⏳ M3 计划" },
            { name: "Icon 系统 / Animations", status: "⏳ M4 计划" },
            { name: "Models / Table / WindowManager", status: "⏳ M5 计划" },
        ]

        delegate: Row {
            required property var modelData
            spacing: theme.spacingSm

            Text {
                width: 320
                text: modelData.name
                color: theme.foreground
                font.pixelSize: 13
            }
            Text {
                text: modelData.status
                color: theme.mutedForeground
                font.pixelSize: 13
            }
        }
    }
}
