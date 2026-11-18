// tests/core/commandfilter_test.cpp
//
// CommandFilter 的纯函数单测（issue #5 · Command）。
//
// 为什么要单独测 C++ 而不是只在 QML 用例里覆盖：过滤是这个组件最容易静默跑偏
// 的一环 —— 大小写、中文、空查询、子序列顺序，任何一处退化都会让「面板看着能用
// 但搜不出来」。纯函数在 C++ 里可以直接断言，不用拖起 QML 引擎。
//
// 对齐基准：cmdk 的 commandScore（node_modules/cmdk/dist/command-score.js）。
// 断言的是**性质**（匹配/不匹配、相对顺序、单调性）而不是逐位小数 —— 逐位钉死
// 会让任何一次浮点实现细节调整都变成「测试失败」，而行为其实没变。

#include "commandfilter.h"

#include <QtTest>

class CommandFilterTest : public QObject
{
    Q_OBJECT

private slots:
    void emptySearchMatchesEverything_data();
    void emptySearchMatchesEverything();

    void caseInsensitive();
    void substringAndSubsequence();
    void nonMatchScoresZero();
    void rankingOrder();
    void multibyteCjk();
    void keywordsContribute();
    void normalization();
    void matchesPredicate();

private:
    CommandFilter filter;
};

void CommandFilterTest::emptySearchMatchesEverything_data()
{
    QTest::addColumn<QString>("value");
    QTest::newRow("ascii") << QStringLiteral("New file");
    QTest::newRow("cjk") << QStringLiteral("新建文件");
    QTest::newRow("empty") << QString();
}

void CommandFilterTest::emptySearchMatchesEverything()
{
    QFETCH(QString, value);
    // 空查询 = 不过滤，每项满分（cmdk 在空查询时压根不走 filter）。
    // 组件侧也短路，这条是「万一组件忘了短路也不会全隐藏」的保险。
    QCOMPARE(filter.score(value, QString()), 1.0);
    QVERIFY(filter.matches(value, QString()));
}

void CommandFilterTest::caseInsensitive()
{
    // 大小写不敏感：搜 "new" 必须命中 "New file"
    QVERIFY(filter.matches(QStringLiteral("New file"), QStringLiteral("new")));
    QVERIFY(filter.matches(QStringLiteral("New file"), QStringLiteral("NEW")));
    QVERIFY(filter.matches(QStringLiteral("NEW FILE"), QStringLiteral("new")));

    // 但原文大小写完全一致时得分更高（cmdk 的 kCasePenalty = 0.9999）
    const double exact = filter.score(QStringLiteral("New file"), QStringLiteral("New"));
    const double loose = filter.score(QStringLiteral("New file"), QStringLiteral("new"));
    QVERIFY2(exact > loose, qPrintable(QStringLiteral("exact=%1 loose=%2").arg(exact).arg(loose)));
}

void CommandFilterTest::substringAndSubsequence()
{
    // 连续子串：命中
    QVERIFY(filter.matches(QStringLiteral("Search Emoji"), QStringLiteral("emoji")));
    // 子序列（字符按顺序出现即可，不要求连续）—— 这是 cmdk 与「includes」的
    // 关键差别：搜 "sme" 要能命中 "Search Emoji"（s…m…e 顺序出现）
    QVERIFY(filter.matches(QStringLiteral("Search Emoji"), QStringLiteral("sme")));
    // 顺序不对则不命中
    QVERIFY(!filter.matches(QStringLiteral("Search Emoji"), QStringLiteral("mes")));
    // 空格查询：连字符与空格等价（normalize 把 - 归一成空格）
    QVERIFY(filter.matches(QStringLiteral("cmd-k"), QStringLiteral("cmd k")));
}

void CommandFilterTest::nonMatchScoresZero()
{
    QCOMPARE(filter.score(QStringLiteral("New file"), QStringLiteral("zzz")), 0.0);
    QVERIFY(!filter.matches(QStringLiteral("New file"), QStringLiteral("filex")));
    // 空 value 遇非空 query 不命中
    QCOMPARE(filter.score(QString(), QStringLiteral("a")), 0.0);
}

void CommandFilterTest::rankingOrder()
{
    // 分数只用来排序，所以断言相对关系：
    const QString q = QStringLiteral("new");
    const double prefix = filter.score(QStringLiteral("New file"), q);
    const double middle = filter.score(QStringLiteral("Open new tab"), q);
    const double sparse = filter.score(QStringLiteral("n e w work"), q);
    QVERIFY2(prefix > 0 && middle > 0 && sparse > 0, "三条都应命中");
    // 词首/前缀命中 > 串中命中 > 稀疏命中（cmdk 的 1 / .9 / .17 分档）
    QVERIFY2(prefix >= middle,
             qPrintable(QStringLiteral("prefix=%1 middle=%2").arg(prefix).arg(middle)));
    QVERIFY2(middle > sparse,
             qPrintable(QStringLiteral("middle=%1 sparse=%2").arg(middle).arg(sparse)));

    // 完全相等的满分
    QCOMPARE(filter.score(QStringLiteral("new"), QStringLiteral("new")), 1.0);
}

void CommandFilterTest::multibyteCjk()
{
    // 中文：按 UTF-16 码元逐字比较，与 JS string 行为一致（每个汉字一个码元）。
    // 只做「连续/子序列命中」，不做拼音 —— 拼音分词是产品层的事，
    // 官方 cmdk 也没有，别过度设计。
    QVERIFY(filter.matches(QStringLiteral("新建文件"), QStringLiteral("新建")));
    QVERIFY(filter.matches(QStringLiteral("新建文件"), QStringLiteral("建文件")));
    // 子序列：新…件
    QVERIFY(filter.matches(QStringLiteral("新建文件"), QStringLiteral("新件")));
    // 顺序颠倒不命中
    QVERIFY(!filter.matches(QStringLiteral("新建文件"), QStringLiteral("件新")));
    // 不命中
    QVERIFY(!filter.matches(QStringLiteral("新建文件"), QStringLiteral("删除")));
    // 中英混排：ASCII 部分照样能搜
    QVERIFY(filter.matches(QStringLiteral("切换 Theme"), QStringLiteral("theme")));
    QVERIFY(filter.matches(QStringLiteral("打开 Settings 面板"), QStringLiteral("settings")));
    // 多字节 + 大小写不敏感同时成立
    QVERIFY(filter.matches(QStringLiteral("Theme 主题"), QStringLiteral("THEME")));
}

void CommandFilterTest::keywordsContribute()
{
    // 关键词拼进 value 一起打分（cmdk: `${value} ${keywords.join(" ")}`）
    const QStringList kw { QStringLiteral("theme"), QStringLiteral("dark") };
    QVERIFY(filter.matches(QStringLiteral("主题"), QStringLiteral("theme"), kw));
    QVERIFY(filter.matches(QStringLiteral("主题"), QStringLiteral("dark"), kw));
    // 没关键词时同样的查询不命中 —— 证明 keywords 真的在起作用
    QVERIFY(!filter.matches(QStringLiteral("主题"), QStringLiteral("theme")));
}

void CommandFilterTest::normalization()
{
    QCOMPARE(filter.normalize(QStringLiteral("New File")), QStringLiteral("new file"));
    // 连字符归一成空格
    QCOMPARE(filter.normalize(QStringLiteral("Cmd-K")), QStringLiteral("cmd k"));
    // 制表/换行也归一成空格（\s）
    QCOMPARE(filter.normalize(QStringLiteral("a\tb\nc")), QStringLiteral("a b c"));
    // 中文不受影响
    QCOMPARE(filter.normalize(QStringLiteral("新建文件")), QStringLiteral("新建文件"));
}

void CommandFilterTest::matchesPredicate()
{
    QVERIFY(filter.matches(QStringLiteral("a"), QStringLiteral("a")));
    QVERIFY(!filter.matches(QStringLiteral("a"), QStringLiteral("b")));
    // matches 必须与 score>0 严格等价（组件两处都会用到）
    const QStringList values { QStringLiteral("New file"), QStringLiteral("新建文件"),
                               QStringLiteral("Search Emoji"), QStringLiteral("zzz") };
    const QStringList queries { QStringLiteral("new"), QStringLiteral("件"), QStringLiteral("sme"),
                                QStringLiteral("q") };
    for (const QString &v : values) {
        for (const QString &s : queries)
            QCOMPARE(filter.matches(v, s), filter.score(v, s) > 0.0);
    }
}

QTEST_MAIN(CommandFilterTest)
#include "commandfilter_test.moc"
