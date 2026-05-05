#pragma once

#include <QObject>
#include <QString>
#include <QVariant>
#include "LibrarySystem.h"

class LibrarySystemBridge : public QObject {
    Q_OBJECT

    // Optionally, add Q_PROPERTY for reactive property binding (like login state)

public:
    explicit LibrarySystemBridge(QObject *parent = nullptr);

    // -------------------- Authentication ---------------------
    Q_INVOKABLE bool login(const QString& email, const QString& password);
    Q_INVOKABLE void logout();

    // -------------------- User Management --------------------
    Q_INVOKABLE RegistrationResult registerStudent(const QString& name, const QString& email, const QString& pwd,const QString& status, const QString& membership, const QString& role);
    Q_INVOKABLE RegistrationResult registerLibrarian(const QString& name, const QString& email, const QString& pwd, const QString& role);
    Q_INVOKABLE RegistrationResult registerUser(const QString& name, const QString& email, const QString& pwd, const QString& status, const QString& membership, const QString& role);
    Q_INVOKABLE bool updateUser(const QString& name, const QString& email, const QString& pwd, const QString& status, const QString& membership, const QString& role);
    Q_INVOKABLE bool removeUser(const QString& id);

    // -------------------- Book Management --------------------
    Q_INVOKABLE bool addBook(const QString& isbn, const QString& title, const QString& author, const QString& category, const QString& section, const QString& publisher, const QString& edition, const QString& language, int publicationYear, int pages, int totalCopies);
    Q_INVOKABLE bool removeBook(const QString& isbn);

    // -------------------- Transactions --------------------
    Q_INVOKABLE bool issueBook(const QString& isbn, const QString& studentID);
    Q_INVOKABLE bool returnBook(const QString& transactionId);

    // -------------------- Reviews --------------------
    Q_INVOKABLE bool submitReview(const QString& isbn, int rating, const QString& comment);
    Q_INVOKABLE bool approveReview(const QString& reviewId);

    // -------------------- Data Fetching (QML ListModel support) --------------------
    Q_INVOKABLE QVariantList getBooks();
    Q_INVOKABLE QVariantList getUsers();
    Q_INVOKABLE QVariantList getTransactions();
    Q_INVOKABLE QVariantList getReviews();

private:
    LibrarySystem m_system;
};
