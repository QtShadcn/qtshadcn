// src/core/commandfilter.h
#pragma once

#include <QObject>
#include <QJSEngine>
#include <QQmlEngine>
#include <QString>
#include <QStringList>
#include <QtQml/qqmlregistration.h>

// C++ 能力层：命令面板的模糊匹配打分（issue #5 · Command）
//
// 为什么放 C++ 而不是 QML：
//   1. 这是一段**递归 + 记忆化的纯函数**（无 UI 依赖），QML 里写既难单测也难断点；
//      本仓库的既定分工是「QML 管 UI、C++ 管能力」，与 ThemeManager / IconRegistry
//      / ShadcnTableModel 同类。
//   2. 纯函数 → 可以在 C++ 测试里直接调用（tests/core/commandfilter_test.cpp），
//      不必拖起整个 QML 引擎；QML 侧再以 singleton 调用同一个实现，
//      组件行为与单测打的是同一段代码，不会出现「测试通过但组件是另一套」。
//   3. commandScore 对中文同样按 UTF-16 码元逐字比较，QString 的行为与 JS
//      string 在这里一致（CJK 每个汉字一个码元），不需要额外的分词/拼音处理。
//
// 与 cmdk 的对齐（node_modules/cmdk/dist/command-score.js）：
//   官方默认 filter 不是「包含匹配」，而是**子序列打分**：查询字符按顺序出现在
//   目标里即命中，命中位置越好分数越高，最后按分数排序（分数只影响顺序，
//   >0 就代表匹配）。逐字移植，不是「近似实现」。
class CommandFilter : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit CommandFilter(QObject *parent = nullptr);

    static CommandFilter *create(QQmlEngine *engine, QJSEngine *jsEngine);

    // cmdk 的 commandScore(value, search, keywords)
    //   value    被匹配的文本（CommandItem 的 value）
    //   search   用户输入的查询串；空串视为「不过滤」，恒返回满分
    //   keywords 附加关键词（拼到 value 后一起打分，与 cmdk 一致）
    // 返回值：0 = 不匹配；(0, 1] = 匹配且越大越靠前（1 = 完全相等）
    Q_INVOKABLE double score(const QString &value, const QString &search,
                             const QStringList &keywords = QStringList()) const;

    // 便捷谓词：score(...) > 0
    Q_INVOKABLE bool matches(const QString &value, const QString &search,
                             const QStringList &keywords = QStringList()) const;

    // cmdk 的归一化：小写化 + 把空白与连字符统一成空格（打分用的两侧都做）
    // 暴露出来是为了单测能直接断言归一化本身，也让自定义 filter 能复用
    Q_INVOKABLE QString normalize(const QString &text) const;
};
