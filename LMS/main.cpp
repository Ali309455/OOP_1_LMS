#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include "backend/LibrarySystem.h"



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
    if (!Database::connect()) {
        qDebug() << "Failed to connect DB";
        return -1;
    }

    Database::init();

    // // =========================
    // // ADD TEST DATA
    // // =========================

    qDebug() << "\n=== ADD DATA ===";
    // Database::addUser("cs-001","Ali", "ali@gmail.com", "123", "gold", "user");
    // Database::addUser("cs-002","Admin", "admin@gmail.com", "admin", "premium", "librarian");

    // Database::addBook("978-2", "C++ advanced", "Bjarne Stroustrup",420,"Programming", "CS", "Pearson", "1st","English", 2015, 10, 10);
    LibrarySystem sys;
    sys.initializeSystem();
    qDebug()<< sys.login("admin@gmail.com","admin");
    sys.approveReview("RV2");
    // sys.issueBook("978-1","cs-001");
    // qDebug() << sys.returnBook("TX1");


    // Database::addTransaction("TX1", "cs-001", "978-1", "issued","2/05/26", 0);
    // Database::addReview("RV2", "cs-001", "978-2", 5, "Great Book", "pending");
    // Database::addWallet( "cs-001", 100, 0);
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
