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
               "status TEXT,"
               "membership TEXT,"
               "expiry_date TEXT,"
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
               "pages INTEGER,"
               "availablecopies INTEGER)");

    query.exec("CREATE TABLE IF NOT EXISTS transactions ("
               "txid TEXT PRIMARY KEY,"
               "user_id TEXT,"
               "isbn TEXT,"
               "issuedate TEXT,"
               "duedate TEXT,"
               "returnDate TEXT,"
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


    query.exec("CREATE TABLE IF NOT EXISTS wallets ("
               "user_id TEXT PRIMARY KEY ,"
               "balance INTEGER,"
               "status INTEGER,"
               "FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE)");
}

bool Database::addUser(QString id,QString name, QString email, QString password, QString membership, QString role, QString status) { // can be used in register and add user both
    QSqlQuery query;

    query.prepare("INSERT INTO users (id, joining_date, name, email, password, status, membership, expiry_date, role) "
                  "VALUES ( ? , date('now'), ?, ?, ?, ?, ?, date('now', '+1 year'), ?)");

    query.addBindValue(id);
    query.addBindValue(name);
    query.addBindValue(email);
    query.addBindValue(password);
    query.addBindValue(status);
    query.addBindValue(membership);
    query.addBindValue(role);

    if (!query.exec()) {
        qDebug() << "Add User Error:" << query.lastError().text();
        return false;
    }

    return true;
}

bool Database::addTransaction(QString txid, QString userId, QString isbn,QString returnDate,QString status , int fine) {
    QSqlQuery query;
    query.prepare("INSERT INTO transactions "
                  "(txid, user_id, isbn, issuedate, duedate,returnDate, status, fine) "
                  "VALUES (?, ?, ?, date('now'), date('now', '+7 days'),?, ?, ?)");

    query.addBindValue(txid);
    query.addBindValue(userId);
    query.addBindValue(isbn);
    query.addBindValue(returnDate);
    query.addBindValue(status);
    query.addBindValue(fine);

    if (!query.exec()) {
        qDebug() << "Add Transaction Error:" << query.lastError().text();
        return false;
    }

    return true;
}

bool Database::addReview(QString review_id, QString userId, QString username, QString isbn, QString bookname, int rating, QString comment, QString status){
    QSqlQuery query;
    query.prepare("INSERT INTO reviews "
                  "(reviewid, user_id, username, isbn, bookname, rating, comment,review_date, status) "
                  "VALUES ( ?, ?, ?, ?, ?, ?, ?,date('now'), ?)");

    query.addBindValue(review_id);
    query.addBindValue(userId);
    query.addBindValue(username);
    query.addBindValue(isbn);
    query.addBindValue(bookname);
    query.addBindValue(rating);
    query.addBindValue(comment);
    query.addBindValue(status);


    if (!query.exec()) {
        qDebug() << "Add Reviews Error:" << query.lastError().text();
        return false;
    }

    return true;
}

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

bool Database::addWallet(QString user_id,int balance,int status)
{
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
        book["edition"] = query.value("edition");
        book["language"] = query.value("language");
        book["publicationyear"] = query.value("publicationyear");
        book["publisher"] = query.value("publisher");
        book["avaliablecopies"] = query.value("availablecopies");
        book["pages"] = query.value("pages");

        books.append(book);
    }

    return books;
}

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
        tx["txid"] = query.value("txid");
        tx["user_id"] = query.value("user_id");
        tx["username"] = query.value("username");
        tx["isbn"] = query.value("isbn");
        tx["issuedate"] = query.value("issuedate");
        tx["duedate"] = query.value("duedate");
        tx["returnDate"] = query.value("returnDate");
        tx["status"] = query.value("status");
        tx["fine"] = query.value("fine");

        transactions.append(tx);
    }

    return transactions;
}

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
        review["reviewid"] = query.value("reviewid");
        review["user_id"] = query.value("user_id");
        review["username"] = query.value("username");
        review["isbn"] = query.value("isbn");
        review["bookname"] = query.value("bookname");
        review["rating"] = query.value("rating");
        review["comment"] = query.value("comment");
        review["status"] = query.value("status");
        review["review_date"] = query.value("review_date");
        reviews.append(review);
    }

    return reviews;
}

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

    // ❌ Nothing to update
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
