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
    // 截图模式：--screenshot <Page文件名> --output <out.png> [--crop x,y,w,h]
    QCommandLineOption shotOpt(QStringList() << "screenshot",
                               QStringLiteral("Capture a component page (e.g. ButtonPage.qml) to PNG and exit."),
                               QStringLiteral("page"));
    QCommandLineOption outOpt(QStringList() << "output",
                              QStringLiteral("Output PNG path."),
                              QStringLiteral("path"));
    QCommandLineOption cropOpt(QStringList() << "crop",
                               QStringLiteral("Crop rect 'x,y,width,height' (optional; full window if omitted)."),
                               QStringLiteral("rect"));
    parser.addOption(shotOpt);
    parser.addOption(outOpt);
    parser.addOption(cropOpt);
    parser.process(app);

    // 截图模式：通知 QML 关闭 GPU 特效（MultiEffect 阴影等，offscreen 软件渲染不支持）
    if (parser.isSet(shotOpt))
        qputenv("QTSHADCN_SCREENSHOT", "1");

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
        const QString crop = parser.isSet(cropOpt) ? parser.value(cropOpt) : QString();

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

        // 等待足够长（复杂页面如 Icon 网格/表单需多帧布局）后整窗截图 + 可选裁剪
        const int delayMs = qEnvironmentVariableIntValue("SHOT_DELAY_MS");
        QTimer::singleShot(delayMs > 0 ? delayMs : 1200, win, [win, out, crop]() {
            QImage img = win->grabWindow();
            if (img.isNull()) {
                qWarning() << "grabWindow returned null image";
                exit(1);
            }
            if (!crop.isEmpty()) {
                const QStringList parts = crop.split(',');
                if (parts.size() == 4) {
                    const int x = parts[0].toInt();
                    const int y = parts[1].toInt();
                    const int w = parts[2].toInt();
                    const int h = parts[3].toInt();
                    if (w > 0 && h > 0 && x >= 0 && y >= 0)
                        img = img.copy(x, y, w, h);
                    else
                        qWarning() << "invalid crop rect, ignored:" << crop;
                } else {
                    qWarning() << "crop must be 'x,y,width,height', ignored:" << crop;
                }
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
