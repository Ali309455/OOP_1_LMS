#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    int fontId = QFontDatabase::addApplicationFont(":/assets/fonts/Lato-Regular.ttf");

    if (fontId != -1) {
        QStringList families = QFontDatabase::applicationFontFamilies(fontId);
        if (!families.isEmpty()) {
            QString family = families.at(0);
            QFont font(family);
            font.setPointSize(10);
            app.setFont(font);
        }
    } else {
        qWarning() << "Failed to load font! Check your resource path.";
    }
    engine.loadFromModule("LMS", "Main");

    return app.exec();
}
