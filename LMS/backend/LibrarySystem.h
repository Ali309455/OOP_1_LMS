#pragma once

#include "Auth.h"
#include "Database.h"
#include "BookMembership.h"
#include "transactionreview.h"
// Forward declarations if necessary

class LibrarySystem {
    AuthManager authManager;
    transactionlog TransactionManager;
    Reviewlog ReviewManager;
    BookCatalog BooksManager;
    WalletLog WalletsManager;
    FineCalculator FineCalc;
    // Add more service managers as needed, e.g., ReviewLog, TransactionLog, etc.

    // Store current user context (pointer, id, or email)
    Person* currentUser = nullptr;
public:
    LibrarySystem();

    // ========== System Lifecycle ==========
    void initializeSystem();
    void saveSystem();
   // ========== database fetching =========
    void loadUsersIntoSystem();
    void loadBooksIntoSystem();
    void loadTransactionsIntoSystem();
    void loadReviewsIntoSystem();
    void loadWalletsIntoSystem();
    // ========== Authentication ===========
    bool login(const std::string& email, const std::string& password);
    void logout();
    std::string generateId(const std::string& prefix, int count);
    // ========== User Management ==========
    bool registerStudent(const std::string& id, const std::string& name, const std::string& email, const std::string& pwd, int semester, const std::string& department);
    bool registerLibrarian(const std::string& id, const std::string& name, const std::string& email, const std::string& pwd, int employeeId, const std::string& department);

    // ========== Catalog Operations ==========
    bool addBook(const std::string& isbn, const std::string& title, const std::string& author, const std::string& genre, const std::string& section, int numCopies);
    bool removeBook(const std::string& isbn);

    // ========== Transaction/Book Ops ==========
    bool issueBook(const std::string& studentId, const std::string& isbn);    // Called by librarian
    bool returnBook(const std::string& txnID);   // Called by librarian

    // ========== Membership Ops =========
    bool upgradeStudentMembership(const std::string& studentId, const std::string& newTier);

    // ========== Review System ==========
    bool submitReview(const std::string& studentId, const std::string& isbn, int rating, const std::string& comment);
    bool approveReview(const std::string& reviewId);

    // ========== Utility ==========
    void listAllBooks();
    void listAllStudents();
    void listAllLibrarians();


};
