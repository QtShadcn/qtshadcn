import QtQuick

// variant → Design Token 名映射表（模块级共享，组件查表用）
//
// 设计要点：
// - 存 token 名（string）而非颜色值：组件经 theme.tokens[名字] 查询，
//   保持绑定依赖，mode 切换时自动刷新（直接存颜色值会变成静态值，不随主题变）
// - 数组下标 = 枚举值（与 ShadcnButton.Variant 顺序对齐）
// - 新增 variant：枚举加一项 + 此处加一项（保持顺序一致）
// - 注意：元素用属性引用而非 var 对象字面量（模块 qmlcache 预编译下
//   数组内对象字面量/QtObject 声明不可靠，纯标识符数组最稳）
QtObject {
    // ── ShadcnButton / ShadcnToggle 各 variant 定义 ──
    // bg/fg 为 token 名；bg 为空字符串 = 透明背景
    // hoverMix：hover 时按钮色向页面背景混合的比例（对齐 shadcn：
    //   primary/destructive hover:bg-*/90 → 0.1；secondary hover:bg-secondary/80 → 0.2）
    readonly property QtObject primary: QtObject {
        property string bg: "primary"
        property string fg: "primaryForeground"
        property bool border: false
        property real hoverMix: 0.1
    }
    readonly property QtObject secondary: QtObject {
        property string bg: "secondary"
        property string fg: "secondaryForeground"
        property bool border: false
        property real hoverMix: 0.2
    }
    readonly property QtObject outline: QtObject {
        property string bg: ""
        property string fg: "foreground"
        property bool border: true
        property real hoverMix: 0.1
    }
    readonly property QtObject ghost: QtObject {
        property string bg: ""
        property string fg: "foreground"
        property bool border: false
        property real hoverMix: 0.1
    }
    readonly property QtObject destructive: QtObject {
        property string bg: "destructive"
        property string fg: "destructiveForeground"
        property bool border: false
        property real hoverMix: 0.1
    }
    readonly property QtObject link: QtObject {
        property string bg: ""
        property string fg: "primary"
        property bool border: false
        property real hoverMix: 0.1
    }

    // 枚举值索引数组（0 Primary / 1 Secondary / 2 Outline / 3 Ghost / 4 Destructive / 5 Link）
    readonly property var button: [primary, secondary, outline, ghost, destructive, link]

    // checkable && checked 时的覆盖（Toggle 选中态）
    readonly property QtObject checkedOverride: QtObject {
        property string bg: "accent"
        property string fg: "accentForeground"
    }
}
