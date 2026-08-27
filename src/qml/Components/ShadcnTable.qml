// src/qml/Components/ShadcnTable.qml
import QtQuick
import QtQuick.Controls 2.15 as QQC
import QtShadcn

// shadcn/ui 风格表格（M5）：表头 sticky + 行 hover/选中 + 列对齐
// 用法:
//   ShadcnTable {
//       model: myTableModel   // ShadcnTableModel
//       onRowClicked: row => { ... }
//   }
Item {
    id: root

    property ShadcnTableModel model: null
    property int rowHeight: 40
    property int headerHeight: 40
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
                    color: theme.muted
                    // 分隔竖线
                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 1
                        color: theme.border
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        text: root.model.columnMeta(index).title || ""
                        color: theme.foreground
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: root.model.columnMeta(index).align === "center"
                            ? Text.AlignHCenter : root.model.columnMeta(index).align === "right"
                                ? Text.AlignRight : Text.AlignLeft
                        anchors.right: root.model.columnMeta(index).align === "right" ? parent.right : undefined
                        anchors.rightMargin: root.model.columnMeta(index).align === "right" ? 12 : 0
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.model.sortBy(index, !(root._sortCol === index && root._asc))
                    }
                }
            }
        }

        // ── 表体 ──
        QQC.TableView {
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
                color: root.currentRow === row ? theme.accent
                      : rowHover.containsMouse ? theme.muted : "transparent"
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
                    anchors.leftMargin: 12
                    text: root.model ? root.model.cellData(row, column) : ""
                    color: root.currentRow === row ? theme.accentForeground : theme.foreground
                    font.pixelSize: 13
                    elide: Text.ElideRight
                    horizontalAlignment: root.model && root.model.columnMeta(column).align === "center"
                        ? Text.AlignHCenter : root.model && root.model.columnMeta(column).align === "right"
                            ? Text.AlignRight : Text.AlignLeft
                    anchors.right: root.model && root.model.columnMeta(column).align === "right" ? parent.right : undefined
                    anchors.rightMargin: root.model && root.model.columnMeta(column).align === "right" ? 12 : 0
                }
                MouseArea {
                    id: rowHover
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
            // 整行点击选中：TableView 没有行级信号，用点击事件反推 row
            onClicked: function(pos) {
                var r = body.rowAt(pos.x, pos.y)
                if (r >= 0) { root.currentRow = r; root.rowClicked(r) }
            }
        }
    }

    // 排序状态（表头点击切换 asc/desc）
    property int _sortCol: -1
    property bool _asc: true
    onModelChanged: { root._sortCol = -1; root._asc = true }
}
