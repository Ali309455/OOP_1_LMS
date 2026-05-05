#include "LibrarySystemBridge.h"
#include <QVariantMap>

LibrarySystemBridge::LibrarySystemBridge(LibrarySystem* system, QObject *parent)
    : QObject(parent), m_system(*system)
{}

bool LibrarySystemBridge::login(const QString &email, const QString &password)
{
    return m_system.login(email.toStdString(), password.toStdString());
}
void LibrarySystemBridge::logout()
{
    m_system.logout();
}

bool LibrarySystemBridge::registerStudent(const QString &name, const QString &email, const QString &pwd,const QString &status ,const QString &membership, const QString &role)
{
    return m_system.registerStudent(name.toStdString(), email.toStdString(), pwd.toStdString(), status.toStdString(), membership.toStdString(), role.toStdString());
}
bool LibrarySystemBridge::registerLibrarian(const QString &name, const QString &email, const QString &pwd, const QString &role)
{
    return m_system.registerLibrarian(name.toStdString(), email.toStdString(), pwd.toStdString(), role.toStdString());
}
bool LibrarySystemBridge::removeUser(const QString &id)
{
    return m_system.removeUser(id.toStdString());
}

bool LibrarySystemBridge::addBook(const QString &isbn, const QString &title, const QString &author, const QString &category, const QString &section, const QString &publisher, const QString &edition, const QString &language, int publicationYear, int pages, int totalCopies)
{
    return m_system.addbook(isbn.toStdString(), title.toStdString(), author.toStdString(), category.toStdString(), section.toStdString(), publisher.toStdString(), edition.toStdString(), language.toStdString(), publicationYear, pages, totalCopies);
}

bool LibrarySystemBridge::removeBook(const QString &isbn)
{
    return m_system.removeBook(isbn.toStdString());
}

bool LibrarySystemBridge::issueBook(const QString &isbn, const QString &studentID)
{
    return m_system.issueBook(isbn.toStdString(), studentID.toStdString());
}

bool LibrarySystemBridge::returnBook(const QString &transactionId)
{
    return m_system.returnBook(transactionId.toStdString());
}

bool LibrarySystemBridge::submitReview(const QString &isbn, int rating, const QString &comment)
{
    // Uses current logged-in student's ID from backend
    return m_system.submitReview("", isbn.toStdString(), rating, comment.toStdString());
}

bool LibrarySystemBridge::approveReview(const QString &reviewId)
{
    qDebug()<< "frontend approve clicked: "<<reviewId;
    return m_system.approveReview(reviewId.toStdString());
}

bool LibrarySystemBridge::deleteReview(const QString &reviewId)
{
    return m_system.deleteReview(reviewId.toStdString());
}
// ------------------ Data for QML ListModels ------------------

// Each QVariantMap returned here models a "row" in a QML ListView

QVariantList LibrarySystemBridge::getBooks()
{
    QVariantList list;
    for (const auto &book : m_system.getAllBooks())
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
    for (const auto *person : m_system.getAllUsers())
    {
        QVariantMap map;
        map["userId"] = QString::fromStdString(person->getUserID());
        map["name"] = QString::fromStdString(person->getName());
        map["email"] = QString::fromStdString(person->getEmail());
        map["role"] = QString::fromStdString(person->getRole());
        list.append(map);
    }
    return list;
}

QVariantList LibrarySystemBridge::getTransactions()
{
    QVariantList list;
    for (const auto &tx : m_system.getAllTransactions())
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
    for (const auto &rev : m_system.getAllReviews())
    {
        QVariantMap map;
        map["reviewId"] = QString::fromStdString(rev.getReviewId());
        map["studentId"] = QString::fromStdString(rev.getStudentId());
        map["author"] = QString::fromStdString(rev.getUsername());
        map["isbn"] = QString::fromStdString(rev.getIsbn());
        map["book"] = QString::fromStdString(rev.getBookname());
        map["text"] = QString::fromStdString(rev.getComment());
        map["status"] = QString::fromStdString(rev.getStatus());
        map["rating"] = rev.getRating();
        map["date"] = QString::fromStdString(rev.getReviewDate());
        qDebug()<<"here";
        list.append(map);
    }
    return list;
}
