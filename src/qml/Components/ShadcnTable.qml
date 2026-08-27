// src/qml/Components/ShadcnTable.qml
import QtQuick
import QtQuick.Controls as QQC
import QtShadcn

// shadcn/ui 风格表格（M5）：表头 sticky + 行 hover/选中 + 列对齐
// 规范：容器 rounded-md border；单元格 p-4(16px)；行 hover bg-muted/50；
//       行选中 bg-muted；表头 text-sm font-medium text-muted-foreground
// 用法:
//   ShadcnTable {
//       model: myTableModel   // ShadcnTableModel
//       onRowClicked: row => { ... }
//   }
Item {
    id: root

    property ShadcnTableModel model: null
    property int rowHeight: 48
    property int headerHeight: 48
    property int currentRow: -1

    signal rowClicked(int row)

    QtShadcnTheme { id: theme }

    // 列总宽（横向滚动用）
    readonly property int totalWidth: {
        var w = 0
        if (root.model) for (var c = 0; c < root.model.columnCount(); ++c)
            w += root.model.columnMeta(c).width || 120
        return Math.max(w, root.width)
    }

    // ── 容器：rounded-md border（对齐 shadcn data-table 外层容器） ──
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: theme.border
        radius: theme.radius
        clip: true

        // 单 Flickable 双轴滚动：表头 y 固定 0（纵向滚动时不走），表体在下方，
        // 横向 contentWidth 共享 → 表头与表体横向始终对齐
        Flickable {
            id: flick
            anchors.fill: parent
            contentWidth: root.totalWidth
            contentHeight: header.height + body.contentHeight
            clip: true

            // ── 表头（sticky） ──
            Row {
                id: header
                height: root.headerHeight
                z: 2
                Repeater {
                    model: root.model ? root.model.columnCount() : 0
                    delegate: Rectangle {
                        required property int index
                        width: root.model.columnMeta(index).width || 120
                        height: root.headerHeight
                        color: "transparent"
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            text: root.model.columnMeta(index).title || ""
                            color: theme.mutedForeground
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            horizontalAlignment: root.model.columnMeta(index).align === "center"
                                ? Text.AlignHCenter : root.model.columnMeta(index).align === "right"
                                    ? Text.AlignRight : Text.AlignLeft
                            anchors.right: root.model.columnMeta(index).align === "right" ? parent.right : undefined
                            anchors.rightMargin: root.model.columnMeta(index).align === "right" ? 16 : 0
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.model.sortBy(index, !(root._sortCol === index && root._asc))
                        }
                    }
                }
            }

            // ── 表体 ──
            TableView {
                id: body
                y: header.height
                width: root.totalWidth
                height: Math.max(0, flick.height - header.height)
                clip: true
                model: root.model
                rowHeightProvider: function() { return root.rowHeight }
                columnWidthProvider: function(c) { return root.model ? (root.model.columnMeta(c).width || 120) : 120 }
                delegate: Rectangle {
                    required property int row
                    required property int column
                    height: root.rowHeight
                    // 选中 bg-muted；hover bg-muted/50；默认透明
                    color: root.currentRow === row ? theme.muted
                          : rowHover.containsMouse ? Qt.alpha(theme.muted, 0.5) : "transparent"
                    // 行底分隔线
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: theme.border
                    }
                    Text {
                        id: cellText
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        text: root.model ? root.model.cellData(row, column) : ""
                        color: root.currentRow === row ? theme.foreground : theme.foreground
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        horizontalAlignment: root.model && root.model.columnMeta(column).align === "center"
                            ? Text.AlignHCenter : root.model && root.model.columnMeta(column).align === "right"
                                ? Text.AlignRight : Text.AlignLeft
                        anchors.right: root.model && root.model.columnMeta(column).align === "right" ? parent.right : undefined
                        anchors.rightMargin: root.model && root.model.columnMeta(column).align === "right" ? 16 : 0
                    }
                    MouseArea {
                        id: rowHover
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
                // 整行点击选中：TableView 没有行级信号，用 TapHandler 捕获点击反推 row
                TapHandler {
                    onTapped: function(eventPoint) {
                        var r = body.rowAt(eventPoint.position.x, eventPoint.position.y)
                        if (r >= 0) { root.currentRow = r; root.rowClicked(r) }
                    }
                }
            }
        }
    }

    // 排序状态（表头点击切换 asc/desc）
    property int _sortCol: -1
    property bool _asc: true
    onModelChanged: { root._sortCol = -1; root._asc = true }
}
