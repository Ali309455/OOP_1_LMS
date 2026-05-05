#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include "backend/LibrarySystem.h"
#include "backend/LibrarySystemBridge.h"
#include <QQmlContext>



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

    LibrarySystem sys;
    sys.initializeSystem();
    LibrarySystemBridge lmsBridge(&sys);
    engine.rootContext()->setContextProperty("lms", &lmsBridge);
    Database::init();

    // // =========================
    // // ADD TEST DATA
    // // =========================

    // qDebug() << "\n=== ADD DATA ===";

    // Database::addBook("978-2", "C++ advanced", "Bjarne Stroustrup",420,"Programming", "CS", "Pearson", "1st","English", 2015, 10, 10);

    qDebug()<< sys.login("ali@gmail.com","123");
    // sys.login("ali@gmail.com","123");
    // qDebug()<< sys.updateUser("SU-6","dkj2","dkj@gmail,com","123","Gold","STUDENT","active");
    // sys.removeUser("SU-2");
    // sys.updateUser("LIB-5","ali", "ai@gmail.com", "mai", "gold", "LIBRARIAN");
    // sys.upgradeStudentMembership("cs-001","silver");
    // qDebug() << sys.removeUser("cs-001");

    // sys.addbook("278-2", "AI essentails", "Bjarne ","SI", "CS", "Pearson", "2st","English", 2022,520, 10);
    // sys.removeBook("278-2");
    bool ok = sys.submitReview("SU-1","978-2",4,"good for fe students");
    qDebug()<<"Review status: "<<ok;
    // bool ok2 = sys.submitReview("SU-0","278-2",3,"good for fe students");
    // qDebug()<<"Review status: "<<ok2;
    // sys.approveReview("RV-1");
    // qDebug() << sys.issueBook("978-2","SU-1");
    // qDebug() << sys.returnBook("TX-2");
    // sys.displayAllData();


    // Database::addTransaction("TX1", "cs-001", "978-1", "issued","2/05/26", 0);
    // Database::addReview("RV2", "cs-001", "978-2", 5, "Great Book", "pending");
    // Database::addWallet( "cs-001", 100, 0);
    // qDebug()<<Database::updateUser("SU-6","dkj2","dkj@gmail.com","sadws","Silver","STUDENT","active");
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
