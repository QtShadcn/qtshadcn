---
name: icon
description: QtShadcn lucide 图标系统：IconRegistry（C++ singleton）与 ShadcnIcon，本地 74 精选 + 远程兜底 + 随主题变色。
---

# Icon 系统

C++ `IconRegistry`（QML singleton）+ QML `ShadcnIcon`。本地精选 74 个 lucide 图标打包进 .qrc，未命中按需从 CDN 拉取并缓存；`currentColor` 动态替换实现随主题变色。

## 用法

```qml
// 基础：默认跟随主题正文色
ShadcnIcon { name: "check"; size: 16 }

// 指定颜色（随主题切换自动刷新）
ShadcnIcon { name: "trash-2"; color: theme.destructive }

// 按钮内嵌图标
ShadcnButton { text: qsTr("删除"); iconName: "trash-2" }
```

## ShadcnIcon 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `name` | string | 图标名（lucide 命名，见 `IconRegistry.names`） |
| `size` | int | 显示尺寸（默认 24 = lucide 设计尺寸） |
| `color` | color | 颜色（默认 `theme.foreground`） |

## IconRegistry（QML singleton）

| 成员 | 说明 |
|------|------|
| `names` | 已注册图标名列表（本地内置，QML 里可直接当 model） |
| `has(name)` | 本地是否内置 |
| `dataUrl(name, color)` | 生成 `data:image/svg+xml;base64`（替换 currentColor 后内联） |
| `remoteEnabled` | 远程兜底开关（默认 true，企业内网可关） |
| `iconReady(name)` | 远程图标下载完成信号（ShadcnIcon 内部监听刷新） |

## 实现要点

- **本地**：74 个 lucide 图标（`src/assets/icons/*.svg`），qrc 打包（`qt_add_resources` + GLOB 自动包含），零延迟 / 离线可用
- **远程兜底**：未命中从 `unpkg.com/lucide-static` 拉取 → 内存 + 磁盘缓存（拉过一次离线可用）
- **变色**：渲染时把 svg 的 `currentColor` 替换为请求颜色 → data URL 内联，随主题/状态动态变色
- **为什么 data URL 而非 ImageProvider**：Qt 6.5+ `qmlRegisterTypesAndRevisions` 不调用 QML_SINGLETON 的 create()，QQuickImageProvider 注册不生效；data URL 绕开且能力等价
- **新增图标**：svg 放进 `src/assets/icons/` 即可（构建自动打包）

## 品牌图标注意

- lucide 新版已移除品牌图标（github 等）→ 远程 404；如需用，从 lucide 旧版（如 0.263.0）拉取描边风格存本地
