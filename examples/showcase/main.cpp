#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // token 自绘前提：强制 Basic style
    // （macOS 默认 native style 拒绝自定义 contentItem/background；
    //   Basic 是无预置皮肤的最小风格，视觉完全由 QtShadcn token 控制）
    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine engine;
    engine.loadFromModule("Showcase", "Main");
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
