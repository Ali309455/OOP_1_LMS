#include "TransactionReview.h"
#include<iostream>

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

// ========= transaction Implementation =========

transaction::transaction() : transactionId(""), studentId(""), isbn(""), issueDate(""), dueDate(""), returnDate(""), status("active"), fine(0.0) {}

transaction::transaction(string transactionId, string studentId, string username, string isbn, string issueDate, string dueDate, string returnDate, string status, double fine) {
    this->transactionId = transactionId;
    this->studentId = studentId;
    this->isbn = isbn;
    this->username= username;
    this->issueDate = issueDate;
    this->dueDate = dueDate;
    this->returnDate = returnDate;
    this->status = status;
    this->fine = fine;
}

void transaction::setTransactionId(string transactionId) { this->transactionId = transactionId; }
void transaction::setStudentId(string studentId) { this->studentId = studentId; }
void transaction::setIsbn(string isbn) { this->isbn = isbn; }
void transaction::setUsername(string username) {this->username = username;}
void transaction::setIssueDate(string issueDate) { this->issueDate = issueDate; }
void transaction::setDueDate(string dueDate) { this->dueDate = dueDate; }
void transaction::setReturnDate(string returnDate) { this->returnDate = returnDate; }
void transaction::setStatus(string status) { this->status = status; }
void transaction::setFine(double fine) { this->fine = fine; }

string transaction::getTransactionId() const { return transactionId; }
string transaction::getStudentId() const { return studentId; }
string transaction::getIsbn() const { return isbn; }
string transaction::getUsername() const { return username; }
string transaction::getIssueDate() const { return issueDate; }
string transaction::getDueDate() const { return dueDate; }
string transaction::getReturnDate() const { return returnDate; }
string transaction::getStatus() const { return status; }
double transaction::getFine() const { return fine; }

bool transaction::isActive() const { return status == "active"; }
bool transaction::isReturned() const { return status == "returned"; }
bool transaction::isOverdue() const { return status == "overdue"; }

void transaction::markReturned(string returnedOn, double calculatedFine) {
    returnDate = returnedOn;
    fine = calculatedFine;
    status = "returned";
}

void transaction::updateOverdueStatus(string todayDate) {
    if (!isReturned() && FineCalculator::daysOverdue(dueDate, todayDate) > 0) {
        status = "overdue";
    }
}

void transaction::display() const {
    cout << "Transaction ID: " << transactionId << "\nStudent ID: " << studentId
         << "\nISBN: " << isbn << "\nIssue Date: " << issueDate << "\nDue Date: " << dueDate
         << "\nReturn Date: " << (returnDate.empty() ? "-" : returnDate)
         << "\nStatus: " << status << "\nFine: " << fine << "\n-----------------------------" << endl;
}

// ========= transactionlog Implementation =========
int transactionlog::transactioncount = 0;
void transactionlog::addTransaction(const transaction& t) { transactions.push_back(t);transactioncount++; }



bool transactionlog::removeTransaction(string transactionId) {
    for (auto it = transactions.begin(); it != transactions.end(); ++it) {
        if (it->getTransactionId() == transactionId) {
            transactions.erase(it);
            return true;
        }
    }
    return false;
}

transaction* transactionlog::findTransactionById(string transactionId) {
    for (auto& t : transactions) {
        if (t.getTransactionId() == transactionId) return &t;
    }
    return nullptr;
}

bool transactionlog::hasActiveTransaction(string studentId, string isbn) {
    for (const auto& t : transactions) {
        if (t.getStudentId() == studentId && t.getIsbn() == isbn && t.isActive()) return true;
    }
    return false;
}

bool transactionlog::issueBook(string transactionId, string studentId, string username, string isbn, string issueDate, string dueDate) {
    if (hasActiveTransaction(studentId, isbn)) return false;
    transactions.emplace_back(transactionId, studentId, username, isbn, issueDate, dueDate, "", "active", 0.0);
    transactioncount++;
    return true;
}

bool transactionlog::returnBook(string transactionId, string returnDate, string membershipType) {
    transaction* t = findTransactionById(transactionId);
    if (t == nullptr || t->isReturned()) return false;
    double finalFine = FineCalculator::calculateFinalFine(t->getDueDate(), returnDate, membershipType);
    t->markReturned(returnDate, finalFine);
    return true;
}

void transactionlog::updateAllOverdue(string todayDate) {
    for (auto& t : transactions) t.updateOverdueStatus(todayDate);
}

void transactionlog::displayAllTransactions() {
    if (transactions.empty()) { cout << "No transactions found." << endl; return; }
    for (const auto& t : transactions) t.display();
}
std::vector<transaction> transactionlog::getAllTransactions() const {
    return transactions;
}

// ========= Review Implementation =========

Review::Review() : reviewId(""), studentId(""), username(""), isbn(""), bookname(""), rating(0), comment(""), status("pending"), reviewDate("") {}

Review::Review(string reviewId, string studentId, string username, string isbn, string bookname, int rating, string comment, string status, string reviewDate) {
    this->reviewId = reviewId;
    this->studentId = studentId;
    this->username = username;
    this->isbn = isbn;
    this->bookname = bookname;
    this->rating = rating;
    this->comment = comment;
    this->status = status;
    this->reviewDate = reviewDate;
}

// (Standard Getters/Setters omitted for brevity, but they follow the same pattern as above)
void Review::approve() { status = "approved"; }
bool Review::isApproved() const { return status == "approved"; }
bool Review::isPending() const { return status == "pending"; }
string Review::getStudentId()const {return studentId;}
string Review::getUsername()const {return username;}
string Review::getIsbn()const {return isbn;}
string Review::getBookname()const {return bookname;}
string Review::getReviewId()const {return reviewId;}
string Review::getReviewDate()const {return reviewDate;}
string Review::getComment()const {return comment;}
string Review::getStatus()const {return status;}
int Review::getRating()const {return rating;}

void Review::display() const {
    cout << "Review ID: " << reviewId << "\nRating: " << rating << "/5\nComment: " << comment
         << "\nStatus: " << status << "\n-----------------------------" << endl;
}

// ========= Reviewlog Implementation =========
int Reviewlog::reviewcount = 0;
bool Reviewlog::addReview(const Review& r) {
    for (const auto& existing : reviews) {
        if (existing.getStudentId() == r.getStudentId() && existing.getIsbn() == r.getIsbn()) return false;
    }
    reviewcount++;
    reviews.push_back(r);
    return true;
}

bool Reviewlog::approveReview(string reviewId) {
    for (auto& r : reviews) {
        if (r.getReviewId() == reviewId) { r.approve(); return true; }
    }
    return false;
}

bool Reviewlog::deleteReview(std::string reviewId) {
    for (auto it = reviews.begin(); it != reviews.end(); ++it) {
        if (it->getReviewId() == reviewId) {
            reviews.erase(it);
            reviewcount--;
            return true;
        }
    }
    return false;
}

void Reviewlog::displayAllReviews() {
    if (reviews.empty()) { cout << "No reviews found." << endl; return; }
    for (const auto& r : reviews) r.display();
}

std::vector<Review> Reviewlog::getAllReviews() const {
    return reviews;
}
