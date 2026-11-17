// src/core/commandfilter.cpp
#include "commandfilter.h"

#include <QHash>

#include <cmath>

namespace {

// 与 cmdk/dist/command-score.js 顶部的常量一一对应（名字取自 cmdk 源码注释语义）
constexpr double kFullMatch = 1.0;      // 完整匹配
constexpr double kSeparator = 0.8;      // 命中的前一个字符是分隔符（. _ / # 等）
constexpr double kSpace = 0.9;          // 命中的前一个字符是空格/连字符
constexpr double kFuzzy = 0.17;         // 纯「顺序出现」的低分
constexpr double kPenalty = 0.999;      // 每跳过一个字符的衰减
constexpr double kCasePenalty = 0.9999; // 只在忽略大小写后才相等（原文不等）
constexpr double kRepeatSkip = 0.1;     // 连续重复字符跳一的折扣
constexpr double kNonMatch = 0.99;      // 查询耗尽但目标没耗尽：仍算命中（前缀命中）

// 打分递归的中间状态：memo 是 cmdk 的 `${i},${j}` 记忆表
struct Scorer {
    const QString &input;   // 原始 value（含拼进去的 keywords），与 cmdk 一致地用于分隔符判断
    const QString &search;  // 原始 search（大小写罚分用它比对）
    const QString &fmtInput;   // 归一化后的 value（indexOf 在它上面做）
    const QString &fmtSearch;  // 归一化后的 search
    mutable QHash<QString, double> memo;

    // JS 的 charAt(i)：越界返回空串。这里用 QChar(0) 表达「无字符」，
    // 与 isSeparator/areSimilar 对空串判 false 的行为一致
    static QChar at(const QString &s, int i)
    {
        return (i >= 0 && i < s.size()) ? s.at(i) : QChar::Null;
    }

    static bool isSeparator(QChar c)
    {
        // /[\\\/_+.#"@\[\(\{&]/
        switch (c.unicode()) {
        case '\\': case '/': case '_': case '+': case '.': case '#':
        case '"': case '@': case '[': case '(': case '{': case '&':
            return true;
        default:
            return false;
        }
    }

    static bool isSimilar(QChar c)
    {
        // /[\s-]/
        return c == QLatin1Char('-') || c == QLatin1Char(' ') || c == QLatin1Char('\t')
            || c == QLatin1Char('\n') || c == QLatin1Char('\r');
    }

    // 统计 [from, to) 内满足谓词的字符数（对应 JS 的 slice(...).match(regex) 取 .length）
    template <typename Pred>
    static int countIf(const QString &s, int from, int to, Pred pred)
    {
        int n = 0;
        for (int i = from; i < to; ++i) {
            if (pred(s.at(i)))
                ++n;
        }
        return n;
    }

    double run(int i, int j) const
    {
        // 查询字符全部消耗：目标也消耗完 = 完全相等，否则是「查询是目标的前缀/子序列」
        if (j == search.size())
            return i == input.size() ? kFullMatch : kNonMatch;

        const QString key = QStringLiteral("%1,%2").arg(i).arg(j);
        auto found = memo.constFind(key);
        if (found != memo.constEnd())
            return found.value();

        const QChar want = at(fmtSearch, j);
        int pos = fmtInput.indexOf(want, i);
        double best = 0.0;

        while (pos >= 0) {
            double candidate = run(pos + 1, j + 1);
            if (candidate > best) {
                if (pos == i) {
                    // 紧接上一个命中字符 → 连续前缀，最高档
                    candidate *= kFullMatch;
                } else if (isSeparator(at(input, pos - 1))) {
                    // 命中在分隔符之后（如 "cmdk" 命中 "command-k" 的 k）
                    candidate *= kSeparator;
                    const int span = countIf(input, i, pos - 1, isSeparator);
                    if (span > 0 && i > 0)
                        candidate *= std::pow(kPenalty, span);
                } else if (isSimilar(at(input, pos - 1))) {
                    // 命中在空格/连字符之后（词首命中）
                    candidate *= kSpace;
                    const int span = countIf(input, i, pos - 1, isSimilar);
                    if (span > 0 && i > 0)
                        candidate *= std::pow(kPenalty, span);
                } else {
                    // 纯顺序命中（模糊）：命中点离上一命中越远扣得越多
                    candidate *= kFuzzy;
                    if (i > 0)
                        candidate *= std::pow(kPenalty, pos - i);
                }

                // 归一化后相等但原文不等 → 只有大小写差别，轻微扣分
                if (at(input, pos) != at(search, j))
                    candidate *= kCasePenalty;
            }

            // 连续重复字符：允许跳一个再匹配（"aab" 查 "ab" 时仍能拿到高分）
            const bool lowScore = candidate < kRepeatSkip;
            const bool nextIsPrevChar = at(fmtInput, pos - 1) == at(fmtSearch, j + 1);
            const bool repeatedInQuery = at(fmtSearch, j + 1) == want;
            const bool prevNotQuery = at(fmtInput, pos - 1) != want;
            if ((lowScore && nextIsPrevChar) || (repeatedInQuery && prevNotQuery)) {
                const double skipped = run(pos + 1, j + 2) * kRepeatSkip;
                if (skipped > candidate)
                    candidate = skipped;
            }

            if (candidate > best)
                best = candidate;

            pos = fmtInput.indexOf(want, pos + 1);
        }

        memo.insert(key, best);
        return best;
    }
};

} // namespace

CommandFilter::CommandFilter(QObject *parent)
    : QObject(parent)
{
}

CommandFilter *CommandFilter::create(QQmlEngine *, QJSEngine *)
{
    // 单例：无状态纯函数，不需要 engine 相关初始化
    return new CommandFilter();
}

QString CommandFilter::normalize(const QString &text) const
{
    // cmdk 的 format(): toLowerCase().replace(/[\s-]/g, " ")
    // \s 与连字符**都**归一成空格，所以 "cmd-k" / "cmd\tk" / "cmd k" 三者等价。
    // 只用 QString::replace(QChar) 会漏掉空白（实测踩过：替换一个字符不覆盖 \s 类），
    // 所以逐字符判后重建。
    QString out;
    out.reserve(text.size());
    for (const QChar c : text.toLower())
        out.append(Scorer::isSimilar(c) ? QLatin1Char(' ') : c);
    return out;
}

double CommandFilter::score(const QString &value,
                            const QString &search,
                            const QStringList &keywords) const
{
    // 查询为空 = 不过滤。cmdk 此时返回 .99（>0，全部命中）；这里给满分，
    // 语义相同（都远大于任何「不匹配」的 0），组件侧本来也在空查询直接短路，
    // 不会拿它排序。
    if (search.isEmpty())
        return 1.0;

    // keywords 拼到 value 后一起打分（cmdk: `${value} ${keywords.join(" ")}`）
    const QString full = keywords.isEmpty() ? value : value + QLatin1Char(' ') + keywords.join(QLatin1Char(' '));

    const QString fmtFull = normalize(full);
    const QString fmtSearch = normalize(search);

    Scorer s{full, search, fmtFull, fmtSearch, {}};
    return s.run(0, 0);
}

bool CommandFilter::matches(const QString &value,
                            const QString &search,
                            const QStringList &keywords) const
{
    return score(value, search, keywords) > 0.0;
}
