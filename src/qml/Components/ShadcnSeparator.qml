// src/qml/Components/ShadcnSeparator.qml
import QtQuick
import QtShadcn

// shadcn/ui 风格分隔线（M6）
// 用法:
//   ShadcnSeparator {}                        // 水平分隔线
//   ShadcnSeparator { orientation: Qt.Vertical }  // 竖直分隔线
//   ShadcnSeparator { text: "或" }            // 带文字的水平分隔线
Item {
    id: root

    property int orientation: Qt.Horizontal
    property string text: ""

    QtShadcnTheme { id: theme }

    implicitWidth: orientation === Qt.Horizontal ? 100 : 1
    implicitHeight: orientation === Qt.Horizontal ? 1 : 100

    Rectangle {
        anchors.fill: parent
        color: theme.border
        visible: root.text === ""
    }

    // 带文字的分隔线
    Row {
        anchors.centerIn: parent
        visible: root.text !== ""
        spacing: 8

        Rectangle {
            width: 40
            height: 1
            anchors.verticalCenter: parent.verticalCenter
            color: theme.border
        }

        Text {
            text: root.text
            color: theme.mutedForeground
            font.pixelSize: 12
        }

        Rectangle {
            width: 40
            height: 1
            anchors.verticalCenter: parent.verticalCenter
            color: theme.border
        }
    }
}
