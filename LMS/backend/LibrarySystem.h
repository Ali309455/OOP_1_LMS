#pragma once

#include "Auth.h"
#include "Database.h"
#include "BookMembership.h"
#include "transactionreview.h"
// Forward declarations if necessary
struct RegistrationResult {
    bool success;
    std::string userId;
    std::string message; // Optional: To explain why it failed
};
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
    QVariantMap login(const std::string& email, const std::string& password);
    void logout();
    std::string generateId(const std::string& prefix, int maxIDfromDB);
    // ========== User Management ==========
    RegistrationResult registerStudent( const std::string& name, const std::string& email, const std::string& pwd,const std::string& status, const std::string& membership, const std::string& role);
    RegistrationResult registerLibrarian( const std::string& name, const std::string& email, const std::string& pwd, const std::string& role);
    RegistrationResult registerUser( const std::string& name, const std::string& email, const std::string& pwd,const std::string& status, const std::string& membership, const std::string& role);
    bool removeUser(const std::string& sid);
    bool updateStudent( const std::string& id,const std::string& name, const std::string& email, const std::string& pwd,const std::string& status, const std::string& membership, const std::string& role);
    bool updateLibrarian( const std::string& id ,const std::string& name, const std::string& email, const std::string& pwd, const std::string& role);
    bool updateUser( const std::string& id, const std::string& name, const std::string& email, const std::string& pwd,  const std::string& membership, const std::string& role,const std::string& status ="");
    // ========== Catalog Operations ==========
    bool addbook(const std::string& isbn,const std::string&  title,const std::string&  author, const std::string& category,const std::string&  section, const std::string& publisher,const std::string&  edition, const std::string& language, int publicationYear, int pages,int totalCopies);
    bool removeBook(const std::string& isbn);
    bool updateBook(const std::string& isbn,const std::string&  title,const std::string&  author, const std::string& category,const std::string&  section, const std::string& publisher,const std::string&  edition, const std::string& language, int publicationYear, int pages,int totalCopies);
    // ========== Transaction/Book Ops ==========
    bool issueBook(const std::string& isbn, const std::string& studentID);    // Called by librarian
    bool returnBook(const std::string& txnID);   // Called by librarian

    // ========== Membership Ops =========
    bool upgradeStudentMembership(const std::string& studentId, const std::string& newTier);
    QVariantMap getCurrentMembershipDetails();
    bool renewMembership(const std::string& studentId);

    // ========== Review System ==========
    bool submitReview(const std::string& studentId, const std::string& isbn, int rating, const std::string& comment);
    bool approveReview(const std::string& reviewId);
    bool deleteReview(const std::string& reviewID);

    // ========== Utility ==========
    std::vector<Book> getAllBooks() const;
    std::vector<Person*> getAllUsers() const;
    std::vector<transaction> getAllTransactions() const;
    std::vector<Review> getAllReviews() const;
    void displayAllData() const ;

};
