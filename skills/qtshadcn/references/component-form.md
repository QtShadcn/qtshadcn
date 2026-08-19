---
name: form-components
description: ShadcnInput / InputGroup / Textarea / Checkbox / RadioGroup / Switch / Slider / Progress / Select 用法、属性与坑。
---

# 表单控件（M3）

## ShadcnInput

```qml
ShadcnInput { width: 320; placeholderText: qsTr("请输入"); echoMode: TextInput.Password }
```

- 基于 QQC.TextField（Basic），h-9(36px) + 6px 圆角 + `bg-input/50`
- 聚焦：border 切 ring + 3px 外环（ring 30%）；placeholder mutedForeground；disabled opacity 50%

## ShadcnInputGroup

```qml
ShadcnInputGroup { prefixIcon: "search"; placeholderText: "搜索..." }
ShadcnInputGroup { prefixText: "￥"; placeholderText: "金额" }
ShadcnInputGroup { suffixIcon: "chevron-down" }
```

- `prefixIcon`/`suffixIcon`（lucide 名，16px mutedForeground）或 `prefixText`/`suffixText`
- 有 addon 时 padding 自动让位；聚焦整框（含 addon）一起 ring

## ShadcnTextarea

```qml
ShadcnTextarea { width: 340; placeholderText: "输入..."; maxHeight: 150 }  // 超高内部滚动
ShadcnTextarea { maxHeight: 0 }   // 不限高（随内容增高）
```

- **Flickable + TextEdit + ScrollBar 实现**（不用 QQC.TextArea：其内部无 Flickable、TextEdit 原生不响应滚轮）
- 高度 = `max(64, min(自然高, maxHeight))`；`maxHeight` 默认 200
- placeholder 自绘（TextEdit 的 placeholderText 是 FINAL 不能 alias，且无 placeholderTextColor）
- 坑：contentHeight 早期 undefined→NaN 拖垮组件（用 `> 0` 兜底）；`onTextEdited` 信号参数 editedText 在 qmlcache 下不可用（用 `text` 转发）

## ShadcnCheckbox

```qml
ShadcnCheckbox { text: "同意条款"; checked: true }
```

- 16px 方框 + rounded 5px + `bg-input/90`；选中 `bg-primary` + check 图标；focus ring
- **坑**：override indicator 必须自带 x/y（模板定位不自动应用），否则方框停在 (0,0) 与文本错位

## ShadcnRadio / ShadcnRadioGroup

```qml
ShadcnRadioGroup {
    ShadcnRadio { text: "默认主题"; checked: true }
    ShadcnRadio { text: "蓝色主题" }
}
```

- 16px 正圆 + `bg-input/90`；选中 primary 底 + 8px primaryForeground 内圆点
- 组内互斥 ButtonGroup（exclusive），方向键切换；override indicator 同样要自带 x/y

## ShadcnSwitch

```qml
ShadcnSwitch { checked: true }                          // Default 44×20 + 24×16 滑块
ShadcnSwitch { size: ShadcnSwitch.Size.Small }          // Small 28×16 + 16×12 滑块
```

- checked `bg-primary` + 2px primary 边框 + 滑块居右；unchecked `bg-input/90`；focus 3px 外环

## ShadcnSlider

```qml
ShadcnSlider { width: 360; from: 0; to: 100; value: 40 }
ShadcnSlider { height: 30; trackThickness: 6 }   // 自定义高度/轨道厚
```

- **对齐 Base UI 默认**（用户贴 DOM 为权威）：track 4px `bg-muted` 胶囊撑满；range `bg-primary`；thumb 12px 正圆 `bg-white` + `border border-ring`，中心对齐（端点半露），hover/focus ring-3 `ring-ring/50`
- **坑**：QQC Basic Slider 默认 `padding:6` 会把 track 缩进（两侧空白）→ `padding: 0`；override background 也要自带 x/y/width；整体高度 18 = thumb 12 + ring 3×2

## ShadcnProgress

```qml
ShadcnProgress { width: 360; value: 0.6 }                      // 0..1
ShadcnProgress { width: 360; value: 0.3; showValue: true }     // 显示百分比
```

- 12px `bg-muted` 轨道 + `bg-primary` 指示条（宽度 200ms 动画）

## ShadcnSelect

```qml
ShadcnSelect { model: ["苹果", "香蕉", "橙子"]; onActivated: (i) => console.log(currentText) }
ShadcnSelect { size: ShadcnSelect.Size.Sm; model: ["S", "M", "L"] }
```

- 基于 QQC.ComboBox（Basic）：trigger `bg-input/50` + 6px 圆角 + 左右 12px padding + chevron-down；弹层 `bg-popover` + ring + shadow，item hover accent + 选中 check
- **坑**：① QQC 默认 indicator（double-arrow.png）要 `indicator: Item { visible: false }` 隐藏（否则双箭头）；② 左右 padding 用 `leftPadding/rightPadding:12`，**不能四边 `padding:12`**（上下 12 会让 contentItem 高只剩 12px 挤压）；③ delegate contentItem 用 anchors 不用 RowLayout（垂直居中可靠）
