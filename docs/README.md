# QtShadcn Docs

QtShadcn 的 Docus 文档站（Nuxt Content + Nuxt UI）。

## 本地开发

```bash
pnpm install
pnpm dev        # http://localhost:3000
```

## 构建

```bash
pnpm build      # 产物在 .output/
```

## 内容结构

```
content/
├── index.md                  # 首页（hero + 特性 + 组件状态）
├── 1.getting-started/        # 快速开始（简介 / 安装 / 使用 / 结构 / 里程碑）
├── 2.design/                 # 设计（技术方案）
└── 3.development/            # 开发（组件开发流程）
```

> 组件开发流程与技术方案曾放在 `docs/skills/`，已移入 `content/` 作为文档页（frontmatter 已适配 Docus）。

## 技术栈

- [Nuxt 4](https://nuxt.com) + [Nuxt Content](https://content.nuxt.com/)
- [Docus](https://docus.dev) 文档主题
- 包管理器：pnpm
