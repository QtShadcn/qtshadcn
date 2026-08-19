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
        QQuickWindow *win = qobject_cast<QQuickWindow *>(root);
        if (!win) {
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

        // 等一帧渲染 + 页面切换完成后截图
        QTimer::singleShot(600, win, [win, out]() {
            QImage img = win->grabWindow();
            if (img.isNull()) {
                qWarning() << "grabWindow returned null image";
                exit(1);
            }
            if (!img.save(out)) {
                qWarning() << "failed to save" << out;
                exit(1);
            }
            qInfo() << "saved" << out << img.size();
            exit(0);
        });

        return app.exec();
    }

    return app.exec();
}
