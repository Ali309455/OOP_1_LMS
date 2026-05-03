#include<iostream>
#include"LibrarySystem.h"
#include<qDebug>
#include <QDate>
#include <QString>
using namespace std;



QString getDate(int addDays = 0)
{
    QDate date = QDate::currentDate().addDays(addDays);
    return date.toString("yyyy-MM-dd");  // DB-friendly format
}

LibrarySystem::LibrarySystem()
{

}
string LibrarySystem::generateId(const std::string& prefix, int count)
{
    return prefix + "-" + std::to_string(count + 1);
}
void LibrarySystem::loadUsersIntoSystem()
{
    QVariantList users = Database::getUsers();

    for (auto u : users) {
                // qDebug() << u.toMap();
            // }
        QVariantMap map = u.toMap();

        std::string id = map["id"].toString().toStdString();
        std::string name = map["name"].toString().toStdString();
        std::string email = map["email"].toString().toStdString();
        std::string password = map["password"].toString().toStdString();
        std::string role = map["role"].toString().toStdString();

        Person* person = nullptr;

        if (role == "user" || role == "student") {
            person = new Student(id, name, email, password);
        } else if (role == "librarian") {
            person = new Librarian(id, name, email, password,"cs211");
        }

        if (person) {
            authManager.registerPerson(person);
        }
    }
}

void LibrarySystem::loadBooksIntoSystem()
{
    QVariantList books = Database::getBooks();

    for (const auto& b : books) {
              // qDebug() << b.toMap();
        QVariantMap map = b.toMap();
        std::string isbn = map["isbn"].toString().toStdString();
        std::string title = map["bookname"].toString().toStdString();
        std::string author = map["author"].toString().toStdString();
        std::string category = map["genre"].toString().toStdString();
        std::string section = map["section"].toString().toStdString();
        std::string publisher = map["publisher"].toString().toStdString();
        std::string edition = map["edition"].toString().toStdString();
        std::string language = map["language"].toString().toStdString();

        int publicationYear = map["publicationyear"].toInt();
        int pages = map["pages"].toInt();
        int totalCopies = map["totalcopies"].toInt();
        int avaliableCopies = map["avaliablecopies"].toInt();

        // Create Book object
        Book book(isbn, title, author, category, section,
                  publisher, edition, language,
                  publicationYear, pages, totalCopies);

        // Add to catalog
        BooksManager.addBook(book);
    }
}

void LibrarySystem::loadTransactionsIntoSystem()
{
    QVariantList transactions = Database::getTransactions();

    for (const auto& t : transactions) {
        QVariantMap map = t.toMap();
            // qDebug() << t.toMap();
        std::string transactionId = map["txid"].toString().toStdString();
        std::string studentId     = map["user_id"].toString().toStdString();
        std::string isbn          = map["isbn"].toString().toStdString();
        std::string issueDate     = map["issuedate"].toString().toStdString();
        std::string dueDate       = map["duedate"].toString().toStdString();
        std::string returnDate    = map["returnDate"].toString().toStdString();
        std::string status        = map["status"].toString().toStdString();

        int fine = map["fine"].toInt();

        // Create object
        transaction tr(transactionId, studentId, isbn,
                       issueDate, dueDate, returnDate,
                       status, fine);

        // Add to manager
        TransactionManager.addTransaction(tr);
    }
}

void LibrarySystem::loadReviewsIntoSystem()
{
    QVariantList reviews = Database::getReviews();

    for (const auto& r : reviews) {
        QVariantMap map = r.toMap();

        std::string reviewId  = map["reviewid"].toString().toStdString();
        std::string studentId = map["user_d"].toString().toStdString();
        std::string isbn      = map["isbn"].toString().toStdString();
        int rating            = map["rating"].toInt();
        std::string comment   = map["comment"].toString().toStdString();
        std::string status    = map["status"].toString().toStdString();
        std::string reviewDate= map["review_date"].toString().toStdString();

        // Create object
        Review review(reviewId, studentId, isbn,
                      rating, comment, status, reviewDate);

        // Add to manager
        ReviewManager.addReview(review);
    }
}

void LibrarySystem::loadWalletsIntoSystem()
{
    QVariantList wallets = Database::getWallets();

    for (const auto& w : wallets) {
        QVariantMap map = w.toMap();

        std::string id = map["id"].toString().toStdString();
        double balance = map["balance"].toDouble();
        int sus = map["suspended"].toInt();

        // Create Wallet object

        // Add to manager
        WalletsManager.createWallet(id, balance,sus);
    }
}

void LibrarySystem::initializeSystem(){
    loadUsersIntoSystem();
    loadBooksIntoSystem();
    loadTransactionsIntoSystem();
    loadReviewsIntoSystem();
    loadWalletsIntoSystem();
}

bool LibrarySystem::login(const std::string& email, const std::string& password) {

    try {
        currentUser = authManager.login(email, password);
        std::cout << "[Login] Welcome, " << (currentUser ? currentUser->getName() : "Unknown") << "\n";
        return currentUser != nullptr;

    } catch (const std::exception& ex) {
        std::cout << "[Login Failed] " << ex.what() << "\n";
        currentUser = nullptr;
        return false;
    }
}

void LibrarySystem::logout() { currentUser = nullptr; }

bool LibrarySystem::issueBook(const string& isbn, const string& sid) {
    if (!currentUser || currentUser->getRole() != "LIBRARIAN")
        return false;                          // permission check HERE
    Book* b = BooksManager.findByIsbn(isbn);
    if (!b || b->getAvailableCopies() == 0) return false;
    string txid =  generateId("TX",transactionlog::transactioncount);
    Database::addTransaction(QString::fromStdString(txid),QString::fromStdString(sid),QString::fromStdString(isbn),"","issued",0);
    return TransactionManager.issueBook(txid,sid,isbn,getDate().toStdString(),getDate(7).toStdString());
}

bool LibrarySystem::returnBook(const string& txnID) {
    if (!currentUser || currentUser->getRole() != "LIBRARIAN"){
        return false;}
    transaction* t = TransactionManager.findTransactionById(txnID);
    if (!t || t->isReturned()) return false;
    double fine = FineCalc.calculateFinalFine(t->getDueDate(),t->getReturnDate(),"gold");
    t->markReturned(getDate().toStdString(),fine);
    BooksManager.findByIsbn(t->getIsbn())->returnOneCopy();
    return Database::updateTransaction(QString::fromStdString(t->getTransactionId()),"returned",t->getFine());
}

bool LibrarySystem::approveReview(const string& reviewID) {
    if (!currentUser || currentUser->getRole() != "LIBRARIAN")
        return false;
    ReviewManager.approveReview(reviewID);
    return Database::updateReview(QString::fromStdString(reviewID),std::nullopt, std::nullopt, QString::fromStdString("approved"));  // delegate to service
}

