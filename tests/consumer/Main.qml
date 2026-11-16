import QtQuick
import QtShadcn

// 消费方冒烟页：只 import QtShadcn，不设任何 QML_IMPORT_PATH
// 能实例化出 ShadcnButton，就说明 QML 模块随库链接即可用
Window {
    width: 480
    height: 240
    visible: true

    ShadcnCard {
        anchors.centerIn: parent
        width: 300
        height: 160

        ShadcnCardHeader {
            ShadcnCardTitle { text: "Consumer OK" }
        }
        ShadcnCardContent {
            ShadcnButton {
                objectName: "btn"
                text: "Deploy"
                variant: ShadcnButton.Variant.Primary
            }
        }
    }
}
