import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui 风格进度条
// 基于 QQC.ProgressBar（Basic style），对齐 shadcn progress 规范：
// - track：h-3(12px) rounded-full bg-muted；indicator：bg-primary（transition 宽度动画）
// - 可选 value 百分比文本（shadcn ProgressValue）
//
// 用法:
//   ShadcnProgress { value: 0.6 }              // 0..1
//   ShadcnProgress { value: 0.4; showValue: true }
ProgressBar {
    id: root

    QtShadcnTheme { id: theme }

    implicitHeight: 12
    implicitWidth: 200

    // 是否在右侧显示百分比文本
    property bool showValue: false

    background: Rectangle {
        implicitHeight: 12
        radius: 6   // rounded-full
        color: theme.muted   // bg-muted
    }

    contentItem: Item {
        implicitHeight: 12

        // 已填充部分（bg-primary，宽度动画 = transition-all）
        Rectangle {
            width: root.visualPosition * parent.width
            height: 12
            radius: 6
            color: theme.primary

            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        // 百分比文本（shadcn ProgressValue，text-sm font-medium）
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showValue
            text: Math.round(root.value * 100) + "%"
            color: theme.primaryForeground
            font.pixelSize: 11
            font.bold: true
        }
    }
}
