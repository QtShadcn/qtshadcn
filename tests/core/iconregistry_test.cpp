// tests/core/iconregistry_test.cpp
#include <QTest>
#include <QObject>
#include <QSignalSpy>
#include <QUrl>
#include "iconregistry.h"

class IconRegistryTest : public QObject
{
    Q_OBJECT
private slots:
    void hasBuiltinIcon();
    void missingIconReturnsFalse();
    void namesSortedCaseInsensitive();
    void dataUrlReplacesCurrentColor();
    void dataUrlDefaultColorIsBlack();
    void dataUrlUnknownIconReturnsEmpty();
    void unsafeNameDoesNotTriggerRemote();
};

void IconRegistryTest::hasBuiltinIcon()
{
    IconRegistry reg;
    QVERIFY(reg.has(QStringLiteral("github")));   // 本地内置图标
    QVERIFY(reg.has(QStringLiteral("sun")));
    QVERIFY(reg.has(QStringLiteral("moon")));
}

void IconRegistryTest::missingIconReturnsFalse()
{
    IconRegistry reg;
    QVERIFY(!reg.has(QStringLiteral("definitely-not-a-real-icon")));
}

void IconRegistryTest::namesSortedCaseInsensitive()
{
    IconRegistry reg;
    const QStringList names = reg.names();
    // 非空且全部小写（图标名只允许小写字母/数字/连字符）
    QVERIFY(!names.isEmpty());
    for (const QString &n : names)
        QCOMPARE(n, n.toLower());
    // 按大小写不敏感升序排列
    QStringList sorted = names;
    std::sort(sorted.begin(), sorted.end(),
              [](const QString &a, const QString &b) { return a.compare(b, Qt::CaseInsensitive) < 0; });
    QCOMPARE(names, sorted);
}

void IconRegistryTest::dataUrlReplacesCurrentColor()
{
    IconRegistry reg;
    const QString url = reg.dataUrl(QStringLiteral("github"), QStringLiteral("#ff0000"));
    QVERIFY(url.startsWith(QStringLiteral("data:image/svg+xml;base64,")));
    // 解码后 currentColor 应被替换为请求的颜色
    const QByteArray b64 = url.mid(QStringLiteral("data:image/svg+xml;base64,").size()).toLatin1();
    const QString svg = QString::fromUtf8(QByteArray::fromBase64(b64));
    QVERIFY(svg.contains(QStringLiteral("#ff0000")));
    QVERIFY(!svg.contains(QStringLiteral("currentColor")));
}

void IconRegistryTest::dataUrlDefaultColorIsBlack()
{
    IconRegistry reg;
    const QString url = reg.dataUrl(QStringLiteral("github"));   // 不传颜色
    QVERIFY(url.startsWith(QStringLiteral("data:image/svg+xml;base64,")));
    const QByteArray b64 = url.mid(QStringLiteral("data:image/svg+xml;base64,").size()).toLatin1();
    const QString svg = QString::fromUtf8(QByteArray::fromBase64(b64));
    QVERIFY(svg.contains(QStringLiteral("#000000")));            // 默认黑色
    QVERIFY(!svg.contains(QStringLiteral("currentColor")));
}

void IconRegistryTest::dataUrlUnknownIconReturnsEmpty()
{
    IconRegistry reg;
    // 关闭远程兜底，确保未知图标同步返回空、且不发网络请求
    reg.setRemoteEnabled(false);
    QSignalSpy spy(&reg, &IconRegistry::iconReady);
    QCOMPARE(reg.dataUrl(QStringLiteral("no-such-icon")), QString());
    QCOMPARE(spy.count(), 0);   // 未触发下载
}

void IconRegistryTest::unsafeNameDoesNotTriggerRemote()
{
    // 含非法字符（大写/特殊符号）的名字应通过注入正则被拦截，不触发远程请求
    IconRegistry reg;
    QSignalSpy spy(&reg, &IconRegistry::iconReady);
    // 这些名字既不在本地、也不匹配 ^[a-z0-9-]+$，dataUrl 应返回空且不下载
    QCOMPARE(reg.dataUrl(QStringLiteral("Foo")), QString());        // 大写
    QCOMPARE(reg.dataUrl(QStringLiteral("bad name")), QString());   // 空格
    QCOMPARE(spy.count(), 0);
}

QTEST_MAIN(IconRegistryTest)
#include "iconregistry_test.moc"
