import QtQuick
import QtShadcn

// 按钮组：相邻按钮边框合并（spacing: -1），圆角只保留两端
// 子项直接放 ShadcnButton / ShadcnToggle 即可，圆角位置自动分配
Row {
    id: root

    spacing: -1

    onChildrenChanged: updateGroup()
    Component.onCompleted: updateGroup()

    function updateGroup() {
        var btns = []
        for (var i = 0; i < root.children.length; ++i) {
            var c = root.children[i]
            if (c.hasOwnProperty("_groupPosition"))
                btns.push(c)
        }
        var n = btns.length
        for (var j = 0; j < n; ++j) {
            btns[j]._groupPosition = n === 1 ? "only"
                : j === 0 ? "first"
                : j === n - 1 ? "last" : "middle"
        }
    }
}
