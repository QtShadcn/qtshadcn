import QtQuick
import QtShadcn

// 声明式主题入口：薄封装，把 C++ ThemeManager 的 token 字典
// 映射成语义化属性，组件直接绑定：
//   QtShadcnTheme { id: theme }
//   Rectangle { color: theme.primary; radius: theme.radius }
// 切换：theme.mode = "dark" → 全局随动
QtObject {
    id: root

    // 双向绑定 mode：初始读 ThemeManager，赋值时写回
    property string mode: ThemeManager.mode
    onModeChanged: {
        if (root.mode !== ThemeManager.mode)
            ThemeManager.mode = root.mode
    }

    // 原始 token 字典（供动态索引，如 theme.tokens["primary"]）
    readonly property var tokens: ThemeManager.tokens

    // ── 颜色语义 ──────────────────────────────
    readonly property color background:            ThemeManager.tokens["background"]
    readonly property color foreground:            ThemeManager.tokens["foreground"]
    readonly property color primary:               ThemeManager.tokens["primary"]
    readonly property color primaryForeground:     ThemeManager.tokens["primaryForeground"]
    readonly property color secondary:             ThemeManager.tokens["secondary"]
    readonly property color secondaryForeground:   ThemeManager.tokens["secondaryForeground"]
    readonly property color muted:                 ThemeManager.tokens["muted"]
    readonly property color mutedForeground:       ThemeManager.tokens["mutedForeground"]
    readonly property color accent:                ThemeManager.tokens["accent"]
    readonly property color accentForeground:      ThemeManager.tokens["accentForeground"]
    readonly property color destructive:           ThemeManager.tokens["destructive"]
    readonly property color destructiveForeground: ThemeManager.tokens["destructiveForeground"]
    readonly property color border:                ThemeManager.tokens["border"]
    readonly property color ring:                  ThemeManager.tokens["ring"]
    // M3: card / input / popover 系列
    readonly property color card:                  ThemeManager.tokens["card"]
    readonly property color cardForeground:        ThemeManager.tokens["cardForeground"]
    readonly property color input:                 ThemeManager.tokens["input"]
    readonly property color popover:               ThemeManager.tokens["popover"]
    readonly property color popoverForeground:     ThemeManager.tokens["popoverForeground"]
    // M6: warning / success（Alert 项目扩展）
    readonly property color warning:               ThemeManager.tokens["warning"]
    readonly property color warningForeground:     ThemeManager.tokens["warningForeground"]
    readonly property color success:               ThemeManager.tokens["success"]
    readonly property color successForeground:     ThemeManager.tokens["successForeground"]

    // ── 形状与间距 ─────────────────────────────
    // radius 是基底（shadcn 的 --radius）。v4 的 rounded-* 不是 Tailwind 默认刻度，
    // 而是从 --radius 派生（apps/v4/app/globals.css 的 @theme inline）：
    //   sm ×0.6 / md ×0.8 / lg ×1.0 / xl ×1.4 / 2xl ×1.8 / 3xl ×2.2 / 4xl ×2.6
    // 因此组件不写死圆角像素，一律用下面这几个派生值——改 theme.radius 全体跟动。
    readonly property int radius: ThemeManager.tokens["radius"]
    readonly property int radiusSm: Math.round(radius * 0.6)
    readonly property int radiusMd: Math.round(radius * 0.8)
    readonly property int radiusLg: radius                  // rounded-lg = --radius 本身
    readonly property int radiusXl: Math.round(radius * 1.4)
    readonly property int spacingXs: ThemeManager.tokens["spacingXs"]
    readonly property int spacingSm: ThemeManager.tokens["spacingSm"]
    readonly property int spacingMd: ThemeManager.tokens["spacingMd"]
    readonly property int spacingLg: ThemeManager.tokens["spacingLg"]
    readonly property int spacingXl: ThemeManager.tokens["spacingXl"]
}
