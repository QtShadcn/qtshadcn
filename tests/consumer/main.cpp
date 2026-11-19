#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTimer>
#include <QDebug>

// 消费方冒烟入口：加载 Main.qml，确认 ShadcnButton 真的被实例化。
// 退出码 0 = import QtShadcn 解析成功且组件创建成功。
int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
        []() {
            qCritical("CONSUMER FAIL: objectCreationFailed");
            QCoreApplication::exit(1);
        },
        Qt::QueuedConnection);

    engine.loadFromModule("Consumer", "Main");

    QTimer::singleShot(1200, &app, [&engine]() {
        const auto roots = engine.rootObjects();
        bool found = false;
        for (QObject *rootObject : roots) {
            if (rootObject->findChild<QObject *>(QStringLiteral("btn")))
                found = true;
        }
        if (found) {
            qInfo("CONSUMER OK: import QtShadcn resolved, ShadcnButton instantiated");
            QCoreApplication::exit(0);
        } else {
            qCritical("CONSUMER FAIL: ShadcnButton not found (rootObjects=%lld)",
                      static_cast<long long>(roots.size()));
            QCoreApplication::exit(1);
        }
    });

    return app.exec();
}
