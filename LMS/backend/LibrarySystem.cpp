#include <iostream>
#include "LibrarySystem.h"
#include "BookMembership.h"
#include <qDebug>
#include <QDate>
#include <QString>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QVariant>
#include <QFileInfo>
#include <QDateTime>
#include <QTextDocument>
#include <QPrinter>
#include <QDir>
#include <QApplication>
using namespace std;

void LibrarySystem::syncLibraryStats()
{  // qDebug()<<libraryWallet.getBalance();
    Database::updateLibrary( "LIB-NED",totalBooks,activeTransations,pendingReviews,libraryWallet.getBalance());
}
static QString htmlEscape(QString s) {
    return s.replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
        .replace('\'', "&#39;");
}
// function to export database report to pdf
bool LibrarySystem::exportDatabaseReportPdf(const QString &outputPdfPath, QString *outError)
{
    QSqlDatabase db = QSqlDatabase::database();
    if (!db.isValid() || !db.isOpen())
    {
        if (outError)
            *outError = "Database is not open. Call Database::connect() first.";
        return false;
    }

    // 1) Fetch table list
    QStringList tables;
    {
        QSqlQuery q(db);

        if (!q.exec(R"(
        SELECT name
        FROM sqlite_master
        WHERE type='table'
        AND name NOT LIKE 'sqlite_%'
        AND name NOT IN ( 'wallets')
        ORDER BY name;
    )"))
        {
            if (outError)
                *outError = "Failed to read table list: " + q.lastError().text();
            return false;
        }

        while (q.next())
            tables << q.value(0).toString();
    }

    // 2) Build HTML
    QString html;
    html += "<html><head><meta charset='utf-8'/>";
    html += R"(
<style>
  body { font-family: Arial, Helvetica, sans-serif; font-size: 8pt; color: #111; }
  .header { margin-bottom: 14px; }
  .title { font-size: 18pt; font-weight: 700; margin: 0; }
  .meta { color: #444; margin-top: 4px; }
  .section { margin-top: 18px; page-break-inside: avoid; }
  .section h2 { font-size: 13pt; margin: 0 0 8px 0; padding: 6px 8px; background: #f2f4f7; border: 1px solid #d9dee7; }
  .submeta { font-size: 9pt; color: #555; margin: 6px 0 8px 0; }
  table { border-collapse: collapse; width: 100%; table-layout: fixed; }
  th, td { border: 1px solid #d0d7de; padding: 6px 6px; vertical-align: top; word-wrap: break-word; }
  th { background: #111827; color: #fff; font-weight: 600; }
  tr:nth-child(even) td { background: #f9fafb; }
  .empty { color: #666; font-style: italic; padding: 8px 0; }
</style>
)";
    html += "</head><body>";

    const QString dbName = QFileInfo(db.databaseName()).absoluteFilePath();
    html += "<div class='header'>";
    html += "<p class='title'>LMS Database Report</p>";
    html += "<div class='meta'>Generated: " + htmlEscape(QDateTime::currentDateTime().toString(Qt::ISODate)) + "</div>";
    html += "<div class='meta'>Database: " + htmlEscape(dbName) + "</div>";
    html += "<div class='meta'>Tables: " + QString::number(tables.size()) + "</div>";
    html += "</div>";

    for (const QString &table : tables)
    {
        // Row count
        int rowCount = -1;
        {
            QSqlQuery qc(db);
            if (qc.exec("SELECT COUNT(*) FROM \"" + table + "\";") && qc.next())
                rowCount = qc.value(0).toInt();
        }

        html += "<div class='section'>";
        html += "<h2>Table: " + htmlEscape(table) + "</h2>";
        html += "<div class='submeta'>Rows: " + QString::number(rowCount) + "</div>";

        QSqlQuery q(db);
        if (!q.exec("SELECT * FROM \"" + table + "\";"))
        {
            html += "<div class='empty'>Error reading table: " + htmlEscape(q.lastError().text()) + "</div>";
            html += "</div>";
            continue;
        }

        QSqlRecord rec = q.record();
        const int colCount = rec.count();

        if (colCount <= 0)
        {
            html += "<div class='empty'>No columns found.</div></div>";
            continue;
        }

        // Table header
        html += "<table><thead><tr>";
        for (int c = 0; c < colCount; ++c)
            html += "<th>" + htmlEscape(rec.fieldName(c)) + "</th>";
        html += "</tr></thead><tbody>";

        bool anyRow = false;
        while (q.next())
        {
            anyRow = true;
            html += "<tr>";
            for (int c = 0; c < colCount; ++c)
            {
                const QVariant v = q.value(c);
                QString cell = v.isNull() ? "NULL" : v.toString();
                html += "<td>" + htmlEscape(cell) + "</td>";
            }
            html += "</tr>";
        }
        html += "</tbody></table>";

        if (!anyRow)
            html += "<div class='empty'>No data.</div>";
        html += "</div>";
    }

    html += "</body></html>";

    // 3) Render HTML -> PDF
    QTextDocument doc;
    doc.setHtml(html);

    QPrinter printer(QPrinter::HighResolution);
    printer.setOutputFormat(QPrinter::PdfFormat);
    QString basePath = QCoreApplication::applicationDirPath();
    QDir dir(basePath);
    dir.cdUp();
    dir.cdUp();
    QString pdfpath = dir.filePath(outputPdfPath);
    printer.setOutputFileName(pdfpath);

    // A4 with reasonable margins
    printer.setPageSize(QPageSize(QPageSize::A4));
    printer.setPageMargins(QMarginsF(3, 1, 1, 3), QPageLayout::Millimeter);

    doc.print(&printer);

    if (!QFileInfo::exists(outputPdfPath) || QFileInfo(outputPdfPath).size() == 0)
    {
        if (outError)
        {
            qDebug() << "PDF was not created (check output path permissions).";
            return false;
        }
    }
    return true;
}

// Helper function to get current date as string
QString getDate(int addDays = 0)
{
    QDate date = QDate::currentDate().addDays(addDays);
    return date.toString("yyyy-MM-dd");
}

LibrarySystem::LibrarySystem(): libraryWallet("LIBRARY", 0),totalBooks(0),activeTransations(0),pendingReviews(0){
    Database::init();
    initializeSystem();
    QVariantMap data = Database::getLibraryById("LIB-NED");
    if (!data.isEmpty()) {
        double balance = data["balance"].toDouble();
        qDebug() << balance;
        libraryWallet.setbalance(balance);
    }
}
// Function to generate unique IDs for users and books based on prefix and max ID from database
string LibrarySystem::generateId(const std::string &prefix, int maxIdFromDB)
{
    // return prefix + "-" + std::to_string(maxIdFromDB + 1);
    if (maxIdFromDB < 0)
        maxIdFromDB = 0;
    return prefix + "-" + std::to_string(maxIdFromDB + 1);
}
// function to load users from database into system memory
void LibrarySystem::loadUsersIntoSystem()
{
    QVariantList users = Database::getUsers();

    for (auto u : users)
    {
        try
        {
            QVariantMap map = u.toMap();

            // Extract values
            std::string id = map["id"].toString().toStdString();
            std::string name = map["name"].toString().toStdString();
            std::string email = map["email"].toString().toStdString();
            std::string password = map["password"].toString().toStdString();
            std::string status = map["status"].toString().toStdString();
            std::string role = map["role"].toString().toStdString();
            std::string membership = map["membership"].toString().toStdString();
            int balance = map["balance"].toInt();
            // Check for empty fields using standard logic
            if (id.empty() || name.empty() || email.empty() || password.empty() || role.empty())
            {
                // std::invalid_argument is the standard way to flag bad data input
                throw std::invalid_argument("Crucial user data is missing in database record.");
            }

            Person *person = nullptr;
            transform(role.begin(), role.end(), role.begin(), ::toupper);
            if (role == ROLE_STUDENT)
            {
                if (membership.empty())
                {
                    throw std::invalid_argument("Membership field is empty for student: " + name);
                }
                person = new Student(id, name, email, password, status, membership, balance);
            }
            else if (role == ROLE_LIBRARIAN)
            {
                person = new Librarian(id, name, email, password, "cs211");
            }
            else
            {
                throw std::runtime_error("Unrecognized role type: " + role);
            }

            if (person)
            {
                authManager.registerPerson(person);
            }
        }
        catch (const std::invalid_argument &e)
        {
            qCritical() << "Data Validation Error:" << e.what();
            continue;
        }
        catch (const std::runtime_error &e)
        {
            qCritical() << "System Runtime Error:" << e.what();
            continue;
        }
        catch (const std::exception &e)
        {
            qCritical() << "Standard Exception:" << e.what();
            continue;
        }
    }
}
// function to load books from database into system memory
void LibrarySystem::loadBooksIntoSystem()
{
    QVariantList books = Database::getBooks();

    for (const auto &b : books)
    {
        QVariantMap map = b.toMap();
        try
        {
            // Extract values
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

            // Check if any critical string field is empty
            if (isbn.empty() || title.empty() || author.empty() || category.empty() ||
                section.empty() || publisher.empty() || language.empty())
            {
                throw std::runtime_error("One or more required text fields are empty.");
            }
            // Check for invalid numeric values
            if (publicationYear <= 0 || pages <= 0 || totalCopies < 0)
            {
                throw std::runtime_error("Numeric fields must contain valid positive values.");
            }
            // Create Book object
            Book book(isbn, title, author, category, section,
                      publisher, edition, language,
                      publicationYear, pages, totalCopies, avaliableCopies);

            BooksManager.addBook(book);
        }
        catch (const std::exception &e)
        {
            qDebug() << "Error creating book:" << e.what();
        }
    }
    settotalBooks(BooksManager.bookcount);
}
// function to load transactions from database into system memory
void LibrarySystem::loadTransactionsIntoSystem()
{
    QVariantList transactions = Database::getTransactions();
    int activeCnt = 0;
    for (const auto &t : transactions)
    {
        try
        {
            QVariantMap map = t.toMap();
            // Extract values
            std::string transactionId = map["txid"].toString().toStdString();
            std::string studentId = map["user_id"].toString().toStdString();
            std::string username = map["username"].toString().toStdString();
            std::string isbn = map["isbn"].toString().toStdString();
            std::string issueDate = map["issuedate"].toString().toStdString();
            std::string dueDate = map["duedate"].toString().toStdString();
            std::string returnDate = map["returnDate"].toString().toStdString();
            std::string status = map["status"].toString().toStdString();
            std::string bookName = map["bookName"].toString().toStdString();

            // 1. Check for crucial empty fields
            if (transactionId.empty() || studentId.empty() || username.empty() || isbn.empty() ||
                issueDate.empty() || dueDate.empty() || status.empty())
            {
                throw std::invalid_argument("Transaction " + transactionId + " is missing required data.");
            }

            int fine = map["fine"].toInt();
            // 2. Validate numeric logic (fine shouldn't be negative)
            if (fine < 0)
            {
                throw std::runtime_error("Invalid fine amount for Transaction ID: " + transactionId);
            }

            // 3. Create object
            transaction tr(transactionId, studentId, username, isbn,
                           issueDate, dueDate, returnDate, bookName,
                           status, fine);

            // 4. Add to manager
            qDebug() << "status " + status;
            if (status == "active")
            {
                qDebug() << "here";
                setactiveTransations(++activeCnt);
            };
            TransactionManager.addTransaction(tr);
        }
        catch (const std::invalid_argument &e)
        {
            qCritical() << "Transaction Data Error:" << e.what();
            continue; 
        }
        catch (const std::runtime_error &e)
        {
            qCritical() << "Transaction Runtime Error:" << e.what();
            continue;
        }
        catch (const std::exception &e)
        {
            qCritical() << "General Exception during transaction load:" << e.what();
            continue;
        }
    }
}
// function to load reviews from database into system memory
void LibrarySystem::loadReviewsIntoSystem()
{
    QVariantList reviews = Database::getReviews();
    int pendingr = 0;
    for (const auto &r : reviews)
    {
        try
        {
            QVariantMap map = r.toMap();
            // Extract values
            std::string reviewId = map["reviewid"].toString().toStdString();
            std::string studentId = map["user_id"].toString().toStdString();
            std::string username = map["username"].toString().toStdString();
            std::string isbn = map["isbn"].toString().toStdString();
            std::string bookname = map["bookname"].toString().toStdString();
            std::string comment = map["comment"].toString().toStdString();
            std::string status = map["status"].toString().toStdString();
            std::string reviewDate = map["review_date"].toString().toStdString();
            int rating = map["rating"].toInt();

            // 1. Check for crucial empty fields
            if (reviewId.empty() || studentId.empty() || isbn.empty() || status.empty())
            {
                throw std::invalid_argument("Required review metadata is missing for ID: " + reviewId);
            }
            // 2. Validate rating range (Standard 1-5 scale check)
            if (rating < 1 || rating > 5)
            {
                throw std::out_of_range("Rating for review " + reviewId + " must be between 1 and 5.");
            }
            // 3. Create object
            Review review(reviewId, studentId, username, isbn, bookname,
                          rating, comment, status, reviewDate);
            // 4. Add to manager
            if (status == "pending")
            {
                setpendingReviews(++pendingr);
            }
            ReviewManager.addReview(review);
        }
        catch (const std::invalid_argument &e)
        {
            qCritical() << "Data Error:" << e.what();
            continue; 
        }
        catch (const std::out_of_range &e)
        {
            qCritical() << "Range Error:" << e.what();
            continue;
        }
        catch (const std::exception &e)
        {
            qCritical() << "General Exception loading review:" << e.what();
            continue;
        }
    }
}
// function to load wallets from database into system memory
void LibrarySystem::loadWalletsIntoSystem()
{
    QVariantList wallets = Database::getWallets();

    for (const auto &w : wallets)
    {
        QVariantMap map = w.toMap();
        // Extract values
        std::string id = map["id"].toString().toStdString();
        double balance = map["balance"].toDouble();
        int sus = map["suspended"].toInt();

        // Create Wallet object

        // Add to manager
        // WalletsManager.createWallet(id, balance,sus);
    }
}



void LibrarySystem::initializeSystem(){
    loadUsersIntoSystem();
    loadBooksIntoSystem();
    loadTransactionsIntoSystem();
    loadReviewsIntoSystem();
    loadWalletsIntoSystem();
}
// ========= setters & getters =========
int LibrarySystem::gettotalBooks() const
{
    return totalBooks;
};
int LibrarySystem::getactiveTransations() const
{
    return activeTransations;
};
int LibrarySystem::getpendingReviews() const
{
    return pendingReviews;
};

void LibrarySystem::settotalBooks(int tb) { totalBooks = tb; };
void LibrarySystem::setactiveTransations(int transactions) { activeTransations = transactions; };
void LibrarySystem::setpendingReviews(int r) { pendingReviews = r; };

double LibrarySystem::getLibraryBalance() const
{
    return libraryWallet.getBalance();
}
// -------------------> Auht <---------------------------

#include <QVariantMap>
// function to authenticate user and return user details
QVariantMap LibrarySystem::login(const std::string &email, const std::string &password) 
{
    QVariantMap result;
    try
    {
        currentUser = authManager.login(email, password);
        if (!currentUser)
        {
            result["success"] = false;
            result["message"] = "Invalid email or password";
            return result;
        }

        // Common fields for all
        result["success"] = true;
        result["userId"] = QString::fromStdString(currentUser->getUserID());
        result["name"] = QString::fromStdString(currentUser->getName());
        result["email"] = QString::fromStdString(currentUser->getEmail());
        result["role"] = QString::fromStdString(currentUser->getRole());
        result["password"] = QString::fromStdString(currentUser->getPassword());
        // Dynamic fields for students
        const Student *student = dynamic_cast<const Student *>(currentUser);
        if (student)
        {
            result["membership"] = QString::fromStdString(student->getMembershipTier());
            result["status"] = QString::fromStdString(student->getStatus());
        }
        else
        {
            // For librarians, status/membership might be "N/A" 
            result["membership"] = "N/A";
            result["status"] = "N/A";
        }

        return result;
    }
    catch (const std::exception &ex)
    {
        result["success"] = false;
        result["message"] = ex.what();
        return result;
    }
}
// function to log out the current user by clearing the user context
void LibrarySystem::logout() { currentUser = nullptr; }

// -------------------> transaction <---------------------------
// function to issue a book to a student, with checks for borrowing limits and book availability
bool LibrarySystem::issueBook(const string &isbn, const string &sid)
{
    // permission check HERE
    vector<transaction> txs = TransactionManager.getAllTransactions();
    // Check how many books the student has already borrowed today
    int todayBorrowCount = 0;

    QString today = getDate();

    for (const auto &tx : txs)
    {
        if (tx.getStudentId() == sid && QString::fromStdString(tx.getIssueDate()) == today && tx.getStatus() == "active")
        {
            todayBorrowCount++;
        }
    }

    // limit = 2 books per day
    if (todayBorrowCount >= 2)
    {
        qDebug() << "today's borrow count exeded";
        return false;
    }
    int borrowlimitdays;
    Book *b = BooksManager.findByIsbn(isbn); // association with book manager to get book details
    if (!b || b->getAvailableCopies() == 0)
        return false;
    b->issueOneCopy();
    Person *p = authManager.findById(sid); // association with auth manager to get student details
    if (!p)
        return false;
    auto *s = dynamic_cast<Student *>(p);
    string tier = s->getMembershipTier();
    if (tier == "Silver")
        borrowlimitdays = 14;
    if (tier == "Gold")
        borrowlimitdays = 21;
    if (tier == "Platinum")
        borrowlimitdays = 30;
    string username = p->getName();
    string txid = generateId("TX", Database::getMaxIdNumber("transactions", "txid", "TX")); // generate unique transaction ID
    bool dbresponse = Database::addTransaction(QString::fromStdString(txid), QString::fromStdString(sid), QString::fromStdString(isbn), getDate(borrowlimitdays), "", QString::fromStdString(b->getTitle()), QString::fromStdString("active"), 0);
    int total = b->getTotalCopies();
    int available = b->getAvailableCopies();
    ++activeTransations;
    qDebug()<<activeTransations;
    if(isbn.empty() && total && available){qDebug()<<"book data fetching failed"; return false;}
    bool bookupdate = Database::updateBook(QString::fromStdString(isbn),total, available);
    syncLibraryStats();

    return(dbresponse && bookupdate && TransactionManager.issueBook(txid,sid,username,isbn,getDate().toStdString(),getDate(borrowlimitdays).toStdString(),b->getTitle()));
}
// function to process the return of a book, calculate fines based on due date and membership tier, and update the transaction and book records accordingly
bool LibrarySystem::returnBook(const string &txnID)
{
    if (!currentUser || currentUser->getRole() != ROLE_LIBRARIAN)
        return false;

    transaction *t = TransactionManager.findTransactionById(txnID); 
    if (!t || t->isReturned())
        return false;

    string returnDate = getDate().toStdString();

    Person *p = authManager.findById(t->getStudentId());
    auto *s = dynamic_cast<Student *>(p);
    if (!s)
        return false;

    string tier = s->getMembershipTier();
    // Calculate fine using the FineCalculator utility class w.r.t due date, return date, and membership tier
    double fine = FineCalc.calculateFinalFine(t->getDueDate(), returnDate, tier);
    if (fine > 0)
    {
        s->payFine(fine);

        // library receives money
        libraryWallet.addAmount(fine);
    }
    t->markReturned(returnDate, fine);

    Book *b = BooksManager.findByIsbn(t->getIsbn());
    if (!b)
        return false;
    b->returnOneCopy();
    --activeTransations;
    syncLibraryStats();
    bool bookupdate = Database::updateBook(QString::fromStdString(t->getIsbn()), b->getTotalCopies(), b->getAvailableCopies());
    return bookupdate && Database::updateTransaction(
                             QString::fromStdString(t->getTransactionId()),
                             "returned", fine, QString::fromStdString(returnDate));
}

// -------------------> Book Manager <---------------------------
// add a new book to the library system, with permission checks for librarian role and database integration to persist the new book record
bool LibrarySystem::addbook(const string &isbn, const string &title, const string &author, const string &category, const string &section, const string &publisher, const string &edition, const string &language, int publicationYear, int pages, int totalCopies)
{
    // permission check 
    if (!currentUser || currentUser->getRole() != ROLE_LIBRARIAN)
        return false;
    Book book(isbn, title, author, category, section, publisher, edition, language, totalCopies, publicationYear, pages, totalCopies);
    BooksManager.addBook(book);
    syncLibraryStats();
    return Database::addBook(QString::fromStdString(isbn),QString::fromStdString(title),QString::fromStdString(author),pages,QString::fromStdString(category),QString::fromStdString(section),QString::fromStdString(publisher),QString::fromStdString(edition),QString::fromStdString(language),publicationYear,totalCopies,totalCopies);
}
// update the total copies of a book in the library system, with permission checks for librarian role and database integration to persist the updated book record
bool LibrarySystem::updateBook(const std::string &isbn, int totalCopies)
{
    if (!currentUser || currentUser->getRole() != ROLE_LIBRARIAN)
        return false;
    int avaliablecopies;
    bool res = BooksManager.updateBook(isbn, totalCopies);
    if (res)
        avaliablecopies = BooksManager.findByIsbn(isbn)->getAvailableCopies();
    return res && Database::updateBook(QString::fromStdString(isbn), totalCopies, avaliablecopies);
}
// remove a book from the library system, with permission checks for librarian role and database integration to delete the book record
bool LibrarySystem::removeBook(const string &isbn)
{
    if (!currentUser || currentUser->getRole() != ROLE_LIBRARIAN)
        return false;
    BooksManager.removeBook(isbn);
    Database::updateLibrary( QString::fromStdString("LIB-NED"),totalBooks,activeTransations,pendingReviews,libraryWallet.getBalance());

    return Database::deleteBook(QString::fromStdString(isbn));
}

// -------------------> Review <---------------------------
// approve a pending review, with permission checks for librarian role and database integration to update the review status
bool LibrarySystem::approveReview(const string &reviewID)
{

    qDebug() << "Approve called. User:"
             << (currentUser ? QString::fromStdString(currentUser->getRole()) : "NULL");

    if (!currentUser)
        return false;

    string role = currentUser->getRole();

    if (role != ROLE_LIBRARIAN && role != "LIBRARIAN" && role != "librarian")
        return false;

    ReviewManager.approveReview(reviewID);
    --pendingReviews;
    syncLibraryStats();

    return Database::updateReview(
        QString::fromStdString(reviewID),
        std::nullopt,
        std::nullopt,
        QString::fromStdString("approved"));
}
// delete a review from the library system, with permission checks for librarian role and database integration to remove the review record
bool LibrarySystem::deleteReview(const string &reviewID)
{
    if (!currentUser || currentUser->getRole() != ROLE_LIBRARIAN)
        return false;
    ReviewManager.deleteReview(reviewID);
    --pendingReviews;
    return Database::deleteReview(QString::fromStdString(reviewID));
}
// submit a new review for a book, with permission checks for student role and database integration to persist the new review record
bool LibrarySystem::submitReview(const string &studentID, const string &isbn, int rating, const string &comment)
{
    if (!currentUser)
    {
        return false;
    }
    string role = currentUser->getRole();
    if (role != ROLE_STUDENT )
        return false;
    // qDebug()<<"id "<<Database::getMaxIdNumber("reviews", "reviewid", "RV")
    string rid = generateId("RV",Database::getMaxIdNumber("reviews", "reviewid", "RV"));
    string sid = currentUser->getUserID();
    string uname = currentUser->getName();
    Book *b = BooksManager.findByIsbn(isbn);
    string bname = (b ? b->getTitle() : "");
    Review r(rid, sid, uname, isbn, bname, rating, comment,"pending", getDate().toStdString());

    if(ReviewManager.addReview(r)){
        ++pendingReviews;
        syncLibraryStats();
        return  Database::addReview(QString::fromStdString(rid),QString::fromStdString(sid), QString::fromStdString(uname), QString::fromStdString(isbn), QString::fromStdString(bname), rating, QString::fromStdString(comment),QString::fromStdString("pending"));}
    else{

        return false;
    }
}

// -------------------> User <---------------------------
// register a new student in the library system, with permission checks for librarian role and database integration to persist the new user record
RegistrationResult LibrarySystem::registerStudent(const string &name, const string &email, const string &pwd, const string &status, const string &membership, const string &role, double balance)
{

    RegistrationResult result;
    result.success = false;
    result.userId = "";
    result.message = "";

    // 1. Generate the ID
    string id = generateId("SU", Database::getMaxIdNumber("users", "id", "SU"));

    // 2. Create the Student object (Heap allocation)
    Student *student = new Student(id, name, email, pwd, status, membership, balance);

    // 3. Attempt to save to Database
    result.success = Database::addUser(
        QString::fromStdString(id),
        QString::fromStdString(name),
        QString::fromStdString(email),
        QString::fromStdString(pwd),
        QString::fromStdString(membership),
        QString::fromStdString(role),
        QString::fromStdString(status),
        balance);

    // 4. Handle logic based on the boolean result
    if (result.success)
    {
        // Success: Track in memory and provide ID to the result
        authManager.registerPerson(student);
        result.userId = id;
        result.message = "Student registered successfully.";
    }
    else
    {
        // Failure: Cleanup the memory to prevent leaks
        delete student;
        result.message = "Database insertion failed.";
    }

    return result;
}
// register a new librarian in the library system, with permission checks for librarian role and database integration to persist the new librarian record
RegistrationResult LibrarySystem::registerLibrarian(const string &name, const string &email, const string &pwd, const string &role)
{
    RegistrationResult result = {false, "", ""};

    string id = generateId("LIB", Database::getMaxIdNumber("users", "id", "LIB"));
    Librarian *librarian = new Librarian(id, name, email, pwd, "none");

    result.success = Database::addUser(
        QString::fromStdString(id),
        QString::fromStdString(name),
        QString::fromStdString(email),
        QString::fromStdString(pwd),
        "",
        QString::fromStdString(role),
        "", 0);

    if (result.success)
    {
        authManager.registerPerson(librarian);
        result.userId = id;
        result.message = "Librarian registered successfully.";
    }
    else
    {
        delete librarian;
        result.message = "Failed to save Librarian to database.";
    }

    return result;
}
// main registration function that routes to specific registration logic based on the role, with comprehensive validation and error handling
RegistrationResult LibrarySystem::registerUser(const string &name, const string &email, const string &pwd, const string &status, const string &membership, const string &role, double balance)
{
    // 1. Authorization Check
    // Ensure only an authorized librarian can perform registration
    if (!currentUser || currentUser->getRole() != ROLE_LIBRARIAN)
    {
        return {false, "", "Unauthorized: Only librarians can register new users."};
    }

    // 2. Basic Validation
    if (name.empty() || email.empty() || pwd.empty() || role.empty())
    {
        return {false, "", "Registration failed: Missing required fields."};
    }

    // 3. Routing based on Role
    if (role == ROLE_STUDENT)
    {
        return registerStudent(name, email, pwd, status, membership, role, balance);
    }
    else if (role == ROLE_LIBRARIAN)
    {
        return registerLibrarian(name, email, pwd, role);
    }
    else
    {
        // Handle unexpected roles
        return {false, "", "Registration failed: Unknown role '" + role + "'."};
    }
}
// remove a user from the library system, with permission checks for librarian role and database integration to delete the user record
bool LibrarySystem::removeUser(const string &id)
{
    if (!currentUser || currentUser->getRole() != ROLE_LIBRARIAN)
        return false;
    return authManager.removeUser(id) && Database::deleteUser(QString::fromStdString(id));
};
// update user details in the library system, with routing to specific update logic based on the role and database integration to persist the updated user record
bool LibrarySystem::updateStudent(const string &id,const string &name,const string &email,const string &pwd,const string &status,const string &membership,const string &role)
{
    Person *p = authManager.findById(id);
    if (!p)
    {
        return false;
    }

    // Ensure it's a student
    Student *s = dynamic_cast<Student *>(p);
    if (!s)
    {
        return false;
    }

    string currentMembership = s->getMembershipTier();
    string finalMembership = currentMembership;

    // Handle membership upgrade if needed
    if (membership != currentMembership)
    {

        Membership* m = createMembership(membership, id);
        if (!m) return false;
        double fee = m->getRenewalFee();
        delete m;
        // block if insufficient funds
        if (s->getWalletBalance() < fee)
            return false;
        // deduct from student wallet
        s->paymembershipfee(fee);
        // add to library wallet
        libraryWallet.addAmount(fee);
        // actually change membership tier in-memory
        authManager.upgrademembership(membership, id);
        finalMembership = membership;
        Database::updateUser(QString::fromStdString(id),s->getWalletBalance());
    }
    // Update other details
    authManager.updateUser(id, name, email, pwd, status,s->getWalletBalance());

    syncLibraryStats();

    return  Database::updateUser(
        QString::fromStdString(id),
        QString::fromStdString(name),
        QString::fromStdString(email),
        QString::fromStdString(pwd),
        QString::fromStdString(finalMembership),
        QString::fromStdString(role),
        QString::fromStdString(status));
}
// update librarian details in the library system, with database integration to persist the updated librarian record
bool LibrarySystem::updateLibrarian(const string &id, const string &name, const string &email, const string &pwd, const string &role)
{
    authManager.updateUser(id, name, email, pwd);
    return Database::updateUser(QString::fromStdString(id), QString::fromStdString(name), QString::fromStdString(email), QString::fromStdString(pwd), QString::fromStdString("none"), QString::fromStdString(role));
}
// main update function that routes to specific update logic based on the role, with comprehensive validation and error handling
bool LibrarySystem::updateUser(const string &id, const string &name, const string &email, const string &pwd, const string &membership, const string &role, const string &status)
{

    // Basic validation
    if (id.empty() || name.empty() || email.empty() || role.empty())
    {
        qDebug() << "Invalid input for user registration";
        return false;
    }
    string password = pwd;
    qDebug() << password;
    if (password.empty())
    {
        Person *p = authManager.findById(id);
        if (p)
        {
            password = p->getPassword();
        }
        else
        {
            qDebug() << "password fetching failed";
        }
    }

    // Decide based on role
    if (role == ROLE_STUDENT)
    {
        return updateStudent(id, name, email, password, status, membership, role);
    }
    else if (role == ROLE_LIBRARIAN)
    {
        return updateLibrarian(id, name, email, password, role);
    }
    else
    {
        qDebug() << "Unknown user:" << QString::fromStdString(role);
        return false;
    }
}
// ---------------> wallet <---------------------------
// add balance to a student's wallet, with database integration to persist the updated balance
bool LibrarySystem::addBalance(const string &sid, double amount)
{
    if (authManager.addBalance(sid, amount))
        return Database::updateUser(QString::fromStdString(sid), authManager.getStudentBalance(sid));
    return false;
}

// -------------------> membership <---------------------------
// upgrade a student's membership tier, with checks for valid student ID, creation of temporary membership object to calculate fees, wallet balance verification, deduction of fees from student wallet, addition of fees to library wallet, and database integration to persist the updated membership tier and wallet balance
bool LibrarySystem::upgradeStudentMembership(const string &studentId, const string &newTier)
{
    // Find user
    Person *p = authManager.findById(studentId);

    if (!p)
        return false;

    // Ensure student
    Student *s = dynamic_cast<Student *>(p);

    if (!s)
        return false;

    // Create temporary membership object
    Membership *m = createMembership(newTier, studentId);

    if (!m)
        return false;

    // Get fee
    double fee = m->getRenewalFee();

    // Optional: prevent insufficient balance
    if (s->getWalletBalance() < fee)
    {
        delete m;
        return false;
    }

    // Deduct from student wallet
    qDebug() <<"fee "<< fee;
    s->paymembershipfee(fee);
    qDebug() << s->getstudentwallet()->getBalance();

    // Add money to library wallet
    libraryWallet.addAmount(fee);
    qDebug() << libraryWallet.getBalance();
    // Upgrade membership
    authManager.upgrademembership(newTier, studentId);
    syncLibraryStats();
    // Cleanup
    delete m;

    // Update DB
    return Database::updateUser(
               QString::fromStdString(studentId),
               QString::fromStdString(p->getName()),
               QString::fromStdString(p->getEmail()),
               QString::fromStdString(p->getPassword()),
               QString::fromStdString(newTier),
               QString::fromStdString(p->getRole()),
               QString::fromStdString(s->getStatus())) &&
           Database::updateUser(
               QString::fromStdString(studentId), s->getWalletBalance());
}
// get the current membership details of the logged-in student, including tier, borrowing limit, fine discount, and expiry date, with database integration to fetch the latest expiry date
QVariantMap LibrarySystem::getCurrentMembershipDetails()
{
    QVariantMap map;

    if (!currentUser)
        return map;

    Student *s = dynamic_cast<Student *>(currentUser);
    if (!s)
        return map;

    string tier = s->getMembershipTier();

    Membership *m = createMembership(tier, s->getUserID());

    map["tier"] = QString::fromStdString(tier);
    map["borrowLimit"] = m->getBorrowedLimit();
    map["fineDiscount"] = QString::number(m->getFineDiscount() * 100) + "%";

    // expiry from DB 
    QVariantList users = Database::getUsers();
    for (auto u : users)
    {
        QVariantMap um = u.toMap();
        if (um["id"].toString().toStdString() == s->getUserID())
        {
            map["expiry"] = um["expiry_date"].toString();
            break;
        }
    }

    map["active"] = true;

    delete m;
    return map;
}
// renew a student's membership, with checks for valid student ID, creation of temporary membership object to calculate renewal fees, wallet balance verification, deduction of fees from student wallet, addition of fees to library wallet, and database integration to persist the renewed membership details and wallet balance
bool LibrarySystem::renewMembership(const string &studentId)
{
    Person *p = authManager.findById(studentId);

    if (!p)
        return false;

    Student *s = dynamic_cast<Student *>(p);

    if (!s)
        return false;

    string tier = s->getMembershipTier();

    return Database::updateUser(
        QString::fromStdString(studentId),
        QString::fromStdString(p->getName()),
        QString::fromStdString(p->getEmail()),
        QString::fromStdString(p->getPassword()),
        QString::fromStdString(tier),
        QString::fromStdString(p->getRole()),
        QString::fromStdString(s->getStatus()));
}
// -------------------> Accessors for Dashboard & Display <---------------------------
vector<Book> LibrarySystem::getAllBooks() const
{
    return BooksManager.getAllBooks();
}

vector<Person *> LibrarySystem::getAllUsers() const
{
    return authManager.getAllUsers(); 
}

vector<transaction> LibrarySystem::getAllTransactions() const
{
    return TransactionManager.getAllTransactions();
}

vector<Review> LibrarySystem::getAllReviews() const
{
    return ReviewManager.getAllReviews(); 
}

// -------------------> Dashboard <---------------------------

QVariantMap LibrarySystem::getStudentDashboardData(const std::string &studentId)
{
    QVariantMap map;

    int borrowedBooks = 0;
    int dueBooks = 0;
    int totalFine = 0;

    QString membership = "N/A";

    // -------- MEMBERSHIP --------
    Person *p = authManager.findById(studentId);

    Student *s = dynamic_cast<Student *>(p);

    qDebug() << "Dashboard studentId:"
             << QString::fromStdString(studentId);

    qDebug() << "Person pointer:" << p;

    if (s)
    {
        qDebug() << "Membership:"
                 << QString::fromStdString(s->getMembershipTier());
    }
    else
    {
        qDebug() << "Dynamic cast FAILED";
    }

    if (s)
    {
        membership = QString::fromStdString(
            s->getMembershipTier());
    }

    // -------- TRANSACTIONS --------
    std::vector<transaction> txs =
        TransactionManager.getTransactionsByStudent(studentId);

    borrowedBooks = txs.size();

    for (const auto &tx : txs)
    {
        QString status =
            QString::fromStdString(tx.getStatus()).toUpper();

        if (status == "ACTIVE" || status == "PENDING")
            dueBooks++;

        totalFine += tx.getFine();
    }

    map["borrowedBooks"] = borrowedBooks;
    map["dueBooks"] = dueBooks;
    map["balance"] = s->getWalletBalance();
    map["membership"] = membership;

    return map;
}
// get the borrowing history of a student, including book names, due dates, and status of each transaction, with database integration to fetch the latest transaction records(for recent activity)
QVariantList LibrarySystem::getStudentBorrowHistory(const std::string &studentId)
{
    QVariantList list;

    std::vector<transaction> txs =
        TransactionManager.getTransactionsByStudent(studentId);

    for (const auto &tx : txs)
    {
        QVariantMap map;

        map["bookName"] =
            QString::fromStdString(tx.getbookName());

        map["dueDate"] =
            QString::fromStdString(tx.getDueDate());

        map["status"] =
            QString::fromStdString(tx.getStatus()).toUpper();

        list.append(map);
    }

    return list;
}
// display all data in the system for debugging purposes, including books, users, transactions, and reviews, with clear sectioning and formatting for readability
void LibrarySystem::displayAllData() const
{
    std::cout << "================ LIBRARY SYSTEM REPORT ================\n\n";

    // 1. Print Books
    std::cout << "--- BOOKS ---\n";
    for (const auto &book : getAllBooks())
    {
        std::cout << book << "\n";
    }

    // 2. Print Users (Note: these are pointers!)
    std::cout << "\n--- USERS ---\n";
    for (const auto *userPtr : getAllUsers())
    {
        if (userPtr)
        {
            std::cout << *userPtr << "\n"; 
        }
    }

    // 3. Print Transactions
    std::cout << "\n--- TRANSACTIONS ---\n";
    for (const auto &t : getAllTransactions())
    {
        t.display();
    }

    // 4. Print Reviews
    std::cout << "\n--- REVIEWS ---\n";
    for (const auto &r : getAllReviews())
    {
        r.display();
    }

    std::cout << "\n=======================================================\n";
}
