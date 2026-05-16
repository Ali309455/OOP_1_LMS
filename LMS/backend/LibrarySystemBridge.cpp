#include "LibrarySystemBridge.h"
#include <QVariantMap>

LibrarySystemBridge::LibrarySystemBridge(LibrarySystem* system, QObject *parent)
    : QObject(parent), m_system(system)
{}

QVariantMap LibrarySystemBridge::login(const QString& email, const QString& password)
{
    return m_system->login(email.toStdString(), password.toStdString());
}
void LibrarySystemBridge::logout()
{
    m_system->logout();
}
// -------------------- User Management --------------------
RegistrationResult LibrarySystemBridge::registerStudent(const QString &name, const QString &email, const QString &pwd, const QString &status, const QString &membership, const QString &role)
{
    return m_system->registerStudent(name.toStdString(), email.toStdString(), pwd.toStdString(), status.toStdString(), membership.toStdString(), role.toStdString(),0);
}
RegistrationResult LibrarySystemBridge::registerLibrarian(const QString &name, const QString &email, const QString &pwd, const QString &role)
{
    return m_system->registerLibrarian(name.toStdString(), email.toStdString(), pwd.toStdString(), role.toStdString());
}
QVariantMap LibrarySystemBridge::registerUser(const QString &name, const QString &email, const QString &pwd, const QString &status, const QString &membership, const QString &role, const double balance)
{
    auto result = m_system->registerUser(name.toStdString(), email.toStdString(),
                                        pwd.toStdString(), status.toStdString(),
                                        membership.toStdString(), role.toStdString(), balance);

    QVariantMap map;
    map["success"] = result.success;
    map["userId"] = QString::fromStdString(result.userId);
    map["message"] = QString::fromStdString(result.message);

    return map;
}

bool LibrarySystemBridge::removeUser(const QString &id){
    return m_system->removeUser(id.toStdString());
}

bool LibrarySystemBridge::updateUser(const QString& id,const QString& name, const QString& email, const QString& pwd, const QString& status, const QString& membership, const QString& role){
    // if(m_system->upgradeStudentMembership(s))
    return m_system->updateUser(
        id.toStdString(),
        name.toStdString(),
        email.toStdString(),
        pwd.toStdString(),
        membership.toStdString(),
        role.toStdString(),
        status.toStdString());
    
}

// -------------------- Catalog Management --------------------
bool LibrarySystemBridge::addBook(const QString &isbn, const QString &title, const QString &author, const QString &category, const QString &section, const QString &publisher, const QString &edition, const QString &language, int publicationYear, int pages, int totalCopies)
{  // const string& isbn,const string&  title,const string&  author, const string& category,const string&  section, const string& publisher,const string&  edition, const string& language, int publicationYear, int pages,int totalCopies
    return m_system->addBook(isbn.toStdString(), title.toStdString(), author.toStdString(), category.toStdString(), section.toStdString(), publisher.toStdString(), edition.toStdString(), language.toStdString(), publicationYear, pages, totalCopies);
}

bool LibrarySystemBridge::removeBook(const QString &isbn)
{
    return m_system->removeBook(isbn.toStdString());
}

bool LibrarySystemBridge::updateBook(const QString& isbn,int totalCopies){
    return m_system->updateBook(isbn.toStdString(),  totalCopies);
}

// -------------------- Transaction Management -------------------------
bool LibrarySystemBridge::issueBook(const QString &isbn, const QString &studentID)
{
    return m_system->issueBook(isbn.toStdString(), studentID.toStdString());
}

bool LibrarySystemBridge::returnBook(const QString &transactionId)
{
    return m_system->returnBook(transactionId.toStdString());
}

// -------------------- Review Management -------------------------
bool LibrarySystemBridge::submitReview(const QString &isbn, int rating, const QString &comment)
{
    // Uses current logged-in student's ID from backend
    return m_system->submitReview("", isbn.toStdString(), rating, comment.toStdString());
}

bool LibrarySystemBridge::approveReview(const QString &reviewId)
{
    qDebug()<< "frontend approve clicked: "<<reviewId;
    return m_system->approveReview(reviewId.toStdString());
}

bool LibrarySystemBridge::deleteReview(const QString &reviewId)
{
    return m_system->deleteReview(reviewId.toStdString());
}

bool LibrarySystemBridge::addBalance(const QString& sid, double amount){
    return m_system->addBalance(sid.toStdString(),amount);
}

// ----------> Stats card data <---------------
double LibrarySystemBridge::getLibraryBalance() const {
    return m_system->getLibraryBalance();
}
int LibrarySystemBridge::getTotalBooks() const{
    return m_system->getTotalBooks();
}
int LibrarySystemBridge::getActiveTransactions() const{
    return m_system->getActiveTransactions();
}
int LibrarySystemBridge::getPendingReviews() const{
    return m_system->getPendingReviews();
}

// ----------> Generate Pdf <---------------
bool LibrarySystemBridge::exportDatabaseReportPdf(const QString &outputPdfPath, QString *outError)
{
    return LibrarySystem::exportDatabaseReportPdf(outputPdfPath);
}

// ------------------ Data for QML ListModels ------------------

// Each QVariantMap returned here models a "row" in a QML ListView

QVariantList LibrarySystemBridge::getBooks()
{
    QVariantList list;
    for (const auto &book : m_system->getAllBooks())
    {
        QVariantMap map;
        map["isbn"] = QString::fromStdString(book.getIsbn());
        map["title"] = QString::fromStdString(book.getTitle());
        map["author"] = QString::fromStdString(book.getAuthor());
        map["genre"] = QString::fromStdString(book.getCategory());
        map["section"] = QString::fromStdString(book.getSection());
        map["totalCopies"] = book.getTotalCopies();
        map["publisher"] = QString::fromStdString(book.getPublisher());
        map["edition"] = QString::fromStdString(book.getEdition());
        map["year"] = (book.getPublicationYear());
        map["pages"] = (book.getPages());
        map["language"] = QString::fromStdString(book.getLanguage());
        map["availableCopies"] = book.getAvailableCopies();
        list.append(map);
    }
    return list;
}

QVariantList LibrarySystemBridge::getUsers()
{
    QVariantList list;
    for (const auto *person : m_system->getAllUsers())
    {
        if (!person)
            continue;

        QVariantMap map;
        // Common Person fields
        map["userId"] = QString::fromStdString(person->getUserID());
        map["name"] = QString::fromStdString(person->getName());
        map["email"] = QString::fromStdString(person->getEmail());
        map["role"] = QString::fromStdString(person->getRole());

        // Try to cast to Student
        const Student *student = dynamic_cast<const Student *>(person);

        if (student)
        {
            // Student-specific fields
            map["status"] = QString::fromStdString(student->getStatus());

            // Assuming membership has a method like getType() or getName()
                map["membership"] = QString::fromStdString(student->getMembershipTier());
                map["balance"] = student->getWalletBalance();

        } else {
            // Fallback for non-students (Librarians, etc.)
            map["status"] = "N/A";
            map["membership"] = "N/A";
        }

        list.append(map);
    }
    return list;
}

QVariantList LibrarySystemBridge::getTransactions()
{
    QVariantList list;
    for (const auto &tx : m_system->getAllTransactions())
    {
        QVariantMap map;
        map["txnId"] = QString::fromStdString(tx.getTransactionId());
        map["sId"] = QString::fromStdString(tx.getStudentId());
        map["student"] = QString::fromStdString(tx.getUsername());
        map["isbn"] = QString::fromStdString(tx.getIsbn());
        map["issueDate"] = QString::fromStdString(tx.getIssueDate());
        map["dueDate"] = QString::fromStdString(tx.getDueDate());
        map["returnDate"] = tx.getReturnDate().empty()
                                ? "--"
                                : QString::fromStdString(tx.getReturnDate());
        map["bookName"] = QString::fromStdString(tx.getBookName());
        map["status"] = QString::fromStdString(tx.getStatus());
        map["fine"] = (tx.getFine() == 0.0)
                          ? "--"
                          : "$" + QString::number(tx.getFine());
        list.append(map);
    }
    return list;
}

QVariantList LibrarySystemBridge::getReviews()
{
    QVariantList list;
    for (const auto &rev : m_system->getAllReviews())
    {
        QVariantMap map;
        map["reviewId"] = QString::fromStdString(rev.getReviewId());
        map["studentId"] = QString::fromStdString(rev.getStudentId());
        map["author"] = QString::fromStdString(rev.getUsername());
        map["isbn"] = QString::fromStdString(rev.getIsbn());
        map["book"] = QString::fromStdString(rev.getBookName());
        map["text"] = QString::fromStdString(rev.getComment());
        map["status"] = QString::fromStdString(rev.getStatus());
        map["rating"] = rev.getRating();
        map["date"] = QString::fromStdString(rev.getReviewDate());
        qDebug() << "here";
        list.append(map);
    }
    return list;
}

// -------------------- Membership --------------------

QVariantMap LibrarySystemBridge::getMembership()
{
    return m_system->getCurrentMembershipDetails();
}

bool LibrarySystemBridge::upgradeMembership(const QString &userId, const QString &tier)
{
    return m_system->upgradeStudentMembership(
        userId.toStdString(),
        tier.toStdString());
}

bool LibrarySystemBridge::renewMembership(const QString &userId)
{
    return m_system->renewMembership(
        userId.toStdString()
        );
}

// ---------------- Dashboard ----------------

QVariantMap LibrarySystemBridge::getStudentDashboard(const QString &studentId)
{
    return m_system->getStudentDashboardData(
        studentId.toStdString()
        );
}

QVariantList LibrarySystemBridge::getStudentBorrowHistory(const QString &studentId)
{
    return m_system->getStudentBorrowHistory(
        studentId.toStdString()
        );
}
