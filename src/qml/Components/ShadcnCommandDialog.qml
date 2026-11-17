pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// shadcn/ui CommandDialog —— 把 Command 装进 Dialog 的薄封装
//
// 官方 CommandDialog 就是 Dialog 的包装（核实 registry/base-nova/command.json）：
//   <Dialog>
//     <DialogHeader className="sr-only">Title + Description</DialogHeader>
//     <DialogContent className="top-1/3 translate-y-0 overflow-hidden rounded-xl! p-0"
//                    showCloseButton={false}>
//       {children}
//     </DialogContent>
//   </Dialog>
// 四件事：① 位置从垂直居中改成 top-1/3；② p-0（内容自己带 p-1）；
// ③ overflow-hidden + rounded-xl；④ **showCloseButton 默认 false**（面板靠
// Esc / 点外部关，右上角不放关闭钮）。
//
// ── 为什么复用 ShadcnDialog 而不是重写 ─────────────────────────
// 背景（bg-popover + rounded-xl + ring-1 ring-foreground/10）、遮罩
// （bg-black/10）、enter/exit（fade + zoom-95 / 100ms）、Esc 与点外部关闭
// 全都已经在 ShadcnDialog 里对齐好了。官方这里也只额外改了 4 个类，
// 照做即可 —— 重造一份 Dialog 会立刻产生两套会漂移的弹层实现。
//
// 实现手段是**派生 + anchors 覆盖**：ShadcnDialog 内部写死
// `anchors.centerIn: Overlay.overlay`，本组件在自己的声明里把它置 null 再给
// x / y。探针实测 Popup 的 anchors 只支持 centerIn（没有 horizontalCenter /
// verticalCenter / margins），且 `anchors.centerIn: null` 之后 x / y 可自由赋值
// 并在多次 open/close 后保持稳定 —— 所以这条路成立，不需要改 ShadcnDialog。
//
// 用法:
//   ShadcnCommandDialog {
//       id: palette
//       ShadcnCommand {
//           ShadcnCommandInput {}
//           ShadcnCommandList {
//               ShadcnCommandEmpty { text: "无匹配" }
//               ShadcnCommandGroup { heading: "建议"; ShadcnCommandItem { text: "新建" } }
//           }
//       }
//   }
//   Shortcut { sequence: "Ctrl+K"; onActivated: palette.open() }
ShadcnDialog {
    id: root

    /// sr-only 标题（官方 DialogTitle）。QQC Dialog 的 header 被基类隐藏，
    /// 这里保留属性是为了语义与无障碍名称，不占视觉空间。
    property string dialogTitle: qsTr("Command Palette")
    /// sr-only 描述（官方 DialogDescription）
    property string dialogDescription: qsTr("Search for a command to run...")

    /// 每次打开时清空上次的搜索词。
    /// ⚠ cmdk 自己不清（面板复用同一个 state）；Qt 侧默认清，因为桌面应用
    ///   的 ⌘K 习惯是「每次打开都是干净的」。不想清就设 false。
    property bool clearSearchOnOpen: true

    /// 内部 Command（Component.onCompleted 时从 contentItem 里认出来）
    property var command: null

    // ── registry 的 top-1/3 + translate-y-0 ────────────────────
    // 取消基类的 anchors.centerIn（见文件头探针结论：Popup 的 anchors 只支持
    // centerIn，没有 verticalCenter / margins），改成自己摆 x / y。
    //
    // ⚠ **必须先改 parent**。Popup 的 x / y 是相对**它的逻辑父项**的坐标，
    //   默认父项是「声明它的那个 Item」。面板写在 showcase 页面的 Column 里时，
    //   那个 Column 在 ScrollView 视口内还有自己的偏移，于是
    //   `y: Overlay.overlay.height / 3` 算的是 overlay 坐标、赋的却是 Column 坐标
    //   —— 实测面板整体向右下偏移了两百多像素（基类 ShadcnDialog 不会中这个枪，
    //   它用 anchors.centerIn，Popup 的 anchors 内部做了跨坐标系换算）。
    //   把父项显式设成 overlay，坐标系就与算式一致（库内 DropdownMenu 用
    //   `popup.parent = placement.frame` 是同一手法）。
    parent: Overlay.overlay
    anchors.centerIn: null
    x: Overlay.overlay ? Math.round((Overlay.overlay.width - width) / 2) : 0
    y: Overlay.overlay ? Math.round(Overlay.overlay.height / 3) : 0

    // registry: showCloseButton = false
    showCloseButton: false

    // DialogContent 的 p-0（基类已是 0）+ overflow-hidden：
    // 面板内容（Command 自带 rounded-xl + p-1）不能画到圆角外
    clip: true

    // 面板标题（无障碍名）。header 被基类隐藏，这里只设 accessible name，
    // 不让它参与布局。
    title: root.dialogTitle

    // ⚠ 用 aboutToShow 而不是 opened：opened 要等 enter 过渡跑完（100ms）才发，
    //   这期间面板已经画在屏幕上、搜索框还留着上次的词、焦点也没落进去
    //   —— 用户会看到一帧「脏」的面板。aboutToShow（Popup 的信号，Qt 6.0 起
    //   就有）在进入动画开始**之前**发，清理与聚焦都早于第一帧绘制。
    //   顺带避开 Dialog.opening —— 那是 Qt 6.9 才加的，本库 floor 是 6.8。
    onAboutToShow: {
        if (root.command) {
            if (root.clearSearchOnOpen)
                root.command.clearSearch();
            root.command.focusInput();
        }
    }

    // 把 contentItem 里的 Command 认出来：
    //   1. 存引用给 onOpened / 调用方
    //   2. 下发 inDialog = true（官方条目在 dialog-content 内圆角升一档 rounded-lg）
    // 沿用 ShadcnDialog 自己的做法（它也是遍历 contentItem.children 找
    // closeClicked 来连线的），不引入新机制。
    Component.onCompleted: {
        var kids = root.contentItem ? root.contentItem.children : [];
        for (var i = 0; i < kids.length; ++i) {
            var c = kids[i];
            if (c && typeof c.registerItem === "function") {
                root.command = c;
                c.inDialog = true;
                break;
            }
        }
    }
}
