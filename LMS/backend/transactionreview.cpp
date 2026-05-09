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
// Combines base fine calculation and membership discount application to get final fine amount
double FineCalculator::calculateFinalFine(const string& dueDate, const string& returnDate, const string& membershipType, double ratePerDay) {
    double baseFine = calculateBaseFine(dueDate, returnDate, ratePerDay);
    return applyMembershipDiscount(baseFine, membershipType);
}

// ========= transaction Implementation =========
transaction::transaction() : transactionId(""), studentId(""), isbn(""), issueDate(""), dueDate(""), returnDate(""), bookName(""), status("active"), fine(0.0) {}
// constructor
transaction::transaction(string transactionId, string studentId, string username, string isbn, string issueDate, string dueDate, string returnDate, string bookName , string status, double fine) {
    this->transactionId = transactionId;
    this->studentId = studentId;
    this->isbn = isbn;
    this->username= username;
    this->issueDate = issueDate;
    this->dueDate = dueDate;
    this->returnDate = returnDate;
    this->status = status;
    this->bookName = bookName;
    this->fine = fine;
}
// setter functions for transaction class
void transaction::setTransactionId(string transactionId) { this->transactionId = transactionId; }
void transaction::setStudentId(string studentId) { this->studentId = studentId; }
void transaction::setIsbn(string isbn) { this->isbn = isbn; }
void transaction::setUsername(string username) {this->username = username;}
void transaction::setIssueDate(string issueDate) { this->issueDate = issueDate; }
void transaction::setDueDate(string dueDate) { this->dueDate = dueDate; }
void transaction::setReturnDate(string returnDate) { this->returnDate = returnDate; }
void transaction::setStatus(string status) { this->status = status; }
void transaction::setFine(double fine) { this->fine = fine; }
// getter functions for transaction class
string transaction::getTransactionId() const { return transactionId; }
string transaction::getStudentId() const { return studentId; }
string transaction::getIsbn() const { return isbn; }
string transaction::getUsername() const { return username; }
string transaction::getIssueDate() const { return issueDate; }
string transaction::getDueDate() const { return dueDate; }
string transaction::getReturnDate() const { return returnDate; }
string transaction::getStatus() const { return status; }
string transaction::getbookName() const { return bookName; }
double transaction::getFine() const { return fine; }
// Helper functions to check transaction status
bool transaction::isActive() const { return status == "active"; }
bool transaction::isReturned() const { return status == "returned"; }
bool transaction::isOverdue() const { return status == "overdue"; }
// Marks the transaction as returned, sets the return date, and updates the fine amount
void transaction::markReturned(string returnedOn, double calculatedFine) {
    returnDate = returnedOn;
    fine = calculatedFine;
    status = "returned";
}
// Updates the transaction status to "overdue" if the current date is past the due date and the book has not been returned
void transaction::updateOverdueStatus(string todayDate) {
    if (!isReturned() && FineCalculator::daysOverdue(dueDate, todayDate) > 0) {
        status = "overdue";
    }
}
// Displays the transaction details in a readable format
void transaction::display() const {
    cout << "Transaction ID: " << transactionId << "\nStudent ID: " << studentId
         << "\nISBN: " << isbn << "\nIssue Date: " << issueDate << "\nDue Date: " << dueDate
         << "\nReturn Date: " << (returnDate.empty() ? "-" : returnDate)
         << "\nStatus: " << status << "\nFine: " << fine << "\n-----------------------------" << endl;
}

// ========= transactionlog Implementation =========
int transactionlog::transactioncount = 0;
void transactionlog::addTransaction(const transaction& t) { transactions.push_back(t);transactioncount++; } // Adds a new transaction to the log and increments the transaction count

// Removes a transaction from the log based on the transaction ID
bool transactionlog::removeTransaction(string transactionId) {
    for (auto it = transactions.begin(); it != transactions.end(); ++it) {
        if (it->getTransactionId() == transactionId) {
            transactions.erase(it);
            return true;
        }
    }
    return false;
}
// Finds and returns a pointer to a transaction based on the transaction ID
transaction* transactionlog::findTransactionById(string transactionId) {
    for (auto& t : transactions) {
        if (t.getTransactionId() == transactionId) return &t;
    }
    return nullptr;
}
// Checks if there is an active transaction for a given student ID and ISBN
bool transactionlog::hasActiveTransaction(string studentId, string isbn) {
    for (const auto& t : transactions) {
        if (t.getStudentId() == studentId && t.getIsbn() == isbn && t.isActive()) return true;
    }
    return false;
}
// Issues a book by creating a new transaction if there are no active transactions for the student and book, and adds it to the log
bool transactionlog::issueBook(string transactionId, string studentId, string username, string isbn, string issueDate, string dueDate, string bookName) {
    if (hasActiveTransaction(studentId, isbn)) return false;
    transactions.emplace_back(transactionId, studentId, username, isbn, issueDate, dueDate, "",bookName, "active", 0.0);
    transactioncount++;
    return true;
}
// Processes the return of a book by updating the corresponding transaction with the return date and calculated fine
bool transactionlog::returnBook(string transactionId, string returnDate, string membershipType) {
    transaction* t = findTransactionById(transactionId);
    if (t == nullptr || t->isReturned()) return false;
    double finalFine = FineCalculator::calculateFinalFine(t->getDueDate(), returnDate, membershipType);
    t->markReturned(returnDate, finalFine);
    return true;
}
// Updates the status of all transactions to "overdue" if they are past their due date and not yet returned
void transactionlog::updateAllOverdue(string todayDate) {
    for (auto& t : transactions) t.updateOverdueStatus(todayDate);
}
// displays all transactions in the log
void transactionlog::displayAllTransactions() {
    if (transactions.empty()) { cout << "No transactions found." << endl; return; }
    for (const auto& t : transactions) t.display();
}
// Returns a vector of all transactions in the log
std::vector<transaction> transactionlog::getAllTransactions() const {
    return transactions;
}
// Returns a vector of transactions for a specific student ID
std::vector<transaction> transactionlog::getTransactionsByStudent(std::string studentId)
{
    std::vector<transaction> result;

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
// constryuctors for Review class
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
// status management functions for Review class
void Review::approve() { status = "approved"; }
bool Review::isApproved() const { return status == "approved"; }
bool Review::isPending() const { return status == "pending"; }
// getter functions for Review class
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
// add a review to the log and increments the review count
bool Reviewlog::addReview(const Review& r) {
    for (const auto& existing : reviews) {
        if (existing.getStudentId() == r.getStudentId() && existing.getIsbn() == r.getIsbn()) return false;
    }
    reviewcount++;
    reviews.push_back(r);
    return true;
}
// approves a review by changing its status to "approved" if it exists in the log
bool Reviewlog::approveReview(string reviewId) {
    for (auto& r : reviews) {
        if (r.getReviewId() == reviewId) { r.approve(); return true; }
    }
    return false;
}
// deletes a review from the log based on the review ID and decrements the review count
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
// displays all reviews in the log
void Reviewlog::displayAllReviews() {
    if (reviews.empty()) { cout << "No reviews found." << endl; return; }
    for (const auto& r : reviews) r.display();
}

std::vector<Review> Reviewlog::getAllReviews() const {
    return reviews;
}
