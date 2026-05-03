#ifndef TRANSACTION_REVIEW_H
#define TRANSACTION_REVIEW_H

#include <vector>
#include <string>

// ========= FINE CALCULATOR =========
class FineCalculator {
public:
    static int daysOverdue(const std::string& dueDate, const std::string& returnDate);
    static double calculateBaseFine(const std::string& dueDate, const std::string& returnDate, double ratePerDay = 10.0);
    static double applyMembershipDiscount(double fine, const std::string& membershipType);
    static double calculateFinalFine(const std::string& dueDate, const std::string& returnDate, const std::string& membershipType, double ratePerDay = 10.0);
};

// ========= TRANSACTION SYSTEM =========
class transaction {
private:
    std::string transactionId;
    std::string studentId;
    std::string isbn;
    std::string issueDate;
    std::string dueDate;
    std::string returnDate;
    std::string status;
    double fine;

public:
    transaction();
    transaction(std::string transactionId, std::string studentId, std::string isbn,
                std::string issueDate, std::string dueDate, std::string returnDate,
                std::string status, double fine);

    // Setters
    void setTransactionId(std::string transactionId);
    void setStudentId(std::string studentId);
    void setIsbn(std::string isbn);
    void setIssueDate(std::string issueDate);
    void setDueDate(std::string dueDate);
    void setReturnDate(std::string returnDate);
    void setStatus(std::string status);
    void setFine(double fine);

    // Getters
    std::string getTransactionId() const;
    std::string getStudentId() const;
    std::string getIsbn() const;
    std::string getIssueDate() const;
    std::string getDueDate() const;
    std::string getReturnDate() const;
    std::string getStatus() const;
    double getFine() const;

    bool isActive() const;
    bool isReturned() const;
    bool isOverdue() const;

    void markReturned(std::string returnedOn, double calculatedFine);
    void updateOverdueStatus(std::string todayDate);
    void display() const;
};

class transactionlog {
private:
    std::vector<transaction> transactions;

public:
    static int transactioncount;
    void addTransaction(const transaction& t);
    bool removeTransaction(std::string transactionId);
    transaction* findTransactionById(std::string transactionId);
    bool hasActiveTransaction(std::string studentId, std::string isbn);
    bool issueBook(std::string transactionId, std::string studentId, std::string isbn, std::string issueDate, std::string dueDate);
    bool returnBook(std::string transactionId, std::string returnDate, std::string membershipType);
    void updateAllOverdue(std::string todayDate);
    std::vector<transaction> getTransactionsByStudent(std::string studentId);
    std::vector<transaction> getOverdueTransactions();
    void displayAllTransactions();
    std::vector<transaction> getAllTransactions() const;
};

// ========= REVIEW SYSTEM =========
class Review {
private:
    std::string reviewId;
    std::string studentId;
    std::string isbn;
    int rating;
    std::string comment;
    std::string status;
    std::string reviewDate;

public:
    Review();
    Review(std::string reviewId, std::string studentId, std::string isbn,
           int rating, std::string comment, std::string status, std::string reviewDate);

    void setReviewId(std::string reviewId);
    void setStudentId(std::string studentId);
    void setIsbn(std::string isbn);
    void setRating(int rating);
    void setComment(std::string comment);
    void setStatus(std::string status);
    void setReviewDate(std::string reviewDate);

    std::string getReviewId() const;
    std::string getStudentId() const;
    std::string getIsbn() const;
    int getRating() const;
    std::string getComment() const;
    std::string getStatus() const;
    std::string getReviewDate() const;

    bool isApproved() const;
    bool isPending() const;
    void approve();
    void display() const;
};

class Reviewlog {
private:
    std::vector<Review> reviews;

public:
    static int reviewcount;
    bool hasStudentReviewedBook(std::string studentId, std::string isbn);
    bool addReview(const Review& r);
    Review* findReviewById(std::string reviewId);
    bool approveReview(std::string reviewId);
    bool rejectReview(std::string reviewId);
    std::vector<Review> getReviewsByBook(std::string isbn);
    std::vector<Review> getReviewsByStudent(std::string studentId);
    std::vector<Review> getPendingReviews();
    std::vector<Review> getApprovedReviews();
    void displayAllReviews();
    std::vector<Review> getAllReviews() const;
};

#endif
