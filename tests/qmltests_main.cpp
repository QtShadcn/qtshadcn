// QML 组件测试入口（Qt Quick Test）
//
// 所有 tests/qml/tst_*.qml 都由这份 main 驱动，用例文件通过 -input 指定：
//   ./bin/qmltests -import <build>/src -input tests/qml/tst_ShadcnCard.qml
//
// -import 指向构建目录的 QML 模块输出（<build>/src），否则用例里的
// `import QtShadcn` 解析不到未安装的模块。
//
// TestSetup 注入一个 C++ 侧 QVariantList 模型：ShadcnSelect 的 textRole
// 取值缺陷正是「C++ 的 QVariantList 在 QML 里 Array.isArray 为 false」，
// 纯 QML 造不出这个形态，必须在 C++ 里给。

#include <QtQuickTest>
#include <QQmlContext>
#include <QQmlEngine>
#include <QString>
#include <QVariantList>
#include <QVariantMap>

class TestSetup : public QObject
{
    Q_OBJECT

public slots:
    void qmlEngineAvailable(QQmlEngine *engine)
    {
        QVariantList people;
        for (const QString &name : { QStringLiteral("C++甲"), QStringLiteral("C++乙") }) {
            QVariantMap person;
            person.insert(QStringLiteral("label"), name);
            people.append(person);
        }
        engine->rootContext()->setContextProperty(QStringLiteral("TestCppModel"), people);
    }
};

QUICK_TEST_MAIN_WITH_SETUP(qtshadcn, TestSetup)

#include "qmltests_main.moc"
