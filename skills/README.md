# QtShadcn Skills

给 AI 编码助手使用的项目参考，格式对齐 [slidev/skills](https://github.com/slidevjs/slidev/tree/main/skills)。按**读者角色**拆成两个 skill：

## ① [`qtshadcn`](qtshadcn/SKILL.md) —— 使用者：把库接入自己的工程、用组件写业务

适用：消费方开发者 + 其 AI 助手。

- [`qtshadcn/SKILL.md`](qtshadcn/SKILL.md) —— 入口：定位、接入铁律、组件索引（M2–M6 全表）、使用坑
- [`qtshadcn/references/consumer/build.md`](qtshadcn/references/consumer/build.md) —— 消费方最小工程（CMake / `main.cpp` / Makefile / `QML_IMPORT_PATH`）
- [`qtshadcn/references/common/`](qtshadcn/references/common/) —— 主题（`core-theme`）、图标（`core-icon`）
- [`qtshadcn/references/consumer/component-*.md`](qtshadcn/references/consumer/) —— 各组件用法：button / form / display / navigation / overlay / feedback

**使用**：先读 `qtshadcn/SKILL.md` → vendor 到 `third_party/qtshadcn`，再读 `references/consumer/build.md` 落地 CMake + 根 Makefile → 按需打开对应组件 reference。

## ② [`qtshadcn-dev`](qtshadcn-dev/SKILL.md) —— 库开发：扩展本库、新增 / 修改组件

适用：扩展 QtShadcn 本身的贡献者 + 其 AI 助手。

- [`qtshadcn-dev/SKILL.md`](qtshadcn-dev/SKILL.md) —— 入口：组件开发铁律（先抓 shadcn 参考 → 对照表 → 确认）、架构要点、开发坑、新增组件后必做
- [`qtshadcn-dev/references/workflow.md`](qtshadcn-dev/references/workflow.md) —— 组件开发全流程：抓 shadcn 参考 → 列对照表 → 实现 → showcase 验证 → 关 Issue
- [`qtshadcn-dev/references/build.md`](qtshadcn-dev/references/build.md) —— 本仓库构建 / 静态验证 / 截图 / showcase 结构
- [`qtshadcn-dev/references/m6-compliance-fix.md`](qtshadcn-dev/references/m6-compliance-fix.md) —— M6 七组件对齐修复记录与遗留修正项
- 人读版流程：[`docs/content/4.development/1.component-workflow.md`](../docs/content/4.development/1.component-workflow.md)

**使用**：先读 `qtshadcn-dev/references/workflow.md` → 按清单新增 `ShadcnXxx` 组件 → 在 showcase 加演示页 → 同步两个 skill。

## 边界与单一来源

| 内容 | 归属 |
|------|------|
| 接入库 / 用组件写业务 / 消费方构建 | `qtshadcn` |
| 改库内组件 / token / showcase / 文档截图 / 发布 | `qtshadcn-dev` |
| 主题与 token 契约（`ThemeManager` / `QtShadcnTheme`） | `qtshadcn/references/common/core-theme.md`（**单一来源**，dev skill 只做交叉引用，不复制） |
| 通用「shadcn/ui → QML」移植方法论 | 个人 Hermes skill `qml-component-library-dev`（不入本仓库） |

结构变更见 [`GENERATION.md`](GENERATION.md)。
