#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QCommandLineParser>
#include <QImage>
#include <QTimer>
#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // token 自绘前提：强制 Basic style
    // （macOS 默认 native style 拒绝自定义 contentItem/background；
    //  Basic 是无预置皮肤的最小风格，视觉完全由 QtShadcn token 控制）
    QQuickStyle::setStyle("Basic");

    QCommandLineParser parser;
    parser.setApplicationDescription("QtShadcn showcase");
    parser.addHelpOption();
    // 截图模式：--screenshot <Page文件名> --output <out.png>
    QCommandLineOption shotOpt(QStringList() << "screenshot",
                               QStringLiteral("Capture a component page (e.g. ButtonPage.qml) to PNG and exit."),
                               QStringLiteral("page"));
    QCommandLineOption outOpt(QStringList() << "output",
                              QStringLiteral("Output PNG path."),
                              QStringLiteral("path"));
    parser.addOption(shotOpt);
    parser.addOption(outOpt);
    parser.process(app);

    QQmlApplicationEngine engine;
    engine.loadFromModule("Showcase", "Main");
    if (engine.rootObjects().isEmpty())
        return -1;

    if (parser.isSet(shotOpt)) {
        QObject *root = engine.rootObjects().first();
        if (!qobject_cast<QQuickWindow *>(root)) {
            qWarning() << "root object is not a QQuickWindow";
            return 1;
        }

        const QString page = parser.value(shotOpt);
        const QString out = parser.isSet(outOpt) ? parser.value(outOpt) : page + ".png";

        // 切到目标页面（Main.qml 的 findPageIndex：文件名 → 菜单 index）
        QVariant idx;
        const bool ok = QMetaObject::invokeMethod(root, "findPageIndex",
                                                  Q_RETURN_ARG(QVariant, idx),
                                                  Q_ARG(QVariant, page));
        if (!ok) {
            qWarning() << "findPageIndex not invokable";
            return 1;
        }
        root->setProperty("currentIndex", idx.toInt());

        // 等待足够长（复杂页面如 Icon 网格/表单需多帧布局）后，
        // 调 Main.qml 的 capturePage（grab 当前页面 item，只截右侧内容区，不含菜单）
        const int delayMs = qEnvironmentVariableIntValue("SHOT_DELAY_MS");
        QTimer::singleShot(delayMs > 0 ? delayMs : 1200, root, [root, out]() {
            QMetaObject::invokeMethod(root, "capturePage", Q_ARG(QVariant, out));
        });

        return app.exec();
    }

    return app.exec();
}
