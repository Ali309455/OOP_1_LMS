#include "TransactionReview.h"
#include <iostream>

using namespace std;

// ========= FineCalculator Implementation =========
int FineCalculator::daysOverdue(const string& dueDate, const string& returnDate) {
    if (dueDate.length() != 10 || returnDate.length() != 10) return 0;

    int dueYear = stoi(dueDate.substr(0, 4));
    int dueMonth = stoi(dueDate.substr(5, 2));
    int dueDay = stoi(dueDate.substr(8, 2));

    int retYear = stoi(returnDate.substr(0, 4));
    int retMonth = stoi(returnDate.substr(5, 2));
    int retDay = stoi(returnDate.substr(8, 2));

    int dueTotal = dueYear * 365 + dueMonth * 30 + dueDay;
    int retTotal = retYear * 365 + retMonth * 30 + retDay;

    return (retTotal <= dueTotal) ? 0 : (retTotal - dueTotal);
}

double FineCalculator::calculateBaseFine(const string& dueDate, const string& returnDate, double ratePerDay) {
    return daysOverdue(dueDate, returnDate) * ratePerDay;
}

double FineCalculator::applyMembershipDiscount(double fine, const string& membershipType) {
    if (membershipType == "Gold" || membershipType == "gold") return fine * 0.90;
    if (membershipType == "Platinum" || membershipType == "platinum") return fine * 0.80;
    return fine;
}

double FineCalculator::calculateFinalFine(const string& dueDate, const string& returnDate, const string& membershipType, double ratePerDay) {
    double baseFine = calculateBaseFine(dueDate, returnDate, ratePerDay);
    return applyMembershipDiscount(baseFine, membershipType);
}

// ========= Transaction Implementation =========
Transaction::Transaction() : transactionId(""), studentId(""), isbn(""), issueDate(""), dueDate(""), returnDate(""), bookName(""), status("active"), fine(0.0) {}

Transaction::Transaction(string transactionId, string studentId, string username, string isbn, string issueDate, string dueDate, string returnDate, string bookName, string status, double fine) {
    this->transactionId = transactionId;
    this->studentId = studentId;
    this->isbn = isbn;
    this->username = username;
    this->issueDate = issueDate;
    this->dueDate = dueDate;
    this->returnDate = returnDate;
    this->status = status;
    this->bookName = bookName;
    this->fine = fine;
}

void Transaction::setTransactionId(string transactionId) { this->transactionId = transactionId; }
void Transaction::setStudentId(string studentId) { this->studentId = studentId; }
void Transaction::setIsbn(string isbn) { this->isbn = isbn; }
void Transaction::setUsername(string username) { this->username = username; }
void Transaction::setIssueDate(string issueDate) { this->issueDate = issueDate; }
void Transaction::setDueDate(string dueDate) { this->dueDate = dueDate; }
void Transaction::setReturnDate(string returnDate) { this->returnDate = returnDate; }
void Transaction::setStatus(string status) { this->status = status; }
void Transaction::setFine(double fine) { this->fine = fine; }

string Transaction::getTransactionId() const { return transactionId; }
string Transaction::getStudentId() const { return studentId; }
string Transaction::getIsbn() const { return isbn; }
string Transaction::getUsername() const { return username; }
string Transaction::getIssueDate() const { return issueDate; }
string Transaction::getDueDate() const { return dueDate; }
string Transaction::getReturnDate() const { return returnDate; }
string Transaction::getStatus() const { return status; }
string Transaction::getBookName() const { return bookName; }
double Transaction::getFine() const { return fine; }

bool Transaction::isActive() const { return status == "active"; }
bool Transaction::isReturned() const { return status == "returned"; }
bool Transaction::isOverdue() const { return status == "overdue"; }

void Transaction::markReturned(string returnedOn, double calculatedFine) {
    returnDate = returnedOn;
    fine = calculatedFine;
    status = "returned";
}

void Transaction::updateOverdueStatus(string todayDate) {
    if (!isReturned() && FineCalculator::daysOverdue(dueDate, todayDate) > 0) {
        status = "overdue";
    }
}

void Transaction::display() const {
    cout << "Transaction ID: " << transactionId << "\nStudent ID: " << studentId
         << "\nISBN: " << isbn << "\nIssue Date: " << issueDate << "\nDue Date: " << dueDate
         << "\nReturn Date: " << (returnDate.empty() ? "-" : returnDate)
         << "\nStatus: " << status << "\nFine: " << fine << "\n-----------------------------" << endl;
}

// ========= TransactionLog Implementation =========
int TransactionLog::transactionCount = 0;

void TransactionLog::addTransaction(const Transaction& t) {
    transactions.push_back(t);
    transactionCount++;
}

bool TransactionLog::removeTransaction(string transactionId) {
    for (auto it = transactions.begin(); it != transactions.end(); ++it) {
        if (it->getTransactionId() == transactionId) {
            transactions.erase(it);
            return true;
        }
    }
    return false;
}

Transaction* TransactionLog::findTransactionById(string transactionId) {
    for (auto& t : transactions) {
        if (t.getTransactionId() == transactionId) return &t;
    }
    return nullptr;
}

bool TransactionLog::hasActiveTransaction(string studentId, string isbn) {
    for (const auto& t : transactions) {
        if (t.getStudentId() == studentId && t.getIsbn() == isbn && t.isActive()) return true;
    }
    return false;
}

bool TransactionLog::issueBook(string transactionId, string studentId, string username, string isbn, string issueDate, string dueDate, string bookName) {
    if (hasActiveTransaction(studentId, isbn)) return false;
    transactions.emplace_back(transactionId, studentId, username, isbn, issueDate, dueDate, "", bookName, "active", 0.0);
    transactionCount++;
    return true;
}

bool TransactionLog::returnBook(string transactionId, string returnDate, string membershipType) {
    Transaction* t = findTransactionById(transactionId);
    if (t == nullptr || t->isReturned()) return false;
    double finalFine = FineCalculator::calculateFinalFine(t->getDueDate(), returnDate, membershipType);
    t->markReturned(returnDate, finalFine);
    return true;
}

void TransactionLog::updateAllOverdue(string todayDate) {
    for (auto& t : transactions) t.updateOverdueStatus(todayDate);
}

void TransactionLog::displayAllTransactions() {
    if (transactions.empty()) { cout << "No transactions found." << endl; return; }
    for (const auto& t : transactions) t.display();
}

std::vector<Transaction> TransactionLog::getAllTransactions() const {
    return transactions;
}

std::vector<Transaction> TransactionLog::getTransactionsByStudent(std::string studentId)
{
    std::vector<Transaction> result;

    for (const auto& tx : transactions)
    {
        if (tx.getStudentId() == studentId)
        {
            result.push_back(tx);
        }
    }

    return result;
}

// ========= Review Implementation =========
Review::Review() : reviewId(""), studentId(""), username(""), isbn(""), bookName(""), rating(0), comment(""), status("pending"), reviewDate("") {}

Review::Review(string reviewId, string studentId, string username, string isbn, string bookName, int rating, string comment, string status, string reviewDate) {
    this->reviewId = reviewId;
    this->studentId = studentId;
    this->username = username;
    this->isbn = isbn;
    this->bookName = bookName;
    this->rating = rating;
    this->comment = comment;
    this->status = status;
    this->reviewDate = reviewDate;
}

void Review::approve() { status = "approved"; }
bool Review::isApproved() const { return status == "approved"; }
bool Review::isPending() const { return status == "pending"; }

string Review::getStudentId() const { return studentId; }
string Review::getUsername() const { return username; }
string Review::getIsbn() const { return isbn; }
string Review::getBookName() const { return bookName; }
string Review::getReviewId() const { return reviewId; }
string Review::getReviewDate() const { return reviewDate; }
string Review::getComment() const { return comment; }
string Review::getStatus() const { return status; }
int Review::getRating() const { return rating; }

void Review::display() const {
    cout << "Review ID: " << reviewId << "\nRating: " << rating << "/5\nComment: " << comment
         << "\nStatus: " << status << "\n-----------------------------" << endl;
}

// ========= ReviewLog Implementation =========
int ReviewLog::reviewCount = 0;

bool ReviewLog::addReview(const Review& r) {
    for (const auto& existing : reviews) {
        if (existing.getStudentId() == r.getStudentId() && existing.getIsbn() == r.getIsbn()) return false;
    }
    reviewCount++;
    reviews.push_back(r);
    return true;
}

bool ReviewLog::approveReview(string reviewId) {
    for (auto& r : reviews) {
        if (r.getReviewId() == reviewId) { r.approve(); return true; }
    }
    return false;
}

bool ReviewLog::deleteReview(std::string reviewId) {
    for (auto it = reviews.begin(); it != reviews.end(); ++it) {
        if (it->getReviewId() == reviewId) {
            reviews.erase(it);
            reviewCount--;
            return true;
        }
    }
    return false;
}

void ReviewLog::displayAllReviews() {
    if (reviews.empty()) { cout << "No reviews found." << endl; return; }
    for (const auto& r : reviews) r.display();
}

std::vector<Review> ReviewLog::getAllReviews() const {
    return reviews;
}
