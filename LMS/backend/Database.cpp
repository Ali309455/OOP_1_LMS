#include "Database.h"
#include <QCoreApplication>
#include<QDir>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

QSqlDatabase db;

bool Database::connect() {
    db = QSqlDatabase::addDatabase("QSQLITE");
    QString basePath = QCoreApplication::applicationDirPath();

    // Go up from build folder to project root
    QDir dir(basePath);
    dir.cdUp();
    dir.cdUp();    // Debug/
    QString dbpath = dir.filePath("Database/lms.db");
    db.setDatabaseName(dbpath);


    if (!db.open()) {
        qDebug() << "DB Error:" << db.lastError().text();
        return false;
    }

    qDebug() << "Database connected!";
    return true;
}

void Database::init() {
    QSqlQuery query;

    query.exec("PRAGMA foreign_keys = ON;");

    query.exec("CREATE TABLE IF NOT EXISTS users ("
               "id TEXT PRIMARY KEY ,"
               "joining_date TEXT,"
               "name TEXT,"
               "email TEXT UNIQUE,"
               "password TEXT,"
               "membership TEXT,"
               "role TEXT)");

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
               "availablecopies INTEGER)");

    query.exec("CREATE TABLE IF NOT EXISTS transactions ("
               "txid TEXT PRIMARY KEY,"
               "user_id INTEGER,"
               "isbn TEXT,"
               "issuedate TEXT,"
               "duedate TEXT,"
               "status TEXT,"
               "fine INTEGER,"
               "FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,"
               "FOREIGN KEY(isbn) REFERENCES books(isbn)  ON DELETE CASCADE)");

    query.exec("CREATE TABLE IF NOT EXISTS reviews ("
               "reviewid TEXT PRIMARY KEY ,"
               "user_id INTEGER,"
               "isbn TEXT,"
               "rating INTEGER,"
               "comment TEXT,"
               "status TEXT,"
               "FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,"
               "FOREIGN KEY(isbn) REFERENCES books(isbn) ON DELETE CASCADE)");
}

bool Database::addUser(QString id,QString name, QString email, QString password, QString membership, QString role) { // can be used in register and add user both
    QSqlQuery query;

    query.prepare("INSERT INTO users (id, joining_date, name, email, password, membership, role) "
                  "VALUES ( ? , date('now'), ?, ?, ?, ?, ?)");

    query.addBindValue(id);
    query.addBindValue(name);
    query.addBindValue(email);
    query.addBindValue(password);
    query.addBindValue(membership);
    query.addBindValue(role);

    if (!query.exec()) {
        qDebug() << "Add User Error:" << query.lastError().text();
        return false;
    }

    return true;
}

bool Database::addTransaction(QString txid, int userId, QString isbn,QString status, int fine) {
    QSqlQuery query;

    query.prepare("INSERT INTO transactions "
                  "(txid, user_id, isbn, issuedate, duedate, status, fine) "
                  "VALUES (?, ?, ?, date('now'), date('now', '+7 days'), ?, ?)");

    query.addBindValue(txid);
    query.addBindValue(userId);
    query.addBindValue(isbn);
    query.addBindValue(status);
    query.addBindValue(fine);

    if (!query.exec()) {
        qDebug() << "Add Transaction Error:" << query.lastError().text();
        return false;
    }

    return true;
}

bool Database::addReview(QString review_id, int userId, QString isbn, int rating, QString comment, QString status){
    QSqlQuery query;
    query.prepare("INSERT INTO reviews "
                  "(reviewid, user_id, isbn, rating, comment, status) "
                  "VALUES ( ?, ?, ?, ?, ?, ?)");

    query.addBindValue(review_id);
    query.addBindValue(userId);
    query.addBindValue(isbn);
    query.addBindValue(rating);
    query.addBindValue(comment);
    query.addBindValue(status);


    if (!query.exec()) {
        qDebug() << "Add Reviews Error:" << query.lastError().text();
        return false;
    }

    return true;
}

bool Database::addBook(QString isbn,QString name,QString author,QString genre,QString section,QString publisher,QString edition,QString language,int publicationYear,int total,int available)
{
    QSqlQuery query;

    query.prepare("INSERT INTO books "
                  "(isbn, bookname, author, genre, section, publisher, edition, language, publicationYear, totalcopies, availablecopies) "
                  "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

    query.addBindValue(isbn);
    query.addBindValue(name);
    query.addBindValue(author);
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
        user["membership"] = query.value("membership");
        user["role"] = query.value("role");

        users.append(user);
    }

    return users;
}

QVariantList Database::getBooks()
{
    QVariantList books;
    QSqlQuery query("SELECT * FROM books");

    while (query.next()) {
        QVariantMap book;
        book["isbn"] = query.value("isbn");
        book["bookname"] = query.value("bookname");
        book["author"] = query.value("author");
        book["genre"] = query.value("genre");
        book["section"] = query.value("section");
        book["totalcopies"] = query.value("totalcopies");
        book["availablecopies"] = query.value("availablecopies");

        books.append(book);
    }

    return books;
}

QVariantList Database::getTransactions()
{
    QVariantList transactions;
    QSqlQuery query("SELECT * FROM transactions");

    while (query.next()) {
        QVariantMap tx;
        tx["txid"] = query.value("txid");
        tx["user_id"] = query.value("user_id");
        tx["isbn"] = query.value("isbn");
        tx["issuedate"] = query.value("issuedate");
        tx["duedate"] = query.value("duedate");
        tx["status"] = query.value("status");
        tx["fine"] = query.value("fine");

        transactions.append(tx);
    }

    return transactions;
}

QVariantList Database::getReviews()
{
    QVariantList reviews;
    QSqlQuery query("SELECT * FROM reviews");

    while (query.next()) {
        QVariantMap review;
        review["reviewid"] = query.value("reviewid");
        review["user_id"] = query.value("user_id");
        review["isbn"] = query.value("isbn");
        review["rating"] = query.value("rating");
        review["comment"] = query.value("comment");
        review["status"] = query.value("status");

        reviews.append(review);
    }

    return reviews;
}


bool Database::updateUser(int id, QString name, QString email, QString password, QString membership, QString role)
{
    QSqlQuery query;

    query.prepare("UPDATE users SET name=?, email=?, password=?, membership=?, role=? WHERE id=?");

    query.addBindValue(name);
    query.addBindValue(email);
    query.addBindValue(password);
    query.addBindValue(membership);
    query.addBindValue(role);
    query.addBindValue(id);

    if (!query.exec()) {
        qDebug() << "Update User Error:" << query.lastError().text();
        return false;
    }

    return true;
}

bool Database::updateBook(QString isbn,QString name,QString author,QString genre,QString section,QString publisher,QString edition,QString language,int publicationYear,int total,int available)
{
    QSqlQuery query;

    query.prepare(
        "UPDATE books SET "
        "bookname=?, author=?, genre=?, section=?, publisher=?, edition=?, language=?, "
        "publicationYear=?, totalcopies=?, availablecopies=? "
        "WHERE isbn=?"
        );

    query.addBindValue(name);
    query.addBindValue(author);
    query.addBindValue(genre);
    query.addBindValue(section);
    query.addBindValue(publisher);
    query.addBindValue(edition);
    query.addBindValue(language);
    query.addBindValue(publicationYear);
    query.addBindValue(total);
    query.addBindValue(available);
    query.addBindValue(isbn);

    if (!query.exec()) {
        qDebug() << "Update Book Error:" << query.lastError().text();
        return false;
    }

    return true;
}

bool Database::updateTransaction(QString txid, QString status, int fine)
{
    QSqlQuery query;

    query.prepare("UPDATE transactions SET status=?, fine=? WHERE txid=?");

    query.addBindValue(status);
    query.addBindValue(fine);
    query.addBindValue(txid);

    if (!query.exec()) {
        qDebug() << "Update Transaction Error:" << query.lastError().text();
        return false;
    }

    return true;
}

bool Database::updateReview(QString reviewId, int rating, QString comment, QString status)
{
    QSqlQuery query;

    query.prepare("UPDATE reviews SET rating=?, comment=?, status=? WHERE reviewid=?");

    query.addBindValue(rating);
    query.addBindValue(comment);
    query.addBindValue(status);
    query.addBindValue(reviewId);

    if (!query.exec()) {
        qDebug() << "Update Review Error:" << query.lastError().text();
        return false;
    }

    return true;
}


bool Database::deleteUser(int id)
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

    // Plain text check (replace with hash later)
    if (dbPassword != password) {
        result.message = "Incorrect password";
        return result;
    }

    // Success
    result.success = true;
    result.message = "Login successful";

    result.user["id"] = query.value("id");
    result.user["name"] = query.value("name");
    result.user["email"] = query.value("email");
    result.user["membership"] = query.value("membership");
    result.user["role"] = query.value("role");

    return result;
}


// 🔌 Connect DB
// if (!Database::connect()) {
//     qDebug() << "Failed to connect DB";
//     return -1;
// }

// Database::init();

// // =========================
// // ADD TEST DATA
// // =========================
// qDebug() << "\n=== ADD DATA ===";

// Database::addUser("cs-001","Ali", "ali@gmail.com", "123", "gold", "user");
// Database::addUser("cs-002","Admin", "admin@gmail.com", "admin", "premium", "librarian");

// Database::addBook("978-1", "C++ Basics", "Bjarne Stroustrup","Programming", "CS", "Pearson", "1st","English", 2015, 10, 10);

// Database::addTransaction("TX1", 1, "001", "issued", 0);
// Database::addReview("RV1", 1, "001", 5, "Great Book", "approved");


// // =========================
// // 📚 FETCH DATA
// // =========================
// qDebug() << "\n=== USERS ===";
// for (auto u : Database::getUsers()) {
//     qDebug() << u.toMap();
// }

// qDebug() << "\n=== BOOKS ===";
// for (auto b : Database::getBooks()) {
//     qDebug() << b.toMap();
// }

// qDebug() << "\n=== TRANSACTIONS ===";
// for (auto t : Database::getTransactions()) {
//     qDebug() << t.toMap();
// }

// qDebug() << "\n=== REVIEWS ===";
// for (auto r : Database::getReviews()) {
//     qDebug() << r.toMap();
// }


// // =========================
// // 🔄 UPDATE TEST
// // =========================
// qDebug() << "\n=== UPDATE ===";

// Database::updateUser(1, "Ali Updated", "ali@gmail.com", "123", "silver", "user");
// Database::updateBook("001", "Clean Code 2", "Robert Martin", "Programming", "CS", 15, 12);
// Database::updateTransaction("TX1", "returned", 50);
// Database::updateReview("RV1", 4, "Good Book", "approved");

// qDebug() << "After Update:";
// for (auto u : Database::getUsers()) qDebug() << u.toMap();


// // =========================
// // 🔐 LOGIN TEST
// // =========================
// qDebug() << "\n=== LOGIN TEST ===";

// LoginResult res = Database::loginUser("ali@gmail.com", "123");

// if (res.success) {
//     qDebug() << "Login Success:";
//     qDebug() << res.user;
// } else {
//     qDebug() << "Login Failed:" << res.message;
// }


// // =========================
// // ❌ DELETE TEST
// // =========================
// qDebug() << "\n=== DELETE ===";

// Database::deleteReview("RV1");
// Database::deleteTransaction("TX1");
// Database::deleteBook("001");
// Database::deleteUser(1);

// qDebug() << "After Delete Users:";
// for (auto u : Database::getUsers()) qDebug() << u.toMap();
