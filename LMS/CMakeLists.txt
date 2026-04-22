cmake_minimum_required(VERSION 3.16)

project(LMS VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup()

qt_add_executable(appLMS
    main.cpp
)

qt_add_qml_module(appLMS
    URI LMS
    QML_FILES
               Main.qml
               qml/screens/auth/Login.qml
               qml/screens/auth/Signup.qml
               qml/screens/shared/BookCatalog.qml
               qml/screens/shared/BookDetail.qml
               qml/screens/shared/Transactions.qml
               qml/screens/shared/TransactionsAdmin.qml
               qml/screens/shared/TransactionsStudent.qml
               qml/screens/shared/Reviews.qml
               qml/screens/shared/Profile.qml
               qml/screens/student/StudentDashboard.qml
               qml/screens/student/Membership.qml
               qml/screens/librarian/LibrarianDashboard.qml
               qml/screens/librarian/Reports.qml
               qml/screens/librarian/UserManagement.qml
               qml/components/Button.qml
               qml/layouts/Sidebar.qml
               qml/layouts/Centralbox.qml
               qml/layouts/Navbar.qml
               qml/navigation/Router.qml

)
qt_add_resources(appLMS "resources"
    PREFIX "/"
    FILES
        "assets/fonts/Lato-Regular.ttf"
        "assets/icons/edit.png"
        "assets/icons/adduser.png"
        "assets/icons/eye.png"
        "assets/icons/addreview.png"
        "assets/icons/clock.png"
        "assets/icons/book.png"
        "assets/icons/dashboard.png"
        "assets/icons/transaction.png"
        "assets/icons/book-read-fill.svg"
        "assets/icons/currency-fill.svg"
        "assets/icons/shield-user-fill.svg"
        "assets/icons/time-fill.svg"
        "assets/icons/book-fill.svg"
        "assets/icons/calendar-event-fill.svg"
        "assets/icons/discount-percent-fill.svg"
        "assets/icons/vip-crown-2-fill.svg"
        "assets/icons/vip-crown-fill.svg"
        "assets/icons/vip-diamond-fill.svg"
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appLMS PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appLMS
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appLMS
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appLMS
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
