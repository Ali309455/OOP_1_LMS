#pragma once

#include "Auth.h"
#include "Database.h"
#include "BookMembership.h"
#include "transactionreview.h"

// Used for both Student and Librarian registration
struct RegistrationResult { 
    bool success;
    std::string userId;
    std::string message; 
};
// main library system class that manages users, books, transactions, reviews, and overall system operations, with integration to the database for persistence and retrieval of data
class LibrarySystem {
    AuthManager authManager; // manages user authentication and registration
    transactionlog TransactionManager; // manages book issue/return transactions
    Reviewlog ReviewManager; // manages book reviews and approvals
    BookCatalog BooksManager; // manages the library's book catalog
    FineCalculator FineCalc; // calculates fines for overdue books
    Person* currentUser = nullptr; // tracks the currently logged-in user
    Wallet libraryWallet; // manages the library's funds from fines and membership fees
    int totalBooks;
    int activeTransations;
    int pendingReviews;
public:
    LibrarySystem();
    ~LibrarySystem() = default;
    // ========== System Lifecycle ==========
    void initializeSystem();
   // ========== database fetching =========
    void loadUsersIntoSystem();
    void loadBooksIntoSystem();
    void loadTransactionsIntoSystem();
    void loadReviewsIntoSystem();
    void loadWalletsIntoSystem();
    // ========= setters & getters =========
    int gettotalBooks() const;
    int getactiveTransations() const;
    int getpendingReviews() const;

    void settotalBooks(int totalbooks);
    void setactiveTransations(int transactions);
    void setpendingReviews(int r);
    // ========== Authentication ===========
    QVariantMap login(const std::string& email, const std::string& password);
    void logout();
    std::string generateId(const std::string& prefix, int maxIDfromDB);
    // ========== User Management ==========
    RegistrationResult registerStudent( const std::string& name, const std::string& email, const std::string& pwd,const std::string& status, const std::string& membership, const std::string& role, double balance);
    RegistrationResult registerLibrarian( const std::string& name, const std::string& email, const std::string& pwd, const std::string& role);
    RegistrationResult registerUser( const std::string& name, const std::string& email, const std::string& pwd,const std::string& status, const std::string& membership, const std::string& role, double balance);
    bool removeUser(const std::string& sid);
    bool updateStudent( const std::string& id,const std::string& name, const std::string& email, const std::string& pwd,const std::string& status, const std::string& membership, const std::string& role);
    bool updateLibrarian( const std::string& id ,const std::string& name, const std::string& email, const std::string& pwd, const std::string& role);
    bool updateUser( const std::string& id, const std::string& name, const std::string& email, const std::string& pwd,  const std::string& membership, const std::string& role,const std::string& status ="");
    // ========== Catalog Operations ==========
    bool addbook(const std::string& isbn,const std::string&  title,const std::string&  author, const std::string& category,const std::string&  section, const std::string& publisher,const std::string&  edition, const std::string& language, int publicationYear, int pages,int totalCopies);
    bool removeBook(const std::string& isbn);
    bool updateBook(const std::string& isbn,int totalCopies);
    // ========== Transaction/Book Operations ==========
    bool issueBook(const std::string& isbn, const std::string& studentID);    // Called by librarian
    bool returnBook(const std::string& txnID);   // Called by librarian

    // ========== Membership Operations =========
    QVariantMap getCurrentMembershipDetails();
    bool renewMembership(const std::string& studentId);
    bool upgradeStudentMembership(const std::string& studentId, const std::string& newTier);

    // ========== Review System ==========
    bool submitReview(const std::string& studentId, const std::string& isbn, int rating, const std::string& comment);
    bool approveReview(const std::string& reviewId);
    bool deleteReview(const std::string& reviewID);

    // ========== Utility ==========
    QVariantMap getStudentDashboardData(const std::string& studentId);
    QVariantList getStudentBorrowHistory(const std::string& studentId);
    std::vector<Book> getAllBooks() const;
    std::vector<Person*> getAllUsers() const;
    std::vector<transaction> getAllTransactions() const;
    std::vector<Review> getAllReviews() const;
    void displayAllData() const ;
    static bool exportDatabaseReportPdf(const QString& outputPdfPath, QString* outError = nullptr);
    void syncLibraryStats();

    double getLibraryBalance() const;
    bool addBalance(const std::string& sid, double amount);
};
