#include "Database.h"
#include <QCoreApplication>
#include<QDir>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

QSqlDatabase db;
// establish connection to database
bool Database::connect() {
    db = QSqlDatabase::addDatabase("QSQLITE");
    QString basePath = QCoreApplication::applicationDirPath();

    QDir dir(basePath);
    dir.cdUp();
    dir.cdUp();    
    QString dbpath = dir.filePath("Database/lms.db");
    db.setDatabaseName(dbpath);


    if (!db.open()) {
        qDebug() << "DB Error:" << db.lastError().text();
        return false;
    }

    qDebug() << "Database connected!";
    return true;
}
// create tables if not exist
void Database::init() {
    QSqlQuery query;

    query.exec("PRAGMA foreign_keys = ON;");
    query.exec("CREATE TABLE IF NOT EXISTS libraries ("
               "id TEXT PRIMARY KEY ,"
               "name TEXT,"
               "totalBooks INTEGER,"
               "activeTransactions INTEGER,"
               "pendingReviews INTEGER,"
               "balance INTEGER)");

    query.exec("CREATE TABLE IF NOT EXISTS users ("
               "id TEXT PRIMARY KEY ,"
               "joining_date TEXT,"
               "name TEXT,"
               "email TEXT UNIQUE,"
               "password TEXT,"
               "status TEXT,"
               "membership TEXT,"
               "expiry_date TEXT,"
               "role TEXT,"
                "balance INTEGER)");

    query.exec("CREATE TABLE IF NOT EXISTS books ("
               "isbn TEXT PRIMARY KEY,"
               "bookname TEXT,"
               "author TEXT,"
               "genre TEXT,"
               "section TEXT,"
               "publisher TEXT,"
               "edition TEXT,"
               "language TEXT,"
               "publicationYear INTEGER,"
               "totalcopies INTEGER,"
               "pages INTEGER,"
               "availablecopies INTEGER)");

    query.exec("CREATE TABLE IF NOT EXISTS transactions ("
               "txid TEXT PRIMARY KEY,"
               "user_id TEXT,"
               "isbn TEXT,"
               "issuedate TEXT,"
               "duedate TEXT,"
               "returnDate TEXT,"
               "bookName TEXT,"
               "status TEXT,"
               "fine INTEGER,"
               "FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,"
               "FOREIGN KEY(isbn) REFERENCES books(isbn)  ON DELETE CASCADE)");

    query.exec("CREATE TABLE IF NOT EXISTS reviews ("
               "reviewid TEXT PRIMARY KEY ,"
               "user_id TEXT,"
               "username TEXT,"
               "isbn TEXT,"
               "bookname TEXT,"
               "rating INTEGER,"
               "comment TEXT,"
               "status TEXT,"
               "review_date TEXT,"
               "FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,"
               "FOREIGN KEY(isbn) REFERENCES books(isbn) ON DELETE CASCADE)");


    // query.exec("CREATE TABLE IF NOT EXISTS wallets ("
    //            "user_id TEXT PRIMARY KEY ,"
    //            "balance INTEGER,"
    //            "status INTEGER,"
    //            "FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE)");
}
// function to add user to database
bool Database::addUser(QString id,QString name, QString email, QString password, QString membership, QString role, QString status, double balance) { // can be used in register and add user both
    QSqlQuery query;

    query.prepare("INSERT INTO users (id, joining_date, name, email, password, status, membership, expiry_date, role, balance) "
                  "VALUES ( ? , date('now'), ?, ?, ?, ?, ?, date('now', '+1 year'), ?,?)");

    query.addBindValue(id);
    query.addBindValue(name);
    query.addBindValue(email);
    query.addBindValue(password);
    query.addBindValue(status);
    query.addBindValue(membership);
    query.addBindValue(role);
    query.addBindValue(balance);

    if (!query.exec()) {
        qDebug() << "Add User Error:" << query.lastError().text();
        return false;
    }

    return true;
}
// function to add transaction to database
bool Database::addTransaction(QString txid, QString userId, QString isbn,QString duedate,QString returnDate,QString bookName,QString status , int fine) {
    QSqlQuery query;
    query.prepare("INSERT INTO transactions "
                  "(txid, user_id, isbn, issuedate, duedate,returnDate,bookName, status, fine) "
                  "VALUES (?, ?, ?, date('now'),  ?,?, ?,?, ?)");

    query.addBindValue(txid);
    query.addBindValue(userId);
    query.addBindValue(isbn);
    query.addBindValue(duedate);
    query.addBindValue(returnDate);
    query.addBindValue(bookName);
    query.addBindValue(status);
    query.addBindValue(fine);

    if (!query.exec()) {
        qDebug() << "Add Transaction Error:" << query.lastError().text();
        return false;
    }

    return true;
}
// function to add review to database
bool Database::addReview(QString reviewId, QString userId, QString username, QString isbn, QString bookName, int rating, QString comment, QString status){
    QSqlQuery query;
    query.prepare("INSERT INTO reviews "
                  "(reviewid, user_id, username, isbn, bookname, rating, comment,review_date, status) "
                  "VALUES ( ?, ?, ?, ?, ?, ?, ?,date('now'), ?)");

    query.addBindValue(reviewId);
    query.addBindValue(userId);
    query.addBindValue(username);
    query.addBindValue(isbn);
    query.addBindValue(bookName);
    query.addBindValue(rating);
    query.addBindValue(comment);
    query.addBindValue(status);


    if (!query.exec()) {
        qDebug() << "Add Reviews Error:" << query.lastError().text();
        return false;
    }

    return true;
}
// function to add book to database
bool Database::addBook(QString isbn, QString name, QString author,int pages, QString genre, QString section, QString publisher,QString edition, QString language,int publicationYear,int total, int available)
{
    QSqlQuery query;

    query.prepare("INSERT INTO books "
                  "(isbn, bookname, author, pages , genre, section, publisher, edition, language, publicationYear, totalcopies, availablecopies) "
                  "VALUES (?, ?, ?, ?, ?, ?, ? , ?, ?, ?, ?, ?)");

    query.addBindValue(isbn);
    query.addBindValue(name);
    query.addBindValue(author);
    query.addBindValue(pages);
    query.addBindValue(genre);
    query.addBindValue(section);
    query.addBindValue(publisher);
    query.addBindValue(edition);
    query.addBindValue(language);
    query.addBindValue(publicationYear);
    query.addBindValue(total);
    query.addBindValue(available);

    if (!query.exec()) {
        qDebug() << "Add Book Error:" << query.lastError().text();
        return false;
    }

    return true;
}

bool Database::addWallet(QString user_id,int balance,int status){
    QSqlQuery query;

    query.prepare("INSERT INTO wallets"
                  "( user_id, balance, status) "
                  "VALUES (?, ?, ?)");

    query.addBindValue(user_id);
    query.addBindValue(balance);
    query.addBindValue(status);

    if (!query.exec()) {
        qDebug() << "Add Book Error:" << query.lastError().text();
        return false;
    }

    return true;
};

bool Database::addLibrary(QString id,QString name,int totalBooks,int activeTransactions,int pendingReviews,int balance){
    QSqlQuery query;

    query.prepare(
        "INSERT INTO libraries "
        "(id, name, totalBooks, activeTransactions, pendingReviews, balance) "
        "VALUES (?, ?, ?, ?, ?, ?)"
        );

    query.addBindValue(id);
    query.addBindValue(name);
    query.addBindValue(totalBooks);
    query.addBindValue(activeTransactions);
    query.addBindValue(pendingReviews);
    query.addBindValue(balance);

    if (!query.exec()) {
        qDebug() << "Add Library Error:" << query.lastError().text();
        return false;
    }

    return true;
}

QVariantList Database::getUsers()
{
    QVariantList users;
    QSqlQuery query("SELECT * FROM users");

    while (query.next()) {
        QVariantMap user;
        user["id"] = query.value("id");
        user["joining_date"] = query.value("joining_date");
        user["name"] = query.value("name");
        user["email"] = query.value("email");
        user["password"] = query.value("password");
        user["membership"] = query.value("membership");
        user["role"] = query.value("role");
        user["status"] = query.value("status");
        user["expiry_date"] = query.value("expiry_date");
        user["balance"] = query.value("balance");
        users.append(user);
    }

    return users;
}
// function to get all books from database
QVariantList Database::getBooks()
{
    QVariantList books;
    QSqlQuery query("SELECT * FROM books");

    while (query.next()) {
        QVariantMap book;
        book["isbn"] = query.value("isbn");
        book["bookName"] = query.value("bookname");
        book["author"] = query.value("author");
        book["genre"] = query.value("genre");
        book["section"] = query.value("section");
        book["totalCopies"] = query.value("totalcopies");
        book["edition"] = query.value("edition");
        book["language"] = query.value("language");
        book["publicationYear"] = query.value("publicationYear");
        book["publisher"] = query.value("publisher");
        book["availableCopies"] = query.value("availablecopies");
        book["pages"] = query.value("pages");

        books.append(book);
    }

    return books;
}
// function to get all transactions from database
QVariantList Database::getTransactions()
{
    QVariantList transactions;

    QSqlQuery query(
        "SELECT transactions.*, users.name AS username "
        "FROM transactions "
        "INNER JOIN users ON transactions.user_id = users.id"
        );

    while (query.next()) {
        QVariantMap tx;
        tx["txId"] = query.value("txid");
        tx["userId"] = query.value("user_id");
        tx["username"] = query.value("username");
        tx["isbn"] = query.value("isbn");
        tx["issueDate"] = query.value("issuedate");
        tx["dueDate"] = query.value("duedate");
        tx["returnDate"] = query.value("returnDate");
        tx["bookName"] = query.value("bookName");
        tx["status"] = query.value("status");
        tx["fine"] = query.value("fine");

        transactions.append(tx);
    }

    return transactions;
}
// function to get all reviews from database
QVariantList Database::getReviews()
{
    QVariantList reviews;
    QSqlQuery query(
        "SELECT reviews.*, users.name AS username, books.bookname AS bookname "
        "FROM reviews "
        "INNER JOIN users ON reviews.user_id = users.id "
        "INNER JOIN books ON reviews.isbn = books.isbn"
        );

    while (query.next()) {
        QVariantMap review;
        review["reviewId"] = query.value("reviewid");
        review["userId"] = query.value("user_id");
        review["username"] = query.value("username");
        review["isbn"] = query.value("isbn");
        review["bookName"] = query.value("bookname");
        review["rating"] = query.value("rating");
        review["comment"] = query.value("comment");
        review["status"] = query.value("status");
        review["reviewDate"] = query.value("review_date");
        reviews.append(review);
    }

    return reviews;
}
// function to get all wallets from database
QVariantList Database::getWallets()
{
    QVariantList wallets;
    QSqlQuery query("SELECT * FROM wallets");

    while (query.next()) {
        QVariantMap wallet;
        wallet["user_id"] = query.value("user_id");
        wallet["balance"] = query.value("balance");
        wallet["status"] = query.value("status");

        wallets.append(wallet);
    }

    return wallets;
}

QVariantMap Database::getLibraryById(const QString& id)
{
    QVariantMap library;

    QSqlQuery query;
    query.prepare("SELECT * FROM libraries WHERE id = :id");
    query.bindValue(":id", id);

    if (!query.exec()) {
        qDebug() << "DB Error:" << query.lastError().text();
        return library; // empty map
    }

    if (query.next()) {
        library["id"] = query.value("id");
        library["name"] = query.value("name");
        library["totalBooks"] = query.value("totalBooks");
        library["activeTransactions"] = query.value("activeTransactions");
        library["pendingReviews"] = query.value("pendingReviews");
        library["balance"] = query.value("balance");
    }

    return library;
}



bool Database::updateUser(QString id, QString name, QString email, QString password, QString membership, QString role,QString status)
{
    QSqlQuery query;

    query.prepare("UPDATE users SET name=?, email=?, password=?, membership=?,  expiry_date=date('now','+1 year'), status=?, role=? WHERE id=?");

    query.addBindValue(name);
    query.addBindValue(email);
    query.addBindValue(password);
    query.addBindValue(membership);
    query.addBindValue(status);
    query.addBindValue(role);
    query.addBindValue(id);

    if (!query.exec()) {
        qDebug() << "Update User Error:" << query.lastError().text();
        return false;
    }

    return true;
}
// function to update user wallet balance in database
bool Database::updateUser(QString id, int balance)
{
    QSqlQuery query;

    query.prepare("UPDATE users SET balance=? WHERE id=?");

    query.addBindValue(balance);
    query.addBindValue(id);

    if (!query.exec()) {
        qDebug() << "Update User Error:" << query.lastError().text();
        return false;
    }

    return true;
}
// function to update book count in database
bool Database::updateBook(QString isbn,int total,int available)
{
    QSqlQuery query;

    query.prepare(
        "UPDATE books SET "
        " totalcopies=?, availablecopies=? "
        "WHERE isbn=?"
        );

    query.addBindValue(total);
    query.addBindValue(available);
    query.addBindValue(isbn);

    if (!query.exec()) {
        qDebug() << "Update Book Error:" << query.lastError().text();
        return false;
    }

    return true;
}
// function to update transaction status and fine in database
bool Database::updateTransaction(QString txid, QString status, int fine, QString returndate)
{
    QSqlQuery query;

    query.prepare("UPDATE transactions SET status=?, fine=?,returnDate=? WHERE txid=?");

    query.addBindValue(status);
    query.addBindValue(fine);
    query.addBindValue(returndate);
    query.addBindValue(txid);

    if (!query.exec()) {
        qDebug() << "Update Transaction Error:" << query.lastError().text();
        return false;
    }

    return true;
}
// function to update review rating, comment and status in database
bool Database::updateReview(QString reviewId,std::optional<int> rating ,std::optional<QString> comment,std::optional<QString> status )
{
    QSqlQuery query;
    QString queryStr = "UPDATE reviews SET ";
    QList<QString> updates;
    QList<QVariant> values;

    if (rating.has_value()) {
        updates.append("rating=?");
        values.append(rating.value());
    }

    if (comment.has_value()) {
        updates.append("comment=?");
        values.append(comment.value());
    }

    if (status.has_value()) {
        updates.append("status=?");
        values.append(status.value());
    }

    if (updates.isEmpty()) {
        qDebug() << "No fields provided to update";
        return false;
    }

    queryStr += updates.join(", ");
    queryStr += " WHERE reviewid=?";

    query.prepare(queryStr);

    for (const auto& val : values)
        query.addBindValue(val);

    query.addBindValue(reviewId);

    if (!query.exec()) {
        qDebug() << "Update Review Error:" << query.lastError().text();
        return false;
    }

    return true;
}

bool Database::updateLibrary(QString id,int totalBooks,int activeTransactions,int pendingReviews, int balance){
    QSqlQuery query;

    query.prepare(
        "UPDATE libraries SET "
        "totalBooks=?, "
        "activeTransactions=?, "
        "pendingReviews=?, "
        "balance=? "
        "WHERE id=?"
        );

    query.addBindValue(totalBooks);
    query.addBindValue(activeTransactions);
    query.addBindValue(pendingReviews);
    query.addBindValue(balance);
    query.addBindValue(id);

    if (!query.exec()) {
        qDebug() << "Update Library Error:" << query.lastError().text();
        return false;
    }

    return true;
}



bool Database::deleteUser(QString id)
{
    QSqlQuery query;

    query.prepare("DELETE FROM users WHERE id=?");
    query.addBindValue(id);

    if (!query.exec()) {
        qDebug() << "Delete User Error:" << query.lastError().text();
        return false;
    }

    return true;
}
// function to delete book from database in case of book being outdated or any other reason
bool Database::deleteBook(QString isbn)
{
    QSqlQuery query;

    query.prepare("DELETE FROM books WHERE isbn=?");
    query.addBindValue(isbn);

    if (!query.exec()) {
        qDebug() << "Delete Book Error:" << query.lastError().text();
        return false;
    }

    qDebug() << "Book deleted:" << isbn;
    return true;
}
// function to delete transaction from database in case of any error or any other reason
bool Database::deleteTransaction(QString txid)
{
    QSqlQuery query;

    query.prepare("DELETE FROM transactions WHERE txid=?");
    query.addBindValue(txid);

    if (!query.exec()) {
        qDebug() << "Delete Transaction Error:" << query.lastError().text();
        return false;
    }

    return true;
}
// function to delete review from database in case of inappropriate content or any other reason
bool Database::deleteReview(QString reviewId)
{
    QSqlQuery query;

    query.prepare("DELETE FROM reviews WHERE reviewid=?");
    query.addBindValue(reviewId);

    if (!query.exec()) {
        qDebug() << "Delete Review Error:" << query.lastError().text();
        return false;
    }

    return true;
}
// function to get maximum ID number for users or books to generate new ID in sequence
int Database::getMaxIdNumber(const QString& table, const QString& column, const QString& prefix) {
    QSqlQuery query;
    query.prepare("SELECT MAX(CAST(SUBSTR(" + column + ", LENGTH(?) + 2) AS INTEGER)) FROM " + table);
    query.addBindValue(prefix);

    if (!query.exec() || !query.next()) {
        qDebug() << "ID fetch error:" << query.lastError().text();
        return 0;
    }

    return query.value(0).toInt();
}
// function to handle user login and return login result with user details if successful or error message if failed
LoginResult Database::loginUser(QString email, QString password)
{
    QSqlQuery query;

    query.prepare("SELECT id, name, email, password, membership, role FROM users WHERE email=?");
    query.addBindValue(email);

    LoginResult result;
    result.success = false;

    if (!query.exec()) {
        result.message = "Database error";
        qDebug() << "Login Error:" << query.lastError().text();
        return result;
    }

    if (!query.next()) {
        result.message = "User not found";
        return result;
    }

    QString dbPassword = query.value("password").toString();

    if (dbPassword != password) {
        result.message = "Incorrect password";
        return result;
    }
    result.success = true;
    result.message = "Login successful";

    result.user["id"] = query.value("id");
    result.user["name"] = query.value("name");
    result.user["email"] = query.value("email");
    result.user["membership"] = query.value("membership");
    result.user["role"] = query.value("role");

    return result;
}

