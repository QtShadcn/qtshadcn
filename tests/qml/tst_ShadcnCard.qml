import QtQuick
import QtQuick.Layouts
import QtTest
import QtShadcn

// ShadcnCard：内容容器是 ColumnLayout，子项可参与布局
//
// 回归锁定（0.2.0 前是 Column，三条限制都源于它不吃 Layout）：
// 1. implicitWidth 320 被当成 Layout 最小宽 → 一行 4 张卡把窗口顶宽
// 2. 子项写 Layout.fillHeight 无效 → 只能手算「卡片高 - Header - Footer」
// 3. Column 给子项的宽度是 0 → 子项无法靠 Layout.fillWidth 撑满内边距内区域
Item {
    id: root
    width: 900
    height: 700

    Component {
        id: cardComp
        ShadcnCard {
            Layout.fillWidth: true
        }
    }

    Component {
        id: fourCardsRowComp
        RowLayout {
            width: 640
            spacing: 8

            ShadcnCard { Layout.fillWidth: true }
            ShadcnCard { Layout.fillWidth: true }
            ShadcnCard { Layout.fillWidth: true }
            ShadcnCard { Layout.fillWidth: true }
        }
    }

    Component {
        id: fillHeightCardComp
        ShadcnCard {
            width: 300
            height: 240

            ShadcnCardContent {
                objectName: "content"

                Layout.fillHeight: true

                Rectangle {
                    anchors.fill: parent
                    color: "#ff0000"
                }
            }
        }
    }

    Component {
        id: fillWidthChildComp
        ShadcnCard {
            width: 300
            height: 200

            Rectangle {
                objectName: "child"
                Layout.fillWidth: true
                color: "#ff0000"
            }
        }
    }

    TestCase {
        name: "ShadcnCard"
        when: windowShown

        // 卡片放进 Layout 时不应要求最小宽 320，否则并排多张会把窗口顶宽
        function test_layout_minimum_width_is_zero() {
            const card = createTemporaryObject(cardComp, root)
            verify(!!card, "Component exists")
            compare(card.Layout.minimumWidth, 0)
        }

        // 4 张卡在 640 宽的行里必须能压缩平分，而不是各自霸占 320
        function test_four_cards_share_row_width() {
            const row = createTemporaryObject(fourCardsRowComp, root)
            verify(!!row, "Component exists")
            compare(row.children.length, 4)

            // 640 - 3×8 = 616，平分后每张 154
            tryVerify(function() { return row.children[0].width < 200 })
            for (let i = 0; i < 4; i++)
                verify(Math.abs(row.children[i].width - 154) <= 2)
            verify(row.childrenRect.width <= row.width + 1)
        }

        // 内容区写 Layout.fillHeight 应真的撑满剩余高度（旧实现无效果）
        function test_content_fills_card_height() {
            const card = createTemporaryObject(fillHeightCardComp, root)
            verify(!!card, "Component exists")

            const content = findChild(card, "content")
            verify(!!content, "Object exists")

            // 240 - 上下内边距各 24 = 192
            tryVerify(function() { return Math.abs(content.height - 192) <= 2 })
            verify(Math.abs(content.width - 252) <= 2)   // 300 - 24×2
        }

        // 直接子项靠 Layout.fillWidth 撑满内边距内区域（旧实现宽度为 0）
        function test_child_fills_content_width() {
            const card = createTemporaryObject(fillWidthChildComp, root)
            verify(!!card, "Component exists")

            const child = findChild(card, "child")
            verify(!!child, "Object exists")

            tryVerify(function() { return Math.abs(child.width - 252) <= 2 })
        }
    }
}
