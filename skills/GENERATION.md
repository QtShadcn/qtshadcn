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
    └── references/             # 分类详细参考（按读者分三组）
        ├── common/             # 两类读者通用：core-theme / core-icon
        ├── consumer/           # 组件消费者：build（接入脚手架）+ component-*
        └── developer/          # 库开发者：build（本仓库构建验证）+ workflow
```

## File Naming Convention

References 按读者目录 + 类别前缀命名：

- `common/core-*` —— 核心能力，两类读者通用（theme / icon）
- `consumer/*` —— 组件消费者（build 接入脚手架；component-* 组件用法）
- `developer/*` —— 库开发者（build 本仓库构建验证；workflow 开发流程）

## 同步约定

新增组件时，需同步更新：

1. `SKILL.md` 的 Feature Reference 表格（加一行）
2. 对应 `references/consumer/component-*.md` reference（补该组件的用法/属性/坑）
3. 若有新开发坑，补进 `SKILL.md` 的「关键坑」表 + 相关 reference
4. 组件规范对齐基准变化（如 Base UI DOM）时，更新 `references/developer/workflow.md`
