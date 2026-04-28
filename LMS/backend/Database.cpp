#include "Database.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

QSqlDatabase db;

bool Database::connect() {
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName("lms.db");

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
               "id INTEGER PRIMARY KEY AUTOINCREMENT,"
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
               "FOREIGN KEY(user_id) REFERENCES users(id),"
               "FOREIGN KEY(isbn) REFERENCES books(isbn))");

    query.exec("CREATE TABLE IF NOT EXISTS reviews ("
               "reviewid INTEGER PRIMARY KEY AUTOINCREMENT,"
               "user_id INTEGER,"
               "isbn TEXT,"
               "rating INTEGER,"
               "comment TEXT,"
               "status TEXT,"
               "FOREIGN KEY(user_id) REFERENCES users(id),"
               "FOREIGN KEY(isbn) REFERENCES books(isbn))");
}
bool Database::addUser(QString name, QString email, QString password, QString membership, QString role) {
    QSqlQuery query;

    query.prepare("INSERT INTO users (joining_date, name, email, password, membership, role) "
                  "VALUES (date('now'), ?, ?, ?, ?, ?)");

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
