import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtShadcn

// EOL 测试主页：电池包信息 + 测试项列表 + 一键自检流程（Timer 逐项跑）
// 状态机：idle → running(逐项) → done；结果 pass / fail
Item {
    id: root

    // 由 Main.qml 注入（电芯数据，用于压差统计展示）
    property var cells: null

    // 测试状态：idle / running / done
    property string testState: "idle"
    property int runIndex: -1          // 当前正在跑的测试项

    ListModel {
        id: itemsModel

        ListElement { name: "绝缘电阻";   spec: "≥ 100 MΩ @ 500V";  result: ""; detail: "" }
        ListElement { name: "CAN 通讯";   spec: "500 kbps 唤醒应答"; result: ""; detail: "" }
        ListElement { name: "总压校准";   spec: "误差 ≤ ±0.5%";     result: ""; detail: "" }
        ListElement { name: "充电测试";   spec: "MOS 导通 · 5A 恒流"; result: ""; detail: "" }
        ListElement { name: "放电测试";   spec: "MOS 导通 · 10A 恒流"; result: ""; detail: "" }
        ListElement { name: "被动均衡";   spec: "开启 · 回路电流正常"; result: ""; detail: "" }
        ListElement { name: "压差检查";   spec: "≤ 80 mV";           result: ""; detail: "" }
    }

    function startTest() {
        for (var i = 0; i < itemsModel.count; ++i) {
            itemsModel.setProperty(i, "result", "")
            itemsModel.setProperty(i, "detail", "")
        }
        root.testState = "running"
        root.runIndex = 0
    }

    // 每项的模拟判定：压差项因 11 号电芯偏低判 fail，其余 pass
    function finishCurrent() {
        var i = root.runIndex
        if (i >= 0 && i < itemsModel.count) {
            var fail = itemsModel.get(i).name === "压差检查"
            itemsModel.setProperty(i, "result", fail ? "fail" : "pass")
            itemsModel.setProperty(i, "detail", fail
                ? "Cell#11 偏低 124 mV，超出规格，需补电或更换"
                : "OK")
        }
        if (root.runIndex < itemsModel.count - 1) {
            root.runIndex++
        } else {
            root.runIndex = -1
            root.testState = "done"
        }
    }

    function failedCount() {
        var n = 0
        for (var i = 0; i < itemsModel.count; ++i) {
            if (itemsModel.get(i).result === "fail")
                n++
        }
        return n
    }

    function passedCount() {
        var n = 0
        for (var i = 0; i < itemsModel.count; ++i) {
            if (itemsModel.get(i).result === "pass")
                n++
        }
        return n
    }

    // 失败详情弹窗选中行
    property int detailIndex: -1

    // 用函数而非 onDetailIndexChanged 开窗：重复点击同一项时属性值不变、
    // changed 信号不触发，弹窗就不会再开
    function openDetail(index) {
        root.detailIndex = index
        detailDialog.open()
    }

    Timer {
        interval: 450
        repeat: true
        running: root.testState === "running"
        onTriggered: root.finishCurrent()
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

        RowLayout {
            spacing: theme.spacingSm
            width: parent.width

            Text {
                color: theme.foreground
                font.pixelSize: 20
                font.bold: true
                text: qsTr("EOL 测试")
                Layout.fillWidth: true
            }
            ShadcnBadge {
                text: {
                    if (root.testState === "running") return qsTr("测试中")
                    if (root.testState === "done") return qsTr("合格")
                    return qsTr("待测")
                }
                variant: {
                    if (root.testState === "done" && root.failedCount() === 0)
                        return ShadcnBadge.Variant.Secondary
                    return ShadcnBadge.Variant.Destructive
                }
                visible: root.testState !== "idle"
            }
            ShadcnButton {
                iconName: root.testState === "running" ? "" : "play"
                enabled: root.testState !== "running"
                loading: root.testState === "running"
                size: ShadcnButton.Size.Small
                text: root.testState === "running" ? qsTr("测试中…")
                      : root.testState === "done" ? qsTr("重新测试") : qsTr("开始测试")

                onClicked: root.startTest()
            }
        }
        Text {
            color: theme.mutedForeground
            font.pixelSize: 12
            text: qsTr("SN: LFP16-20260824-0042 · 16S1P 48V · 循环 3 次 · 出厂前全检")
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

            // ── 测试项列表 ──
            Repeater {
                model: itemsModel

                delegate: ShadcnCard {
                    id: itemCard

                    required property int index
                    required property string name
                    required property string spec
                    required property string result
                    required property string detail

                    width: parent.width

                    ShadcnCardContent {
                        RowLayout {
                            width: parent.width - 8
                            spacing: theme.spacingMd

                            // 状态圆点：进行中黄 / 通过绿 / 失败红 / 待测灰
                            ShadcnStatusDot {
                                status: root.runIndex === itemCard.index && root.testState === "running"
                                        ? ShadcnStatusDot.Status.Warning
                                        : itemCard.result === "pass" ? ShadcnStatusDot.Status.Success
                                        : itemCard.result === "fail" ? ShadcnStatusDot.Status.Danger
                                        : ShadcnStatusDot.Status.Offline
                            }

                            ColumnLayout {
                                spacing: 2
                                Layout.fillWidth: true

                                RowLayout {
                                    spacing: theme.spacingSm

                                    Text {
                                        color: theme.foreground
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                        text: itemCard.name
                                    }
                                    Text {
                                        color: theme.mutedForeground
                                        font.pixelSize: 12
                                        text: itemCard.spec
                                    }
                                    Item { Layout.fillWidth: true }
                                    // 结果 Badge：Pass=Secondary / Fail=Destructive
                                    ShadcnBadge {
                                        text: itemCard.result === "pass" ? qsTr("PASS")
                                              : itemCard.result === "fail" ? qsTr("FAIL") : ""
                                        variant: itemCard.result === "fail"
                                                 ? ShadcnBadge.Variant.Destructive
                                                 : ShadcnBadge.Variant.Secondary
                                        visible: itemCard.result !== ""
                                    }
                                    ShadcnSpinner {
                                        visible: root.runIndex === itemCard.index && root.testState === "running"
                                        width: 14
                                        height: 14
                                        color: theme.mutedForeground
                                    }
                                    ShadcnButton {
                                        size: ShadcnButton.Size.Small
                                        text: qsTr("详情")
                                        variant: ShadcnButton.Variant.Outline
                                        visible: itemCard.result === "fail"

                                        onClicked: root.openDetail(itemCard.index)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item { height: 4 }
        }
    }

    // 失败详情对话框
    ShadcnDialog {
        id: detailDialog

        modal: true

        ShadcnDialogContent {
            ShadcnDialogHeader {
                ShadcnDialogTitle {
                    text: root.detailIndex >= 0 && root.detailIndex < itemsModel.count
                          ? itemsModel.get(root.detailIndex).name + " · FAIL" : ""
                }
                ShadcnDialogDescription {
                    text: root.detailIndex >= 0 && root.detailIndex < itemsModel.count
                          ? itemsModel.get(root.detailIndex).detail : ""
                }
            }
            footer: ShadcnDialogFooter {
                ShadcnButton {
                    text: qsTr("关闭")
                    size: ShadcnButton.Size.Small
                    variant: ShadcnButton.Variant.Outline

                    onClicked: detailDialog.close()
                }
                ShadcnButton {
                    text: qsTr("标记返修")
                    size: ShadcnButton.Size.Small
                    variant: ShadcnButton.Variant.Destructive

                    onClicked: detailDialog.close()
                }
            }
        }
    }
}
