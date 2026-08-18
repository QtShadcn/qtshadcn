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

    // ── 形状与间距 ─────────────────────────────
    readonly property int radius: ThemeManager.tokens["radius"]
    readonly property int spacingXs: ThemeManager.tokens["spacingXs"]
    readonly property int spacingSm: ThemeManager.tokens["spacingSm"]
    readonly property int spacingMd: ThemeManager.tokens["spacingMd"]
    readonly property int spacingLg: ThemeManager.tokens["spacingLg"]
    readonly property int spacingXl: ThemeManager.tokens["spacingXl"]
}
