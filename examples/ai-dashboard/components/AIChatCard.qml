import QtQuick
import QtQuick.Layouts
import QtShadcn

// AI 助手卡片：消息列表 + 输入框 + 发送按钮
ShadcnCard {
    id: card

    QtShadcnTheme { id: theme }

    ShadcnCardHeader {
        id: cardHeader

        RowLayout {
            spacing: theme.spacingSm

            ShadcnIcon {
                name: "sparkles"
                size: 18
                color: theme.primary
            }
            ShadcnCardTitle { text: qsTr("AI 助手") }
        }
        ShadcnCardDescription { text: qsTr("随时为你解答问题") }
    }

    ShadcnCardContent {
        id: cardContent

        // 撑满卡片剩余高度（Card 高 - Header - Footer - 4×内边距，兜底防 NaN）
        height: Math.max(200, card.height - cardHeader.height - cardFooter.height - card.padding * 4)

        ListView {
            id: messageList
            anchors.fill: parent
            clip: true
            spacing: theme.spacingMd
            model: messageModel

            delegate: MessageBubble {
                width: messageList.width
            }
        }
    }

    ShadcnCardFooter {
        id: cardFooter

        RowLayout {
            spacing: theme.spacingSm

            ShadcnInput {
                id: input
                Layout.fillWidth: true
                enabled: !card.waiting
                placeholderText: qsTr("输入消息...")
                onAccepted: card.sendMessage()
            }

            ShadcnButton {
                text: qsTr("发送")
                iconName: "send"
                enabled: !card.waiting
                loading: card.waiting
                onClicked: card.sendMessage()
            }
        }
    }

    property bool waiting: false
    property string pendingUserText: ""

    ListModel {
        id: messageModel
        ListElement { role: "ai"; text: "你好！我是 AI 助手，有什么可以帮你？" }
        ListElement { role: "user"; text: "QtShadcn 怎么接入项目？" }
        ListElement { role: "ai"; text: "通过 add_subdirectory 引入库，链接 QtShadcn 目标即可。" }
    }

    Timer {
        id: replyTimer
        interval: 900
        repeat: false
        onTriggered: {
            var last = messageModel.count - 1
            if (last >= 0)
                messageModel.setProperty(last, "text", card.mockReply(card.pendingUserText))
            card.waiting = false
            card.pendingUserText = ""
            messageList.positionViewAtEnd()
        }
    }

    function sendMessage() {
        var t = input.text.trim()
        if (t.length === 0 || card.waiting)
            return

        messageModel.append({ role: "user", text: t })
        input.text = ""
        card.pendingUserText = t
        card.waiting = true
        messageModel.append({ role: "ai", text: qsTr("正在思考...") })
        messageList.positionViewAtEnd()
        replyTimer.restart()
    }

    // 本地模拟回复：按关键词走几条固定话术，其余回声复述
    function mockReply(userText) {
        var q = userText.toLowerCase()
        if (q.indexOf("qtshadcn") >= 0 || q.indexOf("接入") >= 0)
            return qsTr("在 CMake 里 add_subdirectory 引入 QtShadcn，然后 target_link_libraries 链接 QtShadcn，QML 里 import QtShadcn 即可。")
        if (q.indexOf("主题") >= 0 || q.indexOf("暗色") >= 0 || q.indexOf("浅色") >= 0)
            return qsTr("左侧栏底部可以切换浅色 / 深色。ThemeManager.mode 在 light 和 dark 之间切换，组件会跟 token 走。")
        if (q.indexOf("项目") >= 0)
            return qsTr("点左侧「项目」可以看当前工作区列表。需要的话我也可以帮你规划新建项目的步骤。")
        if (q.indexOf("菜单") >= 0 || q.indexOf("导航") >= 0)
            return qsTr("左侧是首页、项目、设置三个导航。选中项用 accent 高亮，底部是主题切换和工作区信息。")
        if (q.indexOf("你好") >= 0 || q.indexOf("hello") >= 0 || q.indexOf("hi") >= 0)
            return qsTr("你好！我是本地模拟助手，可以聊聊这个 Dashboard 的用法。")
        if (q.indexOf("帮助") >= 0 || q.indexOf("怎么用") >= 0)
            return qsTr("在下面输入问题并发送。我会模拟一段回复（未接真实模型），方便你看对话流和气泡布局。")
        return qsTr("（模拟回复）已收到：「%1」。这是本地占位回答，还没有接入真实模型。").arg(userText)
    }

    // 消息气泡：AI 靠左 muted，用户靠右 primary
    component MessageBubble: Item {
        id: bubble

        required property string role
        required property string text

        readonly property bool isUser: role === "user"

        height: bubbleRect.height

        Rectangle {
            id: bubbleRect
            width: Math.min(bubbleText.implicitWidth + 24, bubble.width * 0.78)
            height: bubbleText.implicitHeight + 20
            radius: theme.radius
            color: bubble.isUser ? theme.primary : theme.muted
            x: bubble.isUser ? bubble.width - width : 0

            Text {
                id: bubbleText
                anchors.centerIn: parent
                width: parent.width - 24
                text: bubble.text
                color: bubble.isUser ? theme.primaryForeground : theme.foreground
                font.pixelSize: 13
                wrapMode: Text.Wrap
            }
        }
    }
}
