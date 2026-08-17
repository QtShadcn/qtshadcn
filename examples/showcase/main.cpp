#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.loadFromModule("Showcase", "Main");
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
