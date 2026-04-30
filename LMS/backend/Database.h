#pragma once
#include <QSqlDatabase>
#include <QString>

struct LoginResult {
    bool success;
    QVariantMap user;
    QString message; // optional (very useful for UI)
};
class Database {
public:
    static bool connect();
    static void init(); // create tables

    // CRUD functions
    static bool addUser(QString id,QString name, QString email, QString password, QString membership, QString role);
    static bool addBook(QString isbn, QString name, QString author, QString genre, QString section, QString publisher,QString edition, QString language,int publicationYear,int total, int available);
    static bool addTransaction(QString txid, int userId, QString isbn, QString status, int fine);
    static bool addReview(QString review_id, int userId, QString isbn, int rating, QString comment, QString status);

    // READ (Array of Objects)
    static QVariantList getUsers();
    static QVariantList getBooks();
    static QVariantList getTransactions();
    static QVariantList getReviews();

    //update
    static bool updateUser(int id, QString name, QString email, QString password, QString membership, QString role);
    static bool updateBook(QString isbn, QString name, QString author, QString genre, QString section, int total, int available);
    static bool updateTransaction(QString txid, QString status, int fine);
    static bool updateReview(QString reviewId, int rating, QString comment, QString status);

    // delete
    static bool deleteUser(int id);
    static bool deleteBook(QString isbn);
    static bool deleteTransaction(QString txid);
    static bool deleteReview(QString reviewId);
    // login result
    static LoginResult loginUser(QString email, QString password);
};
