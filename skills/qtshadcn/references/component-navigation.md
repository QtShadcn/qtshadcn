---
name: navigation-components
description: ShadcnTabs（List / Trigger / Content，default / line 双 variant）用法。
---

# ShadcnTabs（M3）

基于 QQC.TabBar + TabButton（Basic style），`default`（胶囊底容器）与 `line`（下划线指示器）双 variant。

## 用法

```qml
Column {
    spacing: theme.spacingMd

    ShadcnTabsList {
        id: tabs
        variant: "default"   // "default" | "line"
        ShadcnTabsTrigger { text: qsTr("账户") }
        ShadcnTabsTrigger { text: qsTr("密码") }
    }
    StackLayout {
        currentIndex: tabs.currentIndex
        ShadcnTabsContent { Text { text: qsTr("账户内容") } }
        ShadcnTabsContent { Text { text: qsTr("密码内容") } }
    }
}
```

## 组件

| 组件 | 说明 |
|------|------|
| `ShadcnTabsList` | 容器；`variant` default（bg-muted 圆角）/ line（透明底）；暴露 `currentIndex` |
| `ShadcnTabsTrigger` | 标签项；default 选中白底、line 选中 2px 下划线 |
| `ShadcnTabsContent` | 内容项（配合外部 StackLayout 绑定 `currentIndex`） |

- 键盘左右切换（QQC TabBar 行为）
- 结构重构：List 只含 Trigger（不嵌套 Content），Content 由外部 StackLayout 管理
