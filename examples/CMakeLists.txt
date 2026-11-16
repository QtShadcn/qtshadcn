# 只保留两个示例：
# - showcase：组件视觉基线，逐页覆盖全部组件，也是截图验证的入口
# - ai-dashboard：真实消费者，最能暴露 API 设计缺陷
# 其余两个（fire-safety / bms-eol）见 git 历史，需要时 checkout 回来
add_subdirectory(showcase)
add_subdirectory(ai-dashboard)
