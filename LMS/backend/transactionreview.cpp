#include<iostream>
#include<vector>
#include<string>
#include<iomanip>

using namespace std;

class FineCalculator {
public:
    static int daysOverdue(const string& dueDate, const string& returnDate) {
        // format assumed: YYYY-MM-DD
        if (dueDate.length() != 10 || returnDate.length() != 10) return 0;

        int dueYear = stoi(dueDate.substr(0, 4));
        int dueMonth = stoi(dueDate.substr(5, 2));
        int dueDay = stoi(dueDate.substr(8, 2));

        int retYear = stoi(returnDate.substr(0, 4));
        int retMonth = stoi(returnDate.substr(5, 2));
        int retDay = stoi(returnDate.substr(8, 2));

        
        int dueTotal = dueYear * 365 + dueMonth * 30 + dueDay;
        int retTotal = retYear * 365 + retMonth * 30 + retDay;

        if (retTotal <= dueTotal) return 0;
        return retTotal - dueTotal;
    }

    static double calculateBaseFine(const string& dueDate, const string& returnDate, double ratePerDay = 10.0) {
        int overdueDays = daysOverdue(dueDate, returnDate);
        return overdueDays * ratePerDay;
    }

    static double applyMembershipDiscount(double fine, const string& membershipType) {
        if (membershipType == "Gold" || membershipType == "gold") {
            return fine * 0.90;   // 10% discount
        }
        if (membershipType == "Platinum" || membershipType == "platinum") {
            return fine * 0.80;   // 20% discount
        }
        return fine; // Silver/default no discount
    }

    static double calculateFinalFine(const string& dueDate,
                                     const string& returnDate,
                                     const string& membershipType,
                                     double ratePerDay = 10.0) {
        double baseFine = calculateBaseFine(dueDate, returnDate, ratePerDay);
        return applyMembershipDiscount(baseFine, membershipType);
    }
};

class transaction {
private:
    string transactionId;
    string studentId;
    string isbn;
    string issueDate;
    string dueDate;
    string returnDate;
    string status;   
    double fine;

public:
    transaction() {
        transactionId = "";
        studentId = "";
        isbn = "";
        issueDate = "";
        dueDate = "";
        returnDate = "";
        status = "active";
        fine = 0.0;
    }

    transaction(string transactionId, string studentId, string isbn,
                string issueDate, string dueDate, string returnDate,
                string status, double fine) {
        this->transactionId = transactionId;
        this->studentId = studentId;
        this->isbn = isbn;
        this->issueDate = issueDate;
        this->dueDate = dueDate;
        this->returnDate = returnDate;
        this->status = status;
        this->fine = fine;
    }

    void setTransactionId(string transactionId) { this->transactionId = transactionId; }
    void setStudentId(string studentId) { this->studentId = studentId; }
    void setIsbn(string isbn) { this->isbn = isbn; }
    void setIssueDate(string issueDate) { this->issueDate = issueDate; }
    void setDueDate(string dueDate) { this->dueDate = dueDate; }
    void setReturnDate(string returnDate) { this->returnDate = returnDate; }
    void setStatus(string status) { this->status = status; }
    void setFine(double fine) { this->fine = fine; }

    string getTransactionId() const { return transactionId; }
    string getStudentId() const { return studentId; }
    string getIsbn() const { return isbn; }
    string getIssueDate() const { return issueDate; }
    string getDueDate() const { return dueDate; }
    string getReturnDate() const { return returnDate; }
    string getStatus() const { return status; }
    double getFine() const { return fine; }

    bool isActive() const { return status == "active"; }
    bool isReturned() const { return status == "returned"; }
    bool isOverdue() const { return status == "overdue"; }

    void markReturned(string returnedOn, double calculatedFine) {
        returnDate = returnedOn;
        fine = calculatedFine;
        status = "returned";
    }

    void updateOverdueStatus(string todayDate) {
        if (!isReturned() && FineCalculator::daysOverdue(dueDate, todayDate) > 0) {
            status = "overdue";
        }
    }

    void display() const {
        cout << "Transaction ID: " << transactionId << endl;
        cout << "Student ID: " << studentId << endl;
        cout << "ISBN: " << isbn << endl;
        cout << "Issue Date: " << issueDate << endl;
        cout << "Due Date: " << dueDate << endl;
        cout << "Return Date: " << (returnDate.empty() ? "-" : returnDate) << endl;
        cout << "Status: " << status << endl;
        cout << "Fine: " << fine << endl;
        cout << "-----------------------------" << endl;
    }
};

class transactionlog {
private:
    vector<transaction> transactions;

public:
    void addTransaction(const transaction& t) {
        transactions.push_back(t);
    }

    bool removeTransaction(string transactionId) {
        for (int i = 0; i < transactions.size(); i++) {
            if (transactions[i].getTransactionId() == transactionId) {
                transactions.erase(transactions.begin() + i);
                return true;
            }
        }
        return false;
    }

    transaction* findTransactionById(string transactionId) {
        for (int i = 0; i < transactions.size(); i++) {
            if (transactions[i].getTransactionId() == transactionId) {
                return &transactions[i];
            }
        }
        return nullptr;
    }

    bool hasActiveTransaction(string studentId, string isbn) {
        for (int i = 0; i < transactions.size(); i++) {
            if (transactions[i].getStudentId() == studentId &&
                transactions[i].getIsbn() == isbn &&
                transactions[i].isActive()) {
                return true;
            }
        }
        return false;
    }

    bool issueBook(string transactionId, string studentId, string isbn,
                   string issueDate, string dueDate) {
        if (hasActiveTransaction(studentId, isbn)) {
            return false;
        }

        transaction t(transactionId, studentId, isbn, issueDate, dueDate, "", "active", 0.0);
        addTransaction(t);
        return true;
    }

    bool returnBook(string transactionId, string returnDate, string membershipType) {
        transaction* t = findTransactionById(transactionId);

        if (t == nullptr) return false;
        if (t->isReturned()) return false;

        double finalFine = FineCalculator::calculateFinalFine(
            t->getDueDate(),
            returnDate,
            membershipType
        );

        t->markReturned(returnDate, finalFine);
        return true;
    }

    void updateAllOverdue(string todayDate) {
        for (int i = 0; i < transactions.size(); i++) {
            transactions[i].updateOverdueStatus(todayDate);
        }
    }

    vector<transaction> getTransactionsByStudent(string studentId) {
        vector<transaction> result;
        for (int i = 0; i < transactions.size(); i++) {
            if (transactions[i].getStudentId() == studentId) {
                result.push_back(transactions[i]);
            }
        }
        return result;
    }

    vector<transaction> getOverdueTransactions() {
        vector<transaction> result;
        for (int i = 0; i < transactions.size(); i++) {
            if (transactions[i].isOverdue()) {
                result.push_back(transactions[i]);
            }
        }
        return result;
    }

    void displayAllTransactions() {
        if (transactions.empty()) {
            cout << "No transactions found." << endl;
            return;
        }

        for (int i = 0; i < transactions.size(); i++) {
            transactions[i].display();
        }
    }
};

class Review {
private:
    string reviewId;
    string studentId;
    string isbn;
    int rating;
    string comment;
    string status;      // pending, approved
    string reviewDate;

public:
    Review() {
        reviewId = "";
        studentId = "";
        isbn = "";
        rating = 0;
        comment = "";
        status = "pending";
        reviewDate = "";
    }

    Review(string reviewId, string studentId, string isbn,
           int rating, string comment, string status, string reviewDate) {
        this->reviewId = reviewId;
        this->studentId = studentId;
        this->isbn = isbn;
        this->rating = rating;
        this->comment = comment;
        this->status = status;
        this->reviewDate = reviewDate;
    }

    void setReviewId(string reviewId) { this->reviewId = reviewId; }
    void setStudentId(string studentId) { this->studentId = studentId; }
    void setIsbn(string isbn) { this->isbn = isbn; }
    void setRating(int rating) { this->rating = rating; }
    void setComment(string comment) { this->comment = comment; }
    void setStatus(string status) { this->status = status; }
    void setReviewDate(string reviewDate) { this->reviewDate = reviewDate; }

    string getReviewId() const { return reviewId; }
    string getStudentId() const { return studentId; }
    string getIsbn() const { return isbn; }
    int getRating() const { return rating; }
    string getComment() const { return comment; }
    string getStatus() const { return status; }
    string getReviewDate() const { return reviewDate; }

    bool isApproved() const { return status == "approved"; }
    bool isPending() const { return status == "pending"; }

    void approve() {
        status = "approved";
    }

    void display() const {
        cout << "Review ID: " << reviewId << endl;
        cout << "Student ID: " << studentId << endl;
        cout << "ISBN: " << isbn << endl;
        cout << "Rating: " << rating << endl;
        cout << "Comment: " << comment << endl;
        cout << "Status: " << status << endl;
        cout << "Review Date: " << reviewDate << endl;
        cout << "-----------------------------" << endl;
    }
};

class Reviewlog {
private:
    vector<Review> reviews;

public:
    bool hasStudentReviewedBook(string studentId, string isbn) {
        for (int i = 0; i < reviews.size(); i++) {
            if (reviews[i].getStudentId() == studentId &&
                reviews[i].getIsbn() == isbn) {
                return true;
            }
        }
        return false;
    }

    bool addReview(const Review& r) {
        if (hasStudentReviewedBook(r.getStudentId(), r.getIsbn())) {
            return false;
        }
        reviews.push_back(r);
        return true;
    }

    Review* findReviewById(string reviewId) {
        for (int i = 0; i < reviews.size(); i++) {
            if (reviews[i].getReviewId() == reviewId) {
                return &reviews[i];
            }
        }
        return nullptr;
    }

    bool approveReview(string reviewId) {
        Review* r = findReviewById(reviewId);
        if (r == nullptr) return false;
        r->approve();
        return true;
    }

    bool rejectReview(string reviewId) {
        for (int i = 0; i < reviews.size(); i++) {
            if (reviews[i].getReviewId() == reviewId) {
                reviews.erase(reviews.begin() + i);   // reject means delete
                return true;
            }
        }
        return false;
    }

    vector<Review> getReviewsByBook(string isbn) {
        vector<Review> result;
        for (int i = 0; i < reviews.size(); i++) {
            if (reviews[i].getIsbn() == isbn) {
                result.push_back(reviews[i]);
            }
        }
        return result;
    }

    vector<Review> getReviewsByStudent(string studentId) {
        vector<Review> result;
        for (int i = 0; i < reviews.size(); i++) {
            if (reviews[i].getStudentId() == studentId) {
                result.push_back(reviews[i]);
            }
        }
        return result;
    }

    vector<Review> getPendingReviews() {
        vector<Review> result;
        for (int i = 0; i < reviews.size(); i++) {
            if (reviews[i].isPending()) {
                result.push_back(reviews[i]);
            }
        }
        return result;
    }

    vector<Review> getApprovedReviews() {
        vector<Review> result;
        for (int i = 0; i < reviews.size(); i++) {
            if (reviews[i].isApproved()) {
                result.push_back(reviews[i]);
            }
        }
        return result;
    }

    void displayAllReviews() {
        if (reviews.empty()) {
            cout << "No reviews found." << endl;
            return;
        }

        for (int i = 0; i < reviews.size(); i++) {
            reviews[i].display();
        }
    }
};


int main() {
    transactionlog tlog;
    Reviewlog rlog;

    cout << "===== ISSUE BOOK TEST =====" << endl;
    bool issue1 = tlog.issueBook("TXN-1001", "S001", "978-0132350884", "2026-04-01", "2026-04-15");
    bool issue2 = tlog.issueBook("TXN-1002", "S002", "978-0201633612", "2026-04-03", "2026-04-10");

    cout << "Issue 1: " << (issue1 ? "Success" : "Failed") << endl;
    cout << "Issue 2: " << (issue2 ? "Success" : "Failed") << endl;

    cout << "\n===== UPDATE OVERDUE TEST =====" << endl;
    tlog.updateAllOverdue("2026-04-20");
    tlog.displayAllTransactions();

    cout << "===== RETURN BOOK TEST =====" << endl;
    bool ret = tlog.returnBook("TXN-1001", "2026-04-20", "Gold");
    cout << "Return TXN-1001: " << (ret ? "Success" : "Failed") << endl;
    tlog.displayAllTransactions();

    cout << "===== REVIEW TEST =====" << endl;
    Review r1("REV-001", "S001", "978-0132350884", 5, "Excellent book!", "pending", "2026-04-20");
    Review r2("REV-002", "S002", "978-0201633612", 4, "Very useful.", "pending", "2026-04-20");

    cout << "Add Review 1: " << (rlog.addReview(r1) ? "Success" : "Failed") << endl;
    cout << "Add Review 2: " << (rlog.addReview(r2) ? "Success" : "Failed") << endl;

    // duplicate review test
    Review duplicate("REV-003", "S001", "978-0132350884", 3, "Second review", "pending", "2026-04-21");
    cout << "Duplicate Review Add: " << (rlog.addReview(duplicate) ? "Success" : "Failed") << endl;

    cout << "\n===== APPROVE REVIEW TEST =====" << endl;
    rlog.approveReview("REV-001");
    rlog.displayAllReviews();

    cout << "===== REJECT REVIEW TEST =====" << endl;
    rlog.rejectReview("REV-002");
    rlog.displayAllReviews();

    cout << "===== FINE CALCULATOR TEST =====" << endl;
    double fine = FineCalculator::calculateFinalFine("2026-04-10", "2026-04-20", "Platinum");
    cout << "Final Fine (Platinum): " << fixed << setprecision(2) << fine << endl;

    return 0;
}