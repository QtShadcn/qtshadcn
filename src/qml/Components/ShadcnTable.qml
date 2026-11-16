// src/qml/Components/ShadcnTable.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic   // ScrollBar attached property
import QtShadcn

// shadcn/ui 风格表格（M5）：原生 TableView 滚动 + 表头水平联动
// 规范(对齐 shadcn DOM)：容器 overflow-x-auto；表头 h-10 px-2 font-medium text-foreground；
//       单元格 p-2 align-middle；行 border-b；hover bg-muted/50；选中 bg-muted
// 用法:
//   ShadcnTable {
//       model: myTableModel   // ShadcnTableModel
//       onRowClicked: row => { ... }
//   }
//
// pragma ComponentBehavior: Bound 是给 qmllint 看的：delegate 内的 root / theme
// 属于外层作用域，显式声明后静态分析能确认来源，不再逐条报 UnqualifiedAccess。
// 运行时行为不变（Bound 下 delegate 依旧能访问外层 id）。
Item {
    id: root

    property ShadcnTableModel model: null
    property int rowHeight: 40
    property int headerHeight: 40
    property int currentRow: -1

    signal rowClicked(int row)

    QtShadcnTheme { id: theme }

    // ── 模型快照 ─────────────────────────────────────────────────
    //
    // columnCount() / columnMeta() / cellData() 都是 Q_INVOKABLE，不产生
    // 属性依赖。若绑定直写 `model ? model.columnCount() : 0`，而 columns 是在
    // 组件创建之后才赋值的（异步取数、或声明顺序靠后），首次求值拿到 0 之后
    // 绑定再也不会重算 —— 表头就永久空白。totalWidth 曾因额外依赖 root.width
    // 而侥幸重算，才让这个缺陷不易察觉。
    //
    // 这里把模型状态抽成显式属性，由 model 的信号驱动，绑定才有可靠的通知源。
    property int columnCount: 0
    property int rowCount: 0
    readonly property var columnWidths: _columnWidths
    readonly property var columnTitles: _columnTitles
    readonly property var columnAligns: _columnAligns
    // 模型内容版本号。数据变了但行列没变（sortBy / updateRow 走 dataChanged）
    // 时靠它让 delegate 的正文重新求值。
    property int revision: 0

    property var _columnWidths: []
    property var _columnTitles: []
    property var _columnAligns: []

    // 列总宽（横向滚动用）
    readonly property int totalWidth: {
        let w = 0
        for (let c = 0; c < root.columnCount; ++c)
            w += _columnWidths[c] || 120
        return Math.max(w, root.width)
    }

    function _syncColumns() {
        const n = root.model ? root.model.columnCount() : 0
        const widths = []
        const titles = []
        const aligns = []
        for (let c = 0; c < n; ++c) {
            const meta = root.model.columnMeta(c)
            widths.push(meta.width || 120)
            titles.push(meta.title || "")
            aligns.push(meta.align || "left")
        }
        root.columnCount = n
        root._columnWidths = widths
        root._columnTitles = titles
        root._columnAligns = aligns
    }

    function _syncRows() {
        root.rowCount = root.model ? root.model.rowCount() : 0
        root.revision++
    }

    function _syncAll() {
        _syncColumns()
        _syncRows()
    }

    // 单元格正文。revision 在这里被读到，绑定因此与「模型内容变化」挂钩。
    function cellText(row, column) {
        if (root.revision < 0)
            return ""            // 只为建立 revision 依赖，运行时恒不成立
        return root.model ? String(root.model.cellData(row, column)) : ""
    }

    // 表头点击：同列再次点击切换升降序，换列则回到升序
    function _sortBy(column) {
        if (!root.model)
            return
        const ascending = !(root._sortCol === column && root._asc)
        root._sortCol = column
        root._asc = ascending
        root.model.sortBy(column, ascending)
    }

    function _clickRow(row) {
        root.currentRow = row
        root.rowClicked(row)
    }

    onModelChanged: _syncAll()
    Component.onCompleted: _syncAll()

    Connections {
        target: root.model
        ignoreUnknownSignals: true
        function onColumnsChanged() { root._syncColumns(); root.revision++ }
        function onRowsChanged() { root._syncRows() }
        function onModelReset() { root._syncAll() }
        function onDataChanged() { root.revision++ }
        function onLayoutChanged() { root.revision++ }
    }

    // 排序状态
    property int _sortCol: -1
    property bool _asc: true

    // ── 容器：rounded-md border（对齐 shadcn data-table 外层容器） ──
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: theme.border
        radius: theme.radius
        clip: true

        // ── 表头（顶部固定，水平联动 body.contentX） ──
        Item {
            id: headerClip
            objectName: "headerClip"
            width: parent.width
            height: root.headerHeight
            clip: true
            z: 2
            x: -body.contentX

            Row {
                id: header
                objectName: "headerRow"
                width: root.totalWidth
                height: root.headerHeight
                Repeater {
                    // 依赖 columnCount（有 notify），不再依赖 columnCount()
                    model: root.columnCount
                    delegate: Rectangle {
                        id: headerCell

                        required property int index
                        objectName: "headerCell"
                        readonly property string textAlign: root.columnAligns[index] || "left"
                        width: root.columnWidths[index] || 120
                        height: root.headerHeight
                        color: "transparent"

                        Text {
                            objectName: "headerText"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.right: headerCell.textAlign === "right" ? parent.right : undefined
                            anchors.rightMargin: headerCell.textAlign === "right" ? 8 : 0
                            text: root.columnTitles[headerCell.index] || ""
                            color: theme.foreground
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            horizontalAlignment: headerCell.textAlign === "center" ? Text.AlignHCenter
                                               : headerCell.textAlign === "right" ? Text.AlignRight
                                                                                 : Text.AlignLeft
                        }
                        MouseArea {
                            objectName: "headerClick"
                            anchors.fill: parent
                            onClicked: root._sortBy(headerCell.index)
                        }
                    }
                }
            }
        }

        // ── 表体（TableView 原生滚动，不再套 Flickable） ──
        TableView {
            id: body
            objectName: "bodyView"
            y: root.headerHeight
            width: parent.width
            height: parent.height - root.headerHeight
            contentWidth: root.totalWidth
            clip: true
            // 竖向滚动条走统一样式。attach 到 Flickable 的 ScrollBar 是叠加层，
            // 不挤占可用宽 → 不影响 columnWidths / totalWidth 的计算，
            // 也不影响表头联动用的 body.contentX（那是水平方向）
            ScrollBar.vertical: ShadcnScrollBar { objectName: "verticalBar" }
            model: root.model
            rowHeightProvider: function(row) { return root.rowHeight }
            columnWidthProvider: function(column) { return root.columnWidths[column] || 120 }
            delegate: Rectangle {
                id: bodyCell

                required property int row
                required property int column
                objectName: "bodyCell"
                readonly property string textAlign: root.columnAligns[column] || "left"
                height: root.rowHeight
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
                    objectName: "cellText"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.right: bodyCell.textAlign === "right" ? parent.right : undefined
                    anchors.rightMargin: bodyCell.textAlign === "right" ? 8 : 0
                    text: root.cellText(bodyCell.row, bodyCell.column)
                    color: theme.foreground
                    font.pixelSize: 14
                    elide: Text.ElideRight
                    horizontalAlignment: bodyCell.textAlign === "center" ? Text.AlignHCenter
                                     : bodyCell.textAlign === "right" ? Text.AlignRight
                                                                      : Text.AlignLeft
                }
                MouseArea {
                    id: rowHover
                    objectName: "rowClick"
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root._clickRow(bodyCell.row)
                }
            }
        }
    }
}
