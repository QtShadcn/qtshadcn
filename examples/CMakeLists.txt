# C++ 示例：
# - showcase：组件视觉基线，逐页覆盖全部组件，也是截图验证的入口
# - ai-dashboard：真实消费者，最能暴露 API 设计缺陷
# 其余两个（fire-safety / bms-eol）见 git 历史，需要时 checkout 回来
# prototype/main.py 是独立运行的 Python 示例，无需 CMake 构建
add_subdirectory(showcase)
add_subdirectory(ai-dashboard)
