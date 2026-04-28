#pragma once
#include <QSqlDatabase>
#include <QString>

class Database {
public:
    static bool connect();
    static void init(); // create tables

    // CRUD functions
    static bool addUser(QString name, QString email, QString password, QString membership, QString role);
    static bool addBook(QString isbn, QString name, QString author, QString genre, QString section, int total, int available);
    static bool addTransaction(QString txid, int userId, QString isbn, QString issueDate, QString dueDate, QString status, int fine);
    static bool addReview(int userId, QString isbn, int rating, QString comment, QString status);
};