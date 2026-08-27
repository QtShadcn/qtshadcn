// examples/showcase/pages/TablePage.qml
import QtQuick
import QtQuick.Layouts
import QtShadcn

Column {
    id: root
    spacing: 16
    padding: 24
    width: parent ? parent.width : 800

    QtShadcnTheme { id: theme }

    Text {
        text: "ShadcnTable"
        font.pixelSize: 20
        font.bold: true
        color: theme.foreground
    }
    Text {
        text: "基于 QQC.TableView + ShadcnTableModel。点击表头排序，点击行在下方详情卡展示（Badge / StatusDot 组合）。"
        font.pixelSize: 13
        color: theme.mutedForeground
        wrapMode: Text.Wrap
    }

    ShadcnTableModel {
        id: userModel
        columns: [
            { key: "name",   title: "姓名",   width: 140, align: "left" },
            { key: "email",  title: "邮箱",   width: 240, align: "left" },
            { key: "role",   title: "角色",   width: 120, align: "left" },
            { key: "status", title: "状态",   width: 100, align: "center" }
        ]
        rows: [
            { name: "Alice",  email: "alice@qtshadcn.dev",  role: "管理员", status: "在线" },
            { name: "Bob",    email: "bob@qtshadcn.dev",    role: "编辑",   status: "忙碌" },
            { name: "Carol",  email: "carol@qtshadcn.dev",  role: "访客",   status: "离线" },
            { name: "Dave",   email: "dave@qtshadcn.dev",   role: "编辑",   status: "在线" },
            { name: "Eve",    email: "eve@qtshadcn.dev",    role: "管理员", status: "离线" }
        ]
    }

    ShadcnTable {
        id: table
        width: parent.width - 48
        height: 280
        model: userModel
        onRowClicked: function(row) {
            var r = userModel.getRow(row)
            detailTitle.text = r.name
            detailEmail.text = r.email
            detailRole.text = r.role
            detailStatus.text = r.status
        }
    }

    // 详情卡：演示数据层 + 既有组件组合
    ShadcnCard {
        width: parent.width - 48
        ShadcnCardHeader {
            ShadcnCardTitle { id: detailTitle; text: "选中一行查看详情" }
            ShadcnCardDescription { id: detailEmail; text: "" }
        }
        ShadcnCardContent {
            Row {
                spacing: 16
                ShadcnBadge { id: detailRole; text: "—"; variant: ShadcnBadge.Variant.Secondary }
                Row {
                    spacing: 6
                    ShadcnStatusDot { }
                    Text { id: detailStatus; text: "—"; color: theme.foreground; font.pixelSize: 13 }
                }
            }
        }
    }
}
