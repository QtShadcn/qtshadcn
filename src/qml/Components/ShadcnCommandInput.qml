pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui CommandInput —— 命令面板的搜索框
//
// 对齐 registry 的 CommandInput：外层 `p-1 pb-0`，里面是一个 InputGroup
//   h-8! rounded-lg! border-input/30 bg-input/30 shadow-none!
//   + 右侧 InputGroupAddon（search 图标，size-4 shrink-0 opacity-50）
//   + 内层 cmdk Input 是 `w-full text-sm outline-hidden`（透明无边框，靠组提供描边）
//
// ── Qt 侧简化到什么程度（核实后决定）───────────────────────────
// 官方这里绕了一层 InputGroup：InputGroup 提供边框/背景/聚焦环，
// InputGroupInput 自己把 border/bg 清成透明。Qt 侧没有「组向子项投射样式」的
// 机制，所以合成一个组件：ShadcnCommandInput 自己画 InputGroup 那一层的皮肤
// （h-8 / rounded-lg / border-input/30 / bg-input/30 / 聚焦 ring），
// 内部直接用一个透明边框的 TextField。
// 两处偏离，都注明：
//   1) 图标位置：registry 的 `InputGroupAddon` 不写 align → 走 cva 的
//      defaultVariants `align: "inline-start"`（`order-first pl-2`），
//      也就是**渲染在左侧**（虽然源码里 JSX 写在 Input 之后）。Qt 侧照官方
//      视觉结果放左侧 pl-2(8)，而不是照 JSX 顺序放右侧。
//   2) `bg-input/30` / `border-input/30` 是明暗两套的裸工具类（不在 .cn-* 表里），
//      这里的 alpha 走 theme.input 取色 + 0.3。
// 聚焦环对齐 has-[[data-slot=input-group-control]:focus-visible]:ring-3 ring-ring/50。
//
// ⌘ 与 ShadcnCommand 的联动：本组件把 text ↔ command.search 双向同步，
//   并在打开时接受 focus()（官方是 autofocus）。
//
// 用法:
//   ShadcnCommand {
//       ShadcnCommandInput { placeholderText: "输入命令或搜索…" }
//       ShadcnCommandList { ... }
//   }
Item {
    id: root

    /// 占位文案（cmdk 官方默认 "Type a command or search..."）
    property string placeholderText: qsTr("Type a command or search...")
    /// 当前输入值。与 command.search 双向同步。
    property alias text: field.text

    /// 同步闸门：两条路（用户输入 → search、search → 输入框）都会触发对方的
    /// onTextChanged，靠这个标志只放一层，避免互写回环。
    property bool _syncing: false
    /// 禁用输入框（cmdk 的 disabled）
    property alias inputEnabled: field.enabled
    /// 接受 Enter 时发出（ShadcnCommand 已经处理 Enter 执行选中项，
    /// 这里只是把 TextField.accepted 透出来给自定义逻辑用）
    signal accepted()

    /// 所属 ShadcnCommand（沿 parent 链解析）
    property var command: null

    implicitWidth: 340
    implicitHeight: 36   // p-1 pb-0(4 + 0) + h-8(32)

    QtShadcnTheme { id: theme }

    width: parent ? parent.width : implicitWidth

    // ── InputGroup 皮肤（h-8 + rounded-lg + border-input/30 + bg-input/30）──
    Rectangle {
        id: group
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 32                       // h-8
        radius: theme.radiusLg           // rounded-lg
        color: Qt.rgba(theme.input.r, theme.input.g, theme.input.b, 0.3)   // bg-input/30
        border.width: 1
        // 聚焦时整组 border-ring（has-[...:focus-visible]:border-ring）
        border.color: field.activeFocus ? theme.ring
                                        : Qt.rgba(theme.input.r, theme.input.g, theme.input.b, 0.3)
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: theme.radiusLg + 3
            visible: field.activeFocus
            color: "transparent"
            border.width: 3
            border.color: Qt.rgba(theme.ring.r, theme.ring.g, theme.ring.b, 0.5)
            Behavior on border.color { ColorAnimation { duration: theme.durationQuick } }
        }
    }

    // 左侧 search 图标（InputGroupAddon: pl-2 + size-4 + opacity-50）
    ShadcnIcon {
        id: searchIcon
        anchors.left: group.left
        anchors.leftMargin: 8            // pl-2
        anchors.verticalCenter: group.verticalCenter
        name: "search"
        size: 16                         // [&>svg]:size-4
        opacity: 0.5                     // opacity-50
        color: theme.mutedForeground     // text-muted-foreground
    }

    // 输入本体：cmdk 的 Input 是 w-full text-sm outline-hidden + 透明边框
    // （描边由 group 提供，这里不重复画，也避免「两层边框」）
    TextField {
        id: field
        objectName: "commandInputField"
        anchors.left: group.left
        anchors.right: group.right
        anchors.verticalCenter: group.verticalCenter
        leftPadding: 8 + 16 + 8          // pl-2 + 图标 16 + gap 8
        rightPadding: 12
        topPadding: 0
        bottomPadding: 0
        height: 30
        placeholderText: root.placeholderText
        text: ""
        color: theme.foreground
        placeholderTextColor: theme.mutedForeground
        font.pixelSize: 14               // text-sm
        selectByMouse: true
        persistentSelection: false
        background: Item {}              // outline-hidden：不画自己的边框
        // ⚠ Qt 6.8 的 TextField 没有 onTextEdited（textEdited 是 Qt 6.9 才加进
        //   Text 系的），所以一律用 textChanged。CI 在 6.8 上挂过一次。
        onTextChanged: {
            if (root._syncing)
                return;
            if (!root.command)
                return;
            root._syncing = true;
            if (root.command.search !== field.text)
                root.command.search = field.text;
            root._syncing = false;
        }
        onAccepted: root.accepted()
        // 禁用态：cursor-not-allowed + opacity-50
        opacity: field.enabled ? 1.0 : 0.5
    }

    Component.onCompleted: {
        root.command = root._resolveCommand(root.parent);
        if (root.command)
            root.command.registerInput(field, root);
    }

    // search 从外部被改写（宿主直接赋值 / clearSearch）时回灌输入框。
    //
    // ⚠ 为什么用显式 Connections 而不是 `text: command.search` 绑定：
    //   TextField 的 text 一旦被**命令式赋值**（宿主写 input.text、或测试里
    //   模拟输入），Qt 的 QML 语义就是「解绑」，此后 search 再怎么变都不会
    //   回灌 —— 表现为「search 与输入框各说各话」，而且只在特定操作序列后
    //   出现，极难查。显式同步没有「绑定已死」这个失效面（探针实测：
    //   命令式写一次后 `top.query="x"` 不再影响 text）。
    Connections {
        target: root.command

        function onSearchChanged() {
            if (root._syncing)
                return;
            if (!root.command)
                return;
            root._syncing = true;
            if (field.text !== root.command.search)
                field.text = root.command.search;
            root._syncing = false;
        }
    }

    /// 打开面板时聚焦输入框（官方 autofocus）。
    /// ⚠ 不能叫 focus() —— Item 已有 FINAL 的 focus() 方法，QML 里覆盖它会报
    ///   "Final member focus is overridden ... The override won't be used"（实测），
    ///   即静默失效。
    function focusSearch() {
        field.forceActiveFocus();
    }

    function _resolveCommand(from) {
        var p = from;
        while (p) {
            if (typeof p.registerItem === "function")
                return p;
            p = p.parent;
        }
        return null;
    }
}
