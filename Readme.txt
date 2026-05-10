Library Management System (LMS) — Project Report
Qt/QML + C++ (OOP)

============================================================
Project Identification
============================================================
GROUP ID    : G3-8
Full Names  : Abdul Wahab, Mohammad Ali , Mohammad Hassan Khan , Shaffay Zia 
Roll Number : CS-25138, CS-25088, CS-25078, CS-25082
Section     :  B (Group G3)


============================================================
Execution Guide (CMake )
============================================================

Prerequisites
- Qt 6 installed with the following components:
  - Qt Quick, Qt Core, Qt Sql
  (CMake links: Qt6::Quick, Qt6::Core, Qt6::Sql)
- A C++ compiler on Windows (MSVC or MinGW)
- CMake 3.16+ and Ninja available in PATH
- sqlite database , sqlite Viewer
Recommended Build Steps (Out-of-source Build)
1) Open the LMS project directory (the folder containing CMakeLists.txt) in Qt Creator by:
	- Go to File at top bar , open Project(ctrl + o)
	- Go to the LMS folder and click on CMakeLists.txt file.
2) Run:
   Run button in left corner or (CTRL + R)

Notes
- QML is included through qt_add_qml_module(...) and the application loads the QML module "LMS".
- The application attempts a database connection at startup; if it fails, the program exits early.


============================================================
OOP Concept Mapping (with Evidence from Code)
============================================================

1) Inheritance
- Person hierarchy:
  - Student and Librarian inherit from Person (abstract base class with virtual interface).
  Location:
  - LMS/backend/Auth.h
    - class Person (abstract; virtual getRole() = 0)
    - class Student : public Person
    - class Librarian : public Person

- Membership hierarchy:
  - Silver, Gold, and Platinum inherit from Membership (abstract base class).
  Location:
  - LMS/backend/BookMembership.h
    - class Membership (abstract; pure virtual functions)
    - class Silver : public Membership
    - class Gold   : public Membership
    - class Platinum : public Membership

2) Polymorphism (dynamic_cast)
Dynamic polymorphism is used through base-class pointers (Person*) with safe downcasting
to derived types (Student*) when student-specific behavior/fields are required.

Evidence locations:
- LMS/backend/LibrarySystem.cpp
  - dynamic_cast<const Student*>(currentUser) inside LibrarySystem::login(...)
  - dynamic_cast<Student*>(p) inside LibrarySystem::returnBook(...)
  - dynamic_cast<Student*>(p) inside LibrarySystem::updateStudent(...)

- LMS/backend/Auth.cpp
  - dynamic_cast<Student*>(...) used in authentication/user handling paths

- LMS/backend/LibrarySystemBridge.cpp
  - dynamic_cast<const Student*>(person) when preparing user data for QML

3) Encapsulation (Private Members + Getters/Setters)
Encapsulation is applied by keeping member variables private and exposing controlled
access through public functions (getters/setters).

Representative examples:
- Student private members and accessors
  Location:
  - LMS/backend/Auth.h
    - private: status, membership, wallet, etc.
    - public: getStatus(), setStatus(), getMembershipTier(), etc.

- Book private members and accessors
  Location:
  - LMS/backend/BookMembership.h
    - private: isbn/title/author/copies/status, etc.
    - public: getTitle(), getAvailableCopies(), getTotalCopies(), etc.

- Wallet private members and accessors
  Location:
  - LMS/backend/BookMembership.h
    - private: balance, suspended, etc.
    - public: getBalance(), isSuspended(), etc.

4) Bridge Pattern (UI–Logic Separation)
The bridge is implemented as a dedicated QObject class that exposes C++ backend
operations to QML using Q_INVOKABLE functions. QML calls the bridge; the bridge
delegates to the core backend system.

Evidence locations:
- Bridge class definition and QML-facing methods:
  - LMS/backend/LibrarySystemBridge.h
    - class LibrarySystemBridge : public QObject
    - Q_INVOKABLE methods such as login(), getBooks(), issueBook(), etc.

- Bridge instance provided to QML:
  - LMS/main.cpp
    - engine.rootContext()->setContextProperty("lms", &lmsBridge);

- Bridge implementation delegates to backend:
  - LMS/backend/LibrarySystemBridge.cpp
    - calls into m_system.* methods and converts between Qt and std types


============================================================
Project Status (Known Issues / Honest Assessment)
============================================================

Backend Status (Completed / Functional)
- Core backend logic is implemented and structured around the LibrarySystem orchestration:
  - loading users/books/transactions/reviews from the database
  - role-based login and authorization checks
  - issuing/returning books, user registration and updates, review submission/approval
  Evidence:
  - LMS/backend/LibrarySystem.cpp (initializeSystem and major operations)

Known Issues / In-Progress Areas
- UI synchronization is not fully reactive:
  - Most UI data is exposed via on-demand getters (QVariantList returned from bridge),
    and reactive state via Q_PROPERTY signals is not consistently implemented.
  Evidence:
  - LMS/backend/LibrarySystemBridge.h mentions Q_PROPERTY as optional.
- Error handling is partly console-based:
  - Many failures are logged via qDebug/qCritical or represented as boolean returns,
    while user-facing UI feedback (pop-ups/toasts) may not cover every failure path.
- Database/startup dependency:
  - The app exits when Database::connect() fails, which is correct behavior but requires
    correct DB setup for a smooth demo run.
- Some bridge API shapes suggest ongoing refinement:
  - There can be issued related to parameter dependancy
  - Wallet for Library is not saved in Database 

============================================================
Resources
============================================================
- Qt Documentation:
  - Qt Quick, QML/C++ integration, QObject, Q_INVOKABLE, QVariantMap, Qt SQL
- C++ Reference:
  - cppreference.com (dynamic_cast, inheritance, virtual destructors, memory safety)
- OOP / Design Pattern Guides:
  - Bridge Pattern (Gang of Four / reputable OOP pattern references)

