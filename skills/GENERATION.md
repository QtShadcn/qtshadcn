# Skills Generation Information

This document describes how the QtShadcn skills were generated and how to keep them synchronized with the codebase.

## Generation Details

**Generated from:**
- 项目源码：`src/qml/Components/*`、`src/core/*`、`examples/showcase/`
- 文档：`docs/content/2.components/*`（组件用法）、工作记忆（开发坑）
- 日期：2026-08-19（2026-09-10 拆分为使用者 / 开发者两个 skill）
- 参考格式：slidev 的 `skills/`（SKILL.md 表格索引 + references 分类参考）

## Structure

按**读者角色**拆成两个 skill —— 使用者（接库写业务）与库开发者（扩展本库）。入口文件不再混装两类读者。

```
skills/
├── GENERATION.md                    # 本文件
├── README.md                        # 两个 skill 的总索引 + 边界表
├── qtshadcn/                        # ① 使用者
│   ├── SKILL.md                     # 接入铁律 + 组件索引（M2–M6）+ 使用坑
│   ├── README.md
│   └── references/
│       ├── common/                  # 两类读者通用：core-theme / core-icon（单一来源）
│       └── consumer/                # build（接入脚手架）+ component-*（组件用法）
└── qtshadcn-dev/                    # ② 库开发者
    ├── SKILL.md                     # 开发铁律 + 架构要点 + 开发坑 + 新增组件后必做
    ├── README.md
    └── references/
        ├── build.md                 # 本仓库构建 / 静态验证 / 截图 / showcase 结构
        ├── workflow.md              # 组件开发全流程
        └── m6-compliance-fix.md     # M6 对齐修复记录与遗留修正项
```

边界：坑按「发生在**消费方业务代码**里 → `qtshadcn`」vs「发生在**写库组件 / 构建库**时 → `qtshadcn-dev`」归属。`references/common/` 只存一份，dev 侧交叉引用，不复制（避免两份漂移）。

## File Naming Convention

- `common/core-*` —— 核心能力，两类读者通用（theme / icon），**单一来源在 `qtshadcn`**
- `qtshadcn/references/consumer/*` —— 消费者（build 接入脚手架；component-* 组件用法）
- `qtshadcn-dev/references/*` —— 库开发者（build 本仓库构建验证；workflow 开发流程；`m6-*` 专项修复记录）

## Hermes 镜像

`~/.hermes/skills/software-development/{qtshadcn,qtshadcn-dev}` 是指向本目录两个 skill 的**符号链接**（单一来源，不再手工复制）。改完本目录即时生效；若仓库移动位置，重建链接即可。

## 同步约定

新增组件时，需同步更新：

1. `qtshadcn/SKILL.md` 的组件索引表（加一行）+ 对应 `qtshadcn/references/consumer/component-*.md`
2. `qtshadcn-dev/SKILL.md` 的「新增组件后必做」清单执行到底（showcase 三处同步 / 文档 / 截图）
3. 有新坑：消费方踩的进 `qtshadcn/SKILL.md`「使用坑」；写库时踩的进 `qtshadcn-dev/SKILL.md`「开发坑」
4. 组件规范对齐基准变化（如 Base UI DOM）时，更新 `qtshadcn-dev/references/workflow.md`，专项记录进 `qtshadcn-dev/references/m6-compliance-fix.md` 一类文件
