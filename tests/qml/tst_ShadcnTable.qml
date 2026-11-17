pragma ComponentBehavior: Bound

import QtQuick
import QtTest
import QtShadcn

// ShadcnTable：表头 / 单元格 / 行点击 / 表头排序 / 横向联动
//
// 这份测试存在的理由不只是「覆盖」。ShadcnTable 的 delegate 通过闭包访问外层
// root 与 theme（qmllint 报了 44 条 UnqualifiedAccess），要改成 required property
// 逐个传参就得先有回归网 —— 否则重构完只能靠肉眼看示例页有没有坏。
//
// 每个用例都用独立包装组件造一份 model：sortBy 会原地重排 rows，
// 共用一个 model 会让用例之间互相污染。
Item {
    id: root
    width: 800
    height: 600

    Component {
        id: tableComp
        Item {
            width: 500
            height: 300

            ShadcnTableModel {
                id: localModel
                rows: [
                    { name: "张三", age: 30, city: "北京" },
                    { name: "李四", age: 25, city: "上海" },
                    { name: "王五", age: 41, city: "广州" }
                ]
                // 列宽合计 560 > 表格宽 400，才能验证 totalWidth 是求和而非跟随宽度
                columns: [
                    { key: "name", title: "姓名", width: 200, align: "left" },
                    { key: "age", title: "年龄", width: 160, align: "right" },
                    { key: "city", title: "城市", width: 200, align: "left" }
                ]
            }

            ShadcnTable {
                objectName: "table"
                anchors.fill: parent
                width: 400
                model: localModel
            }
        }
    }

    // 容器 600 宽，列宽合计 300（等分）→ 每列应摊到 200
    Component {
        id: stretchComp
        Item {
            width: 600
            height: 300

            ShadcnTableModel {
                id: stretchModel
                rows: [ { name: "a", age: 1, city: "x" } ]
                columns: [
                    { key: "name", title: "A", width: 100, align: "left" },
                    { key: "age",  title: "B", width: 100, align: "left" },
                    { key: "city", title: "C", width: 100, align: "left" }
                ]
            }

            ShadcnTable {
                objectName: "table"
                anchors.fill: parent
                model: stretchModel
            }
        }
    }

    // 容器 600，列宽 40/20/40（合计 100）→ 按比例摊成 240/120/240
    Component {
        id: proportionalComp
        Item {
            width: 600
            height: 300

            ShadcnTableModel {
                id: propModel
                rows: [ { name: "a", age: 1, city: "x" } ]
                columns: [
                    { key: "name", title: "A", width: 40, align: "left" },
                    { key: "age",  title: "B", width: 20, align: "left" },
                    { key: "city", title: "C", width: 40, align: "left" }
                ]
            }

            ShadcnTable {
                objectName: "table"
                anchors.fill: parent
                model: propModel
            }
        }
    }

    // TableView 的 delegate 不是普通 children，会挂到 contentItem 下；
    // objectName 也不唯一（每格同名），所以按名字收集成数组。
    function collectByName(node, name, out) {
        const found = out || []
        if (!node || found.indexOf(node) >= 0)
            return found
        if (node.objectName === name)
            found.push(node)
        if (node.children)
            for (let i = 0; i < node.children.length; ++i)
                collectByName(node.children[i], name, found)
        if (node.contentItem && node.contentItem !== node)
            collectByName(node.contentItem, name, found)
        return found
    }

    // 按 row/column 取某个单元格当前显示的文本。delegate 是池化的，
    // 不能靠数组下标顺序对应，必须读 delegate 自己的 row/column。
    function cellTextAt(table, row, column) {
        const cells = root.collectByName(table, "cellText")
        for (let i = 0; i < cells.length; ++i) {
            const cell = cells[i].parent
            if (cell && cell.row === row && cell.column === column)
                return cells[i].text
        }
        return null
    }

    TestCase {
        name: "ShadcnTable"
        when: windowShown


        // 表头按 columnMeta 的 title 渲染，宽度取 columnMeta 的 width
        function test_header_renders_titles_and_widths() {
            const box = createTemporaryObject(tableComp, root)
            verify(!!box, "Component exists")
            const table = findChild(box, "table")
            verify(!!table, "table exists")

            tryVerify(function() { return root.collectByName(table, "headerCell").length === 3 },
                     5000, "header delegates created")
            const titles = root.collectByName(table, "headerText").map(t => t.text)
            compare(titles, ["姓名", "年龄", "城市"])

            const widths = root.collectByName(table, "headerCell").map(c => c.width)
            compare(widths, [200, 160, 200])
        }

        // 单元格内容来自 model.cellData(row, column)，按行列顺序对应
        function test_body_renders_cell_values() {
            const box = createTemporaryObject(tableComp, root)
            verify(!!box, "Component exists")
            const table = findChild(box, "table")

            tryVerify(function() { return root.collectByName(table, "cellText").length === 9 },
                     5000, "body delegates created")

            // 只断言第一行的三列，避免依赖 delegate 的创建顺序
            const texts = root.collectByName(table, "cellText").map(t => t.text)
            verify(texts.indexOf("张三") >= 0, "name cell: " + texts)
            verify(texts.indexOf("30") >= 0, "age cell: " + texts)
            verify(texts.indexOf("北京") >= 0, "city cell: " + texts)
        }

        // 列宽合计大于组件宽度时，totalWidth 取合计值（横向滚动才有内容可滚）
        function test_total_width_sums_columns() {
            const box = createTemporaryObject(tableComp, root)
            verify(!!box, "Component exists")
            const table = findChild(box, "table")

            tryVerify(function() { return table.totalWidth === 560 }, 5000,
                      "totalWidth should be 200+160+200")
        }

        // ── 容器比列宽合计宽时，列要跟着撑开 ────────────────────────
        //
        // 回归锁定：totalWidth 早已取 Math.max(列宽和, 容器宽)，但列本身没跟着
        // 撑开 —— 结果表头 Row、单元格、行底部那条 border 都停在「列宽合计」处，
        // 而外框有容器那么宽，右侧空出一整块（showcase 里空 140px，肉眼就是
        // 「表格右边缺一块、分割线断在半路」）。对齐 shadcn 的 <table class="w-full">：
        // 列宽是「期望宽度」，容器更宽时按比例分摊多余空间。
        function test_columns_stretch_to_fill_container() {
            const box = createTemporaryObject(stretchComp, root)
            verify(!!box, "Component exists")
            const table = findChild(box, "table")

            // 列宽 100+100+100=300，容器 600 → 每列摊到 200
            tryVerify(function() { return table.totalWidth === 600 }, 5000,
                      "totalWidth 应等于容器宽（列和 300 < 容器 600）: " + table.totalWidth)
            tryVerify(function() {
                const w = table.columnWidths
                return Math.round(w[0]) === 200 && Math.round(w[1]) === 200
                       && Math.round(w[2]) === 200
            }, 5000, "等分三列应摊到 200/200/200，实际 " + JSON.stringify(table.columnWidths))

            // 比例保持：40/20/40 的列宽在 600 容器里应摊成 240/120/240
            const box2 = createTemporaryObject(proportionalComp, root)
            const table2 = findChild(box2, "table")
            tryVerify(function() { return table2.totalWidth === 600 }, 5000,
                      "proportional: totalWidth 600")
            tryVerify(function() {
                const w = table2.columnWidths
                return Math.round(w[0]) === 240 && Math.round(w[1]) === 120
                       && Math.round(w[2]) === 240
            }, 5000, "40/20/40 应按比例摊成 240/120/240，实际 " + JSON.stringify(table2.columnWidths))
        }

        // 表头 Row 与单元格的实际宽度都要撑满，不能只是 totalWidth 变大。
        // 上面那条测的是数据，这条测的是「画出来的东西」—— 两者不同：
        // 数据对了但 delegate 仍用原始列宽，视觉上照样缺一块。
        function test_header_and_cells_reach_container_edge() {
            const box = createTemporaryObject(stretchComp, root)
            const table = findChild(box, "table")

            tryVerify(function() { return table.totalWidth === 600 }, 5000)
            tryVerify(function() { return root.collectByName(table, "headerCell").length === 3 },
                      5000, "header cells created")

            const headers = root.collectByName(table, "headerCell")
            let sum = 0
            for (let i = 0; i < headers.length; ++i)
                sum += headers[i].width
            compare(sum, 600, "表头各格宽度之和应等于 totalWidth（撑满，不留白）")

            // 每一格都要真的变宽，而不是只把最后一个拉长
            for (let i = 0; i < headers.length; ++i)
                compare(headers[i].width, 200, "header[" + i + "] 应摊到 200")
        }

        // 点击行既更新 currentRow，也发 rowClicked(row)
        function test_row_click_updates_current_and_emits() {
            const box = createTemporaryObject(tableComp, root)
            verify(!!box, "Component exists")
            const table = findChild(box, "table")

            tryVerify(function() { return root.collectByName(table, "rowClick").length >= 3 },
                     5000, "row MouseAreas created")
            compare(table.currentRow, -1)

            const spy = createTemporaryObject(spyComp, root,
                                              { target: table, signalName: "rowClicked" })
            verify(!!spy, "SignalSpy exists")
            mouseClick(root.collectByName(table, "rowClick")[0])
            tryCompare(spy, "count", 1)
            compare(spy.signalArguments[0][0], 0)
            verify(table.currentRow >= 0, "currentRow set after click")
        }

        // 表头点击按该列排序：升序后 age 第一行应是 25
        function test_header_click_sorts_ascending() {
            const box = createTemporaryObject(tableComp, root)
            verify(!!box, "Component exists")
            const table = findChild(box, "table")
            const model = table.model

            tryVerify(function() { return root.collectByName(table, "headerClick").length === 3 },
                     5000, "header click areas created")

            compare(model.getRow(0).name, "张三")
            mouseClick(root.collectByName(table, "headerClick")[1])   // 年龄列
            compare(model.getRow(0).age, 25)
            compare(model.getRow(2).age, 41)
        }

        // 同一列表头点第二次应切降序。旧实现只算不记：_sortCol/_asc 从不更新，
        // 于是第二次点击仍然走升序，这个用例专门锁住它。
        function test_header_click_twice_toggles_to_descending() {
            const box = createTemporaryObject(tableComp, root)
            verify(!!box, "Component exists")
            const table = findChild(box, "table")
            const model = table.model

            tryVerify(function() { return root.collectByName(table, "headerClick").length === 3 },
                     5000, "header click areas created")

            mouseClick(root.collectByName(table, "headerClick")[1])
            compare(model.getRow(0).age, 25)
            mouseClick(root.collectByName(table, "headerClick")[1])
            compare(model.getRow(0).age, 41, "second click should sort descending")
        }

        // 排序改变的是行序，不是行列数：delegate 不会被重建，只有 dataChanged。
        // cellData() 是 Q_INVOKABLE，若不显式依赖 revision，正文永远停在旧值。
        function test_sorted_cells_refresh_after_header_click() {
            const box = createTemporaryObject(tableComp, root)
            verify(!!box, "Component exists")
            const table = findChild(box, "table")

            tryVerify(function() { return root.cellTextAt(table, 0, 0) === "张三" }, 5000,
                      "initial first cell")

            mouseClick(root.collectByName(table, "headerClick")[1])   // 年龄升序

            tryVerify(function() { return root.cellTextAt(table, 0, 0) === "李四" }, 5000,
                      "first row should switch to 李四 after ascending sort")
            compare(root.cellTextAt(table, 0, 1), "25")
        }

        // 表体横向滚动时表头跟着平移，否则表头与列错位
        function test_header_follows_horizontal_scroll() {
            const box = createTemporaryObject(tableComp, root)
            verify(!!box, "Component exists")
            const table = findChild(box, "table")

            const headerClip = findChild(table, "headerClip")
            const body = findChild(table, "bodyView")
            verify(!!headerClip, "headerClip exists")
            verify(!!body, "bodyView exists")

            body.contentX = 100
            tryCompare(headerClip, "x", -100)
        }

        // 表体接了统一滚动条（此前 TableView 完全没有 ScrollBar，只能滚轮拖）
        function test_body_has_vertical_scrollbar() {
            const box = createTemporaryObject(tableComp, root)
            const table = findChild(box, "table")
            const body = findChild(table, "bodyView")
            verify(!!body, "bodyView exists")

            const bar = findChild(body, "verticalBar")
            verify(!!bar, "vertical scrollbar attached to body")
            compare(bar.vertical, true, "orientation is vertical")

            // 滚动条是叠加层，不应挤占列宽计算
            compare(table.totalWidth, table.columnWidths.reduce(function(a, b) { return a + b }, 0),
                    "scrollbar must not affect totalWidth")
        }
    }

    Component {
        id: spyComp
        SignalSpy {}
    }
}
