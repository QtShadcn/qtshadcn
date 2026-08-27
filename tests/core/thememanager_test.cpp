// tests/core/thememanager_test.cpp
#include <QTest>
#include <QObject>
#include <QSignalSpy>
#include "thememanager.h"

class ThemeManagerTest : public QObject
{
    Q_OBJECT
private slots:
    void defaultModeIsLight();
    void setModeNormalizesUnknownToLight();
    void setModeDark();
    void modeChangedOnlyOnChange();
    void darkPrimaryYieldsWhiteForeground();
    void lightPrimaryYieldsBlackForeground();
    void midGrayPrimaryAtThreshold();
    void tokenLookup();
    void primaryChangedOnlyOnChange();
};

void ThemeManagerTest::defaultModeIsLight()
{
    ThemeManager m;
    QCOMPARE(m.mode(), QStringLiteral("light"));
    // 默认无主色覆盖：light 下 primary 内置为 #18181b，前景按亮度自动选白字
    QCOMPARE(m.primary(), QString());
    QCOMPARE(m.token(QStringLiteral("primary")).toString(), QStringLiteral("#18181b"));
    QCOMPARE(m.token(QStringLiteral("primaryForeground")).toString(), QStringLiteral("#fafafa"));
}

void ThemeManagerTest::setModeNormalizesUnknownToLight()
{
    ThemeManager m;
    // 非精确 "dark" 一律归一化为 light（大小写/任意串都不生效）
    m.setMode(QStringLiteral("DARK"));
    QCOMPARE(m.mode(), QStringLiteral("light"));
    m.setMode(QStringLiteral("foo"));
    QCOMPARE(m.mode(), QStringLiteral("light"));
}

void ThemeManagerTest::setModeDark()
{
    ThemeManager m;
    m.setMode(QStringLiteral("dark"));
    QCOMPARE(m.mode(), QStringLiteral("dark"));
    // dark 下默认 primary 为 #fafafa（浅色），前景自动选黑字
    QCOMPARE(m.token(QStringLiteral("primary")).toString(), QStringLiteral("#fafafa"));
    QCOMPARE(m.token(QStringLiteral("primaryForeground")).toString(), QStringLiteral("#18181b"));
}

void ThemeManagerTest::modeChangedOnlyOnChange()
{
    ThemeManager m;
    QSignalSpy spy(&m, &ThemeManager::modeChanged);
    m.setMode(QStringLiteral("light"));   // 已经是 light，不应发信号
    QCOMPARE(spy.count(), 0);
    m.setMode(QStringLiteral("dark"));
    QCOMPARE(spy.count(), 1);
    m.setMode(QStringLiteral("dark"));    // 仍是 dark，不应重复发
    QCOMPARE(spy.count(), 1);
}

void ThemeManagerTest::darkPrimaryYieldsWhiteForeground()
{
    // 深色主色（接近黑）→ 亮度 < 0.5 → 前景白字
    ThemeManager m;
    m.setPrimary(QStringLiteral("#000000"));
    QCOMPARE(m.primary(), QStringLiteral("#000000"));
    QCOMPARE(m.token(QStringLiteral("primary")).toString(), QStringLiteral("#000000"));
    QCOMPARE(m.token(QStringLiteral("primaryForeground")).toString(), QStringLiteral("#fafafa"));
}

void ThemeManagerTest::lightPrimaryYieldsBlackForeground()
{
    // 浅色主色（白）→ 亮度 > 0.5 → 前景黑字
    ThemeManager m;
    m.setPrimary(QStringLiteral("#ffffff"));
    QCOMPARE(m.token(QStringLiteral("primary")).toString(), QStringLiteral("#ffffff"));
    QCOMPARE(m.token(QStringLiteral("primaryForeground")).toString(), QStringLiteral("#18181b"));
}

void ThemeManagerTest::midGrayPrimaryAtThreshold()
{
    // 中灰 #808080：亮度 ≈ 0.502 > 0.5 → 前景黑字（验证阈值分支）
    ThemeManager m;
    m.setPrimary(QStringLiteral("#808080"));
    QCOMPARE(m.token(QStringLiteral("primary")).toString(), QStringLiteral("#808080"));
    QCOMPARE(m.token(QStringLiteral("primaryForeground")).toString(), QStringLiteral("#18181b"));

    // 略低于阈值的灰 #7f7f7f：亮度 ≈ 0.498 < 0.5 → 前景白字
    ThemeManager m2;
    m2.setPrimary(QStringLiteral("#7f7f7f"));
    QCOMPARE(m2.token(QStringLiteral("primaryForeground")).toString(), QStringLiteral("#fafafa"));
}

void ThemeManagerTest::tokenLookup()
{
    ThemeManager m;
    QVERIFY(m.token(QStringLiteral("background")).isValid());
    QCOMPARE(m.token(QStringLiteral("radius")).toInt(), 8);
    // 不存在的 token 返回默认 QVariant
    QVERIFY(!m.token(QStringLiteral("does-not-exist")).isValid());
}

void ThemeManagerTest::primaryChangedOnlyOnChange()
{
    ThemeManager m;
    QSignalSpy spy(&m, &ThemeManager::primaryChanged);
    m.setPrimary(QString());         // 默认就是空，不发
    QCOMPARE(spy.count(), 0);
    m.setPrimary(QStringLiteral("#ff0000"));
    QCOMPARE(spy.count(), 1);
    m.setPrimary(QStringLiteral("#ff0000"));  // 同值，不重复发
    QCOMPARE(spy.count(), 1);
}

QTEST_MAIN(ThemeManagerTest)
#include "thememanager_test.moc"
