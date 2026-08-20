# QtShadcn Skills

给 AI 编码助手使用的项目参考，格式对齐 [slidev/skills](https://github.com/slidevjs/slidev/tree/main/skills)。

## 结构

- [`SKILL.md`](SKILL.md) —— 入口：定位、消费方脚手架铁律、组件索引、关键坑
- [`references/core-build.md`](references/core-build.md) —— 本库构建 + 消费方最小工程（CMake / `main.cpp` / Makefile）
- `references/` —— 主题、开发流程、图标、各组件用法

## 使用

1. 先读 `SKILL.md`
2. **给用户写 Qt 应用**：vendor 到 `third_party/qtshadcn`，再读 `references/core-build.md` 落地 CMake + 根 Makefile
3. 按需打开对应组件 reference
