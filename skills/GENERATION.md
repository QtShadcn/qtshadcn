# Skills Generation Information

This document describes how the QtShadcn skills were generated and how to keep them synchronized with the codebase.

## Generation Details

**Generated from:**
- 项目源码：`src/qml/Components/*`、`src/core/*`、`examples/showcase/`
- 文档：`docs/content/2.components/*`（组件用法）、工作记忆（开发坑）
- 日期：2026-08-19
- 参考格式：slidev 的 `skills/`（SKILL.md 表格索引 + references 分类参考）

## Structure

```
skills/
├── GENERATION.md               # 本文件
└── qtshadcn/
    ├── SKILL.md                # 表格索引：所有组件 / 主题 / 构建 / 流程
    ├── README.md
    └── references/             # 分类详细参考
```

## File Naming Convention

References 按类别前缀命名：

- `core-*` —— 核心能力（theme / build / workflow / icon）
- `component-*` —— 组件类（button / form / display / overlay / navigation）

## 同步约定

新增组件时，需同步更新：

1. `SKILL.md` 的 Feature Reference 表格（加一行）
2. 对应 `component-*.md` reference（补该组件的用法/属性/坑）
3. 若有新开发坑，补进 `SKILL.md` 的「关键坑」表 + 相关 reference
4. 组件规范对齐基准变化（如 Base UI DOM）时，更新 `core-workflow.md`
