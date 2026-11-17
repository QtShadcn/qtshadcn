import QtQuick

// 弹层通用过渡：淡入淡出 + 缩放到 0.95（对齐 shadcn 的 fade + zoom-95，duration-100）
//
// 用法（Popup / Dialog 的 enter / exit 都能直接赋值）：
//   enter: ShadcnFadeZoomTransition { shown: true }
//   exit:  ShadcnFadeZoomTransition { shown: false }
//
// 为什么做成组件而不是一段可复制的 Transition：ShadcnDialog / ShadcnDropdownMenu /
// ShadcnSelect 三处的 enter/exit 曾经**一字不差**地重复了 24 行。想统一调「弹层进场
// 时长」得改三处，漏一处就不一致 —— 这不是理论上的坏味道，是实际会发生的维护税。
//
// ── 一个 Qt 结构限制导致的 API 形状 ──────────────────────────────
//
// Transition 的默认属性 animations 只接受 Animation 派生类，**任何 QtObject
// 都放不进去**（QtShadcnTheme、甚至裸 QtObject 都会报 incompatible-type）。
// 所以不能像普通组件那样在里面挂一个 `QtShadcnTheme { id: theme }` 去读 token。
//
// 折中做法：时长与缓动做成**可写属性**，默认值取自 C++ ThemeManager 的
// reducedMotion 语义（通过 durationMs 的默认绑定）。调用方一般不用管；
// 需要统一调整时改 theme 的 motion token 后从外部传入，或直接用默认值。
//
// 为什么不干脆在这里读 ThemeManager：QML 单例可以直接引用（`ThemeManager.xxx`），
// 但 motion token 目前是 QtShadcnTheme 上的便捷属性而非 C++ token 字典成员，
// 单例里拿不到。若后续把 motion 下沉到 ThemeManager，这里可以简化成直接读。
Transition {
    id: root

    // true = 进场（0→1、0.95→1、OutCubic）
    // false = 退场（1→0、1→0.95、InCubic）
    property bool shown: true

    // 缩放起止幅度（shadcn 的 zoom-95 即 0.95）。个别场景想更夸张可覆盖
    property real zoomFrom: 0.95

    // 时长与缓动：默认对齐 shadcn 的 duration-100 + zoom-in/out 手感。
    // 覆盖示例：ShadcnFadeZoomTransition { shown: true; durationMs: 200 }
    property int durationMs: 100
    property int enterEasing: Easing.OutCubic
    property int exitEasing: Easing.InCubic

    // 无障碍：减弱动画时时长归零（等于瞬间切换）。
    // 与 QtShadcnTheme.reducedMotion 手动保持同步，默认关闭。
    property bool reducedMotion: false

    readonly property int _ms: reducedMotion ? 0 : durationMs

    animations: ParallelAnimation {
        NumberAnimation {
            property: "opacity"
            from: root.shown ? 0.0 : 1.0
            to: root.shown ? 1.0 : 0.0
            duration: root._ms
        }
        NumberAnimation {
            property: "scale"
            from: root.shown ? root.zoomFrom : 1.0
            to: root.shown ? 1.0 : root.zoomFrom
            duration: root._ms
            // 进场用 OutCubic（快进慢停），退场用 InCubic（慢起快走），
            // 与 shadcn 的 zoom-in / zoom-out 手感一致
            easing.type: root.shown ? root.enterEasing : root.exitEasing
        }
    }
}
