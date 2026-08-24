import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// 电芯监控：16 串电压卡片 + 压差统计 + 温度状态
// 数据由 Main.qml 注入（单一来源）；本页只读
Item {
    id: root

    // 由 Main.qml 注入
    property var cells: null

    // 统计（从 cells 计算；函数式绑定，块表达式不能直接放属性绑定里）
    readonly property int minMv: computeMin()
    readonly property int maxMv: computeMax()
    readonly property int deltaMv: maxMv - minMv

    function computeMin() {
        if (!cells)
            return 0
        var m = 99999
        for (var i = 0; i < cells.count; ++i) m = Math.min(m, cells.get(i).mv)
        return m
    }

    function computeMax() {
        if (!cells)
            return 0
        var m = 0
        for (var i = 0; i < cells.count; ++i) m = Math.max(m, cells.get(i).mv)
        return m
    }

    // 单芯电压 → 进度条 0..1（3.0V~3.5V 映射）
    function norm(mv) {
        return Math.max(0, Math.min(1, (mv - 3000) / 500))
    }

    QtShadcnTheme {
        id: theme
    }

    // 标题区
    ColumnLayout {
        id: header

        anchors.left: parent.left
        anchors.margins: 24
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 40
        spacing: theme.spacingSm

        Text {
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
            text: qsTr("电芯监控")
        }
        Row {
            spacing: theme.spacingSm

            ShadcnBadge {
                text: root.deltaMv > 80 ? qsTr("压差超标") : qsTr("压差正常")
                variant: root.deltaMv > 80 ? ShadcnBadge.Variant.Destructive : ShadcnBadge.Variant.Secondary
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: theme.mutedForeground
                font.pixelSize: 12
                text: qsTr("最高 %1 mV · 最低 %2 mV · 压差 %3 mV").arg(root.maxMv).arg(root.minMv).arg(root.deltaMv)
            }
        }
    }

    // 内容区（放不下才滚）
    ScrollView {
        id: sv

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        anchors.topMargin: 20
        clip: true

        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        Column {
            width: sv.availableWidth
            spacing: theme.spacingLg

            // ── 16 串电芯卡片 ──
            Flow {
                width: parent.width
                spacing: 12

                Repeater {
                    model: root.cells

                    delegate: ShadcnCard {
                        id: cellCard

                        required property int no
                        required property int mv
                        required property int temp

                        // 压差超标电芯（= minMv 且压差 > 80）标红点
                        readonly property bool low: root.deltaMv > 80 && mv === root.minMv

                        width: 150

                        ShadcnCardContent {
                            Column {
                                spacing: 6

                                RowLayout {
                                    width: parent.width - 8

                                    Text {
                                        color: theme.mutedForeground
                                        font.pixelSize: 12
                                        text: qsTr("Cell #%1").arg(cellCard.no)
                                    }
                                    Item { Layout.fillWidth: true }
                                    ShadcnStatusDot {
                                        status: cellCard.low ? ShadcnStatusDot.Status.Danger
                                                : cellCard.temp >= 35 ? ShadcnStatusDot.Status.Warning
                                                : ShadcnStatusDot.Status.Success
                                        size: 8
                                    }
                                }
                                Text {
                                    color: theme.foreground
                                    font.bold: true
                                    font.pixelSize: 17
                                    text: (cellCard.mv / 1000).toFixed(3) + " V"
                                }
                                ShadcnProgress {
                                    width: parent.width - 8
                                    value: root.norm(cellCard.mv)
                                }
                                Text {
                                    color: theme.mutedForeground
                                    font.pixelSize: 11
                                    text: qsTr("%1 °C").arg(cellCard.temp)
                                }
                            }
                        }
                    }
                }
            }

            Item { height: 4 }
        }
    }
}
