# QtShadcn Skills

给 AI 编码助手使用的项目参考，格式对齐 [slidev/skills](https://github.com/slidevjs/slidev/tree/main/skills)。根据角色分两类：

## ① 使用者 —— 把库接入自己的工程、用组件写业务

适用：消费方开发者 + 其 AI 助手，目标是快速接库并用组件搭界面。

- [`SKILL.md`](SKILL.md) —— 入口：定位、消费方脚手架铁律、组件索引、关键坑
- [`references/core-build.md`](references/core-build.md) —— 本库构建 + 消费方最小工程（CMake / `main.cpp` / Makefile）
- `references/` —— 主题、图标、各组件用法

**使用**：先读 `SKILL.md` → vendor 到 `third_party/qtshadcn`，再读 `references/core-build.md` 落地 CMake + 根 Makefile → 按需打开对应组件 reference。

## ② 开发组件 —— 扩展本库、新增 / 修改组件

适用：需要扩展 QtShadcn 本身的贡献者 + 其 AI 助手，目标是按规范新增组件并同步文档与截图。

- [`references/core-workflow.md`](references/core-workflow.md) —— 组件开发全流程：抓 shadcn 参考 → 列对照表 → 实现 → showcase 验证 → 关 Issue → 「新增组件后必做」清单
- 人读版流程：[`docs/content/4.development/1.component-workflow.md`](../../../docs/content/4.development/1.component-workflow.md)

**使用**：先读 `core-workflow.md` → 按清单新增 `ShadcnXxx` 组件 → 在 showcase 加演示页 → 更新组件索引。
