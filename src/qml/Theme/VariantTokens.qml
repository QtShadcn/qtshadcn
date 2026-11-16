import QtQuick

// variant → Design Token 名映射表（模块级共享，组件查表用）
//
// 设计要点：
// - 存 token 名（string）而非颜色值：组件经 theme.tokens[名字] 查询，
//   保持绑定依赖，mode 切换时自动刷新（直接存颜色值会变成静态值，不随主题变）
// - 数组下标 = 枚举值（与 ShadcnButton.Variant 顺序对齐）
// - 新增 variant：枚举加一项 + 此处加一项（保持顺序一致）
// - 元素类型统一为 VariantSpec（具名类型）：内联 QtObject 会让
//   `vt.button[i].bg` / `vt.checkedOverride.fg` 这类访问在 qmllint 里被误判为
//   missing-property，且字段名拼错无法在静态阶段发现
// - 注意：数组里仍放属性引用（primary/secondary/...），不写字面量——
//   模块 qmlcache 预编译下，数组内直接声明对象不可靠
QtObject {
    // ── ShadcnButton / ShadcnToggle 各 variant 定义 ──
    // bg 为空字符串 = 透明背景；hoverMix 默认 0.1（见 VariantSpec）
    readonly property VariantSpec primary: VariantSpec {
        bg: "primary"
        fg: "primaryForeground"
    }
    readonly property VariantSpec secondary: VariantSpec {
        bg: "secondary"
        fg: "secondaryForeground"
        hoverMix: 0.2
    }
    readonly property VariantSpec outline: VariantSpec {
        fg: "foreground"
        border: true
    }
    readonly property VariantSpec ghost: VariantSpec {
        fg: "foreground"
    }
    readonly property VariantSpec destructive: VariantSpec {
        bg: "destructive"
        fg: "destructiveForeground"
    }
    readonly property VariantSpec link: VariantSpec {
        fg: "primary"
    }

    // 枚举值索引数组（0 Primary / 1 Secondary / 2 Outline / 3 Ghost / 4 Destructive / 5 Link）
    readonly property var button: [primary, secondary, outline, ghost, destructive, link]

    // ── ShadcnBadge 各 variant 定义 ──
    // 与 Button 区别：destructive 用 v4 新风格「bg-destructive/10 透明底 + 红字」
    readonly property VariantSpec badgeDefault: VariantSpec {
        bg: "primary"
        fg: "primaryForeground"
    }
    readonly property VariantSpec badgeSecondary: VariantSpec {
        bg: "secondary"
        fg: "secondaryForeground"
    }
    readonly property VariantSpec badgeDestructive: VariantSpec {
        bg: "destructive"
        fg: "destructive"
        bgAlpha: 0.10   // v4: bg-destructive/10
    }
    readonly property VariantSpec badgeOutline: VariantSpec {
        fg: "foreground"
        border: true
        borderToken: "border"
    }
    readonly property VariantSpec badgeGhost: VariantSpec {
        fg: "foreground"
    }
    readonly property VariantSpec badgeLink: VariantSpec {
        fg: "primary"
    }

    // 枚举值索引数组（0 Default / 1 Secondary / 2 Destructive / 3 Outline / 4 Ghost / 5 Link）
    readonly property var badge: [badgeDefault, badgeSecondary, badgeDestructive, badgeOutline, badgeGhost, badgeLink]

    // checkable && checked 时的覆盖（Toggle 选中态）
    readonly property VariantSpec checkedOverride: VariantSpec {
        bg: "accent"
        fg: "accentForeground"
    }
}
