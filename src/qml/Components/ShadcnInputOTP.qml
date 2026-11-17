pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui 风格验证码输入（Input OTP）
//
// 结构：一个**透明的 TextField** 承接全部键盘输入（键入 / 粘贴 / 退格 / 输入法），
// 文本按字符自绘到 N 个格子里。字符分发、超长截断都只是「监听 text 变化」这一个动作，
// 不需要自己维护「当前在哪一格」的状态机。
//
// 为什么不用「每格一个 TextField」：焦点会在格子间跳转，粘贴只落在获得焦点的那个
// field 上（只会填一格），退格要手写跳格逻辑，输入法组字更是无从下手 —— 浏览器里
// input-otp 正是用「单个 input + 自绘 slot」解决的，Qt 侧照搬同一套结构最稳。
//
// 规范对齐 shadcn input-otp（base-nova）：
// - 每格 size-8 = 32×32，border-input，文本 text-sm/14px 居中
// - 首格 rounded-l-lg（topLeft/bottomLeft = theme.radiusLg）+ 左边框；末格 rounded-r-lg
//   + 右边框；中间格无圆角、只有右边框 → 整体读作「一个圆角矩形被竖线切成 N 格」
// - 选中格（光标所在格）：border-ring + 3px 外环（与 ShadcnInput 的聚焦环一致）
// - 空格子上有 1px 闪烁光标（shadcn 的 fake caret）
// - disabled: opacity 50%
//
// 用法:
//   ShadcnInputOTP {
//       length: 6
//       onCompleted: value => console.log("填满:", value)
//   }
Item {
    id: root

    QtShadcnTheme { id: theme }

    // ── API ──
    // 格子数 = 字符数上限
    property int length: 6
    // 当前值。超长写入会被截断到 length（粘贴整段时由 textChanged 兜住）
    property alias text: input.text
    // 当前光标所在格（未聚焦 / 已填满光标停在末尾时为 -1）
    property int activeIndex: -1
    // 填满时发出，参数为完整值
    signal completed(string value)

    // 每格 32px（shadcn size-8）
    readonly property int slotSize: 32

    // 字符数（text 为空/别名尚未解析时给 0，避免子项绑定里读 undefined.length）
    readonly property int charCount: input && input.text ? input.text.length : 0

    implicitWidth: length * slotSize
    implicitHeight: slotSize
    activeFocusOnTab: true
    // 禁用态：opacity 50%（shadcn disabled:opacity-50）
    opacity: enabled ? 1 : 0.5

    // 取第 index 格的字符（越界给空串，供外部/测试读格子内容）
    function slotChar(index) {
        if (index < 0 || index >= root.charCount)
            return ""
        return root.text.charAt(index)
    }

    // 取第 index 格的对象（几何/圆角断言用；Repeater.itemAt）
    function slotItem(index) {
        return slotRepeater.itemAt(index)
    }

    // 「刚好填满」是否已经发过 completed：置满才发、退格后重置
    property bool _completedFired: false

    // text 变化（键入 / 粘贴 / 退格 / 程序写入）后统一处理：
    // 超长截断 + 恰好填满时发 completed。
    // 不用 readonly 绑定做这两件事：绑定可能在子项实例化前求值（ShadcnTextarea 的教训）
    function _normalizeText() {
        if (!input)
            return
        if (input.text.length > root.length) {
            // 超长（典型场景：粘贴一整段验证码）→ 截断到 length。
            // 赋值本身会再触发一轮 textChanged，由那一轮负责 completed。
            var clipped = input.text.substring(0, root.length)
            input.text = clipped
            if (input.cursorPosition > clipped.length)
                input.cursorPosition = clipped.length
            return
        }
        if (root.length > 0 && input.text.length >= root.length) {
            if (!root._completedFired) {
                root._completedFired = true
                root.completed(root.text)
            }
        } else {
            root._completedFired = false
        }
    }

    function _syncActiveIndex() {
        if (!input) {
            root.activeIndex = -1
            return
        }
        var caret = input.cursorPosition
        root.activeIndex = (root.enabled && input.activeFocus && caret >= 0 && caret < root.length)
                           ? caret : -1
    }

    onLengthChanged: {
        // 缩短 length 时把已有文本裁掉，并允许重新触发 completed
        root._completedFired = false
        root._normalizeText()
        root._syncActiveIndex()
    }
    onEnabledChanged: root._syncActiveIndex()

    // root.forceActiveFocus() 要落到内部 TextField 上：键盘输入其实在它身上，
    // 只给 root 焦点既收不到字符、也不会亮聚焦环
    onActiveFocusChanged: {
        if (root.activeFocus && input)
            input.forceActiveFocus()
    }

    // ── 承接键盘输入的隐藏 TextField（声明在最前：text 别名在 Repeater 之前就位）──
    // 视觉全部由格子自绘，这里只负责文本缓冲（IME / 粘贴 / 退格 / 选中），
    // 故透明且只占 1×1。点击由最上层的 MouseArea 转成 forceActiveFocus。
    TextField {
        id: input
        objectName: "input"

        width: 1
        height: 1
        opacity: 0
        color: theme.foreground
        font.pixelSize: 14

        // 只用 onTextChanged：TextInput 的 textEdited 在 Qt 6.8 上不存在
        // （见 .qmllint.ini 里那条 CI 踩坑记录）；textChanged 在 6.5–6.11 全版本可用
        onTextChanged: root._normalizeText()

        onActiveFocusChanged: root._syncActiveIndex()
        onCursorPositionChanged: root._syncActiveIndex()
    }

    // ── 格子 ──
    Repeater {
        id: slotRepeater
        model: root.length

        delegate: Rectangle {
            id: slot
            required property int index

            objectName: "slot"

            readonly property bool _first: slot.index === 0
            readonly property bool _last: slot.index === root.length - 1
            readonly property bool _active: root.activeIndex === slot.index

            x: slot.index * root.slotSize
            y: 0
            width: root.slotSize
            height: root.slotSize

            // 圆角只出现在整条的外侧两端：首格左侧、末格右侧，中间格为 0。
            // （几何断言锁住「整体是一个圆角矩形」，而不是 N 个独立小方块）
            topLeftRadius: slot._first ? theme.radiusLg : 0
            bottomLeftRadius: slot._first ? theme.radiusLg : 0
            topRightRadius: slot._last ? theme.radiusLg : 0
            bottomRightRadius: slot._last ? theme.radiusLg : 0

            color: Qt.rgba(theme.input.r, theme.input.g, theme.input.b, 0.5)   // bg-input/50
            // 首/末格用整圈 border 撑出外侧圆角（Rectangle 不支持分边 border，
            // 分边时描边会被裁成直角）；中间格 border.width 0，改用 1px 线描边
            border.width: slot._first || slot._last ? 1 : 0
            border.color: slot._active ? theme.ring : theme.input

            // 选中格浮到最上层：否则相邻格会盖掉它的描边与聚焦环
            z: slot._active ? 10 : 0

            // 中间格的上 / 下 / 右边框（逐条自绘，避免相邻格叠出 2px 双线）
            Rectangle {
                objectName: "slotEdgeTop"
                visible: !slot._first && !slot._last
                x: 0
                y: 0
                width: parent.width
                height: 1
                color: slot._active ? theme.ring : theme.input
            }
            Rectangle {
                objectName: "slotEdgeBottom"
                visible: !slot._first && !slot._last
                x: 0
                y: parent.height - 1
                width: parent.width
                height: 1
                color: slot._active ? theme.ring : theme.input
            }
            Rectangle {
                objectName: "slotEdgeRight"
                visible: !slot._first && !slot._last
                x: parent.width - 1
                y: 0
                width: 1
                height: parent.height
                color: slot._active ? theme.ring : theme.input
            }

            // 字符（text-sm / foreground，居中）
            Text {
                objectName: "slotCharText"
                anchors.centerIn: parent
                visible: slot.index < root.charCount
                text: slot.index < root.charCount ? root.text.charAt(slot.index) : ""
                color: theme.foreground
                font.pixelSize: 14
            }

            // 空格子上的闪烁光标（shadcn fake caret：h-4 w-px bg-foreground）
            Rectangle {
                id: caret
                objectName: "slotCaret"
                anchors.centerIn: parent
                visible: slot._active && slot.index >= root.charCount
                width: 1
                height: 16
                color: theme.foreground

                SequentialAnimation on opacity {
                    running: caret.visible
                    loops: Animation.Infinite
                    NumberAnimation { from: 1; to: 0; duration: 500 }
                    NumberAnimation { from: 0; to: 1; duration: 500 }
                }
            }

            // 选中格聚焦环：3px 外环（与 ShadcnInput 的聚焦环一致）
            Rectangle {
                objectName: "slotRing"
                anchors.fill: parent
                anchors.margins: -3
                visible: slot._active
                color: "transparent"
                border.width: 3
                border.color: Qt.rgba(theme.ring.r, theme.ring.g, theme.ring.b, 0.3)

                topLeftRadius: slot.topLeftRadius > 0 ? slot.topLeftRadius + 3 : 0
                bottomLeftRadius: slot.bottomLeftRadius > 0 ? slot.bottomLeftRadius + 3 : 0
                topRightRadius: slot.topRightRadius > 0 ? slot.topRightRadius + 3 : 0
                bottomRightRadius: slot.bottomRightRadius > 0 ? slot.bottomRightRadius + 3 : 0
            }
        }
    }

    // 点击任意位置聚焦输入框（光标落到末尾，键入即追加）
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        onClicked: {
            input.forceActiveFocus()
            input.cursorPosition = Math.min(root.text.length, root.length)
            input.deselect()
        }
    }
}
