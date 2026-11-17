// delegate 里要访问外层 theme / root，显式声明后静态分析能确认来源
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtShadcn

// 动效页：motion token 的实际效果 + 减弱动画开关
// 这页的用途不只是「有个动画展示」，而是让时长/缓动这些抽象数字变成能直接比较的
// 东西 —— 四档时长并排跑同一个位移，谁快谁慢一眼看出，比读表格里的 100/120/150/200 有用。
Item {
    id: root

    QtShadcnTheme {
        id: theme
    }

    // 四个演示块共用的重放触发器：自增即让所有演示同时重跑一遍
    property int replayTick: 0

    // 标题区（固定）
    Column {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        anchors.topMargin: 40

        spacing: theme.spacingLg

        Text {
            text: qsTr("动效 Token")
            color: theme.foreground
            font.pixelSize: 20
            font.bold: true
        }

        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("theme 的四档时长 + 三种缓动。点「重放」让下方位移演示同时跑一遍，肉眼比较 100 / 120 / 150 / 200ms 的差别。打开「减弱动画」后全部瞬间归零。")
            color: theme.mutedForeground
            font.pixelSize: 13
        }
    }

    ScrollView {
        id: sv

        anchors.top: header.bottom
        anchors.topMargin: 20
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 24
        anchors.rightMargin: 24

        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        Column {
            width: sv.availableWidth
            spacing: theme.spacingLg

            // ── 控制条 ──────────────────────────────
            RowLayout {
                width: parent.width
                spacing: theme.spacingMd

                ShadcnButton {
                    text: qsTr("重放")
                    size: ShadcnButton.Size.Small
                    onClicked: root.replayTick++
                }

                ShadcnSwitch {
                    id: reducedSwitch
                    size: ShadcnSwitch.Size.Small
                    onCheckedChanged: theme.reducedMotion = checked
                }
                Text {
                    text: qsTr("减弱动画（reducedMotion）")
                    color: theme.mutedForeground
                    font.pixelSize: 13
                    Layout.alignment: Qt.AlignVCenter
                }
                Item { Layout.fillWidth: true }
            }

            // ── 四档时长并排 ────────────────────────
            SectionTitle {
                text: qsTr("时长档位（同一个位移，四档时长）")
            }

            Column {
                id: durationList
                width: parent.width
                spacing: theme.spacingSm

                Repeater {
                    model: [
                        { label: "durationInstant  100ms", ms: theme.durationInstant },
                        { label: "durationQuick    120ms", ms: theme.durationQuick },
                        { label: "durationNormal   150ms", ms: theme.durationNormal },
                        { label: "durationSlow     200ms", ms: theme.durationSlow }
                    ]

                    delegate: RowLayout {
                        id: durationRow
                        required property var modelData
                        // 拆成显式属性：qmllint 无法静态校验 modelData.xxx
                        // （var 类型的属性访问拿不到类型信息），拆开后统一 QualifiedAccess
                        readonly property string labelText: modelData.label
                        readonly property int durationValue: modelData.ms
                        width: durationList.width
                        spacing: theme.spacingMd

                        Text {
                            text: durationRow.labelText
                            color: theme.mutedForeground
                            font.pixelSize: 12
                            font.family: Qt.platform.os === "osx" ? "Menlo" : "monospace"
                            Layout.preferredWidth: 200
                        }

                        // 轨道 + 滑块：滑块在轨道内左右跑，时长取对应 token
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 28

                            Rectangle {
                                anchors.fill: parent
                                radius: height / 2
                                color: theme.muted
                            }
                            Rectangle {
                                id: knob
                                width: 20
                                height: 20
                                radius: 10
                                y: 4
                                color: theme.primary

                                // replayTick 任一变化都重跑：把 x 归零再动画到右端
                                property bool _atRight: false
                                x: _atRight ? parent.width - width - 4 : 4
                                Behavior on x {
                                    NumberAnimation {
                                        duration: theme.motionDuration(durationRow.durationValue)
                                        easing.type: theme.easingOut
                                    }
                                }
                                Connections {
                                    target: root
                                    function onReplayTickChanged() {
                                        knob._atRight = false
                                        retrigger.restart()
                                    }
                                }
                                Timer {
                                    id: retrigger
                                    interval: 30
                                    onTriggered: knob._atRight = true
                                }
                            }
                        }
                    }
                }
            }

            // ── 弹层过渡 ────────────────────────────
            SectionTitle {
                text: qsTr("弹层过渡（ShadcnFadeZoomTransition）")
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                text: qsTr("Dialog / DropdownMenu / Select 三处共用的 fade + zoom-95。改动前它们各自重复了 8 行一模一样的 Transition。")
                color: theme.mutedForeground
                font.pixelSize: 13
            }
            Row {
                spacing: theme.spacingMd

                ShadcnButton {
                    text: qsTr("打开对话框")
                    onClicked: demoDialog.open()
                }
                ShadcnDropdownMenu {
                    ShadcnDropdownMenuTrigger { text: qsTr("打开菜单") }
                    ShadcnDropdownMenuContent {
                        ShadcnDropdownMenuItem { text: qsTr("菜单项一") }
                        ShadcnDropdownMenuItem { text: qsTr("菜单项二") }
                    }
                }
            }

            // ── 循环动画（不属于 token）─────────────
            SectionTitle {
                text: qsTr("循环动画（周期，不归 token 管）")
            }
            Text {
                width: parent.width
                wrapMode: Text.WordWrap
                text: qsTr("Spinner 的 700ms 是「转一圈」、Skeleton 的 700ms 是「呼吸一次」—— 语义与过渡时长不同，调参动机也不同（前者影响观感节奏，后者影响交互响应），所以没并进四档。")
                color: theme.mutedForeground
                font.pixelSize: 13
            }
            Row {
                spacing: theme.spacingLg
                ShadcnSpinner {
                    width: 24
                    height: 24
                    color: theme.primary
                }
                ShadcnSkeleton {
                    width: 120
                    height: 16
                }
            }

            Item { height: theme.spacingLg }
        }
    }

    // 演示用对话框（关闭钮与遮罩都保持默认行为）
    ShadcnDialog {
        id: demoDialog
        ShadcnDialogContent {
            ShadcnDialogHeader {
                ShadcnDialogTitle { text: qsTr("过渡演示") }
                ShadcnDialogDescription {
                    text: qsTr("进场是 fade + zoom-95，100ms。关掉再看一次。")
                }
            }
            footer: ShadcnDialogFooter {
                ShadcnButton {
                    text: qsTr("知道了")
                    onClicked: demoDialog.close()
                }
            }
        }
    }

    // 页内小标题（与仓库其他 showcase 页面一致的内联组件写法）
    component SectionTitle: Text {
        color: theme.foreground
        font.pixelSize: 15
        font.bold: true
    }
}
