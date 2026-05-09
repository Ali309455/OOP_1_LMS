#ifndef BOOK_MEMBERSHIP_H
#define BOOK_MEMBERSHIP_H

#include <string>
#include <vector>
#include <ctime>

// ========= CONSTANTS & ENUMS =========
enum BookStatus { AVAILABLE, LIMITED, UNAVAILABLE };
extern const int YEAR_IN_SECONDS;

// ========= BOOK SYSTEM =========
class Book {
private:
    std::string isbn, title, author, category, section, publisher, edition, language;
    int totalCopies, availableCopies, publicationYear, pages;
    BookStatus status;

    void updateStatus();

public:
    Book(std::string isbn, std::string title, std::string author, std::string category, std::string section,
         std::string publisher = "", std::string edition = "", std::string language = "",int avaliableCopies = 0,
         int publicationYear = 0, int pages = 0, int totalCopies = 0);

    // friend function to print book details
    friend std::ostream& operator<<(std::ostream& os, const Book& book);
    // Getters
    std::string getIsbn() const;
    std::string getTitle() const;
    std::string getAuthor() const;
    std::string getCategory() const;
    std::string getSection() const;
    std::string getPublisher() const;
    std::string getEdition() const;
    std::string getLanguage() const;
    int getPublicationYear() const;
    int getPages() const;
    int getTotalCopies() const;
    int getAvailableCopies() const;
    BookStatus getStatus() const;
    // Setters
    void setTitle(const std::string& t) ;
    void setAuthor(const std::string& a) ;
    void setCategory(const std::string& c) ;
    void setSection(const std::string& s) ;
    void setPublisher(const std::string& p);
    void setEdition(const std::string& e);
    void setLanguage(const std::string& l);
    void setPublicationYear(int y) ;
    void setPages(int p);
    void setTotalCopies(int total);
    // Book issue and return functions
    bool issueOneCopy();
    void returnOneCopy();
    std::string statusToString() const;
};

class BookCatalog {
private:
    std::vector<Book> books; // association with Book class

public:
    static int bookcount;
    // Catalog management functions
    bool addBook(const Book& book);
    bool updateBook(const std::string& isbn,int totalCopies);
    bool removeBook(const std::string& isbn);
    const std::vector<Book>& getAllBooks() const;
    // Search functions
    Book* findByIsbn(const std::string& isbn) ;
    std::vector<Book> searchByTitle(const std::string& title) const;
    std::vector<Book> searchByAuthor(const std::string& author) const;
    std::vector<Book> searchByCategory(const std::string& category) const;
    std::vector<Book> searchBySection(const std::string& section) const;
};

// ========= MEMBERSHIP SYSTEM =========
class Membership {
protected:
    std::string studentId;
    int loanDurationDays;
    bool isActive;
    time_t startDate, expiryDate;

public:
    // constructor
    Membership(std::string id, int loandays);
    // virtual destructor to allow proper cleanup of derived classes
    virtual ~Membership();
    // pure virtual functions to be implemented by derived classes
    virtual std::string getTierName() const = 0;
    virtual int getBorrowedLimit() const = 0;
    virtual double getFineDiscount() const = 0;
    virtual double getRenewalFee() const = 0;
    // getter functions for membership class
    int getLoanDuration() const;
    std::string getStudentId() const;
    time_t getExpiryDate() const;
    time_t getStartDate() const;
    bool getStatus() const;
    bool isExpired();
    void renewMembership();
};
// ========= DERIVED MEMBERSHIP TIERS =========
class Silver : public Membership {
public:
    Silver(std::string id);
    // override functions for silver tier
    int getBorrowedLimit() const override;
    double getFineDiscount() const override;
    double getRenewalFee() const override;
    std::string getTierName() const override;
};

class Gold : public Membership {
public:
    Gold(std::string id);
    // override functions for gold tier
    int getBorrowedLimit() const override;
    double getFineDiscount() const override;
    double getRenewalFee() const override;
    std::string getTierName() const override;
};

class Platinum : public Membership {
public:
    Platinum(std::string id);
    // override functions for platinum tier
    int getBorrowedLimit() const override;
    double getFineDiscount() const override;
    double getRenewalFee() const override;
    std::string getTierName() const override;
};
// Factory function to create membership based on tier
Membership* createMembership(std::string tier, std::string studentId);

// ========= WALLET SYSTEM =========
class Wallet {
private:
    std::string studentId;
    double balance;
    bool suspended;
public:
    // constructors
    Wallet(std::string id,double initialDeposit);
    Wallet(std::string id,double deposit,bool suspended);
    // getter functions for wallet class
    std::string getStudentId() const;
    double getBalance() const;
    bool isSuspended() const;
    void suspendWallet();
    void activateWallet();
    // function to add/deduct amount from wallet balance
    void setbalance(double b);
    void addAmount(double amount);
    bool deductAmount(double amount);
    void deductFine(double fineAmount);
    void deductMembershipRenewalFee(double feeAmount);
};

// ========= WALLET TRANSACTION =========
class WalletTransaction {
private:
    std::string studentId;
    double amount;
    std::string type;
    time_t timestamp;
public:
    // constructor
    WalletTransaction(std::string sid,double amt,std::string t);
    // getter functions for wallet transaction class
    std::string getStudentId() const;
    double getAmount() const;
    std::string getType() const;
    time_t getTimestamp() const;
};
// ========= WALLET LOG =========
class WalletLog {
private:
    // structure to represent a wallet transaction log entry
    struct WalletEntry {
        std::string studentId;
        double amount;
        std::string type;
        time_t timestamp;
    };
    std::vector<WalletEntry> logs; // vector to store wallet transaction logs
public:
    // function to add a log entry to the wallet log
    void addLog(std::string studentId,double amount,std::string type);
    std::vector<WalletEntry> getAllLogs() const;
    std::vector<WalletEntry> getLogsByStudent(std::string studentId) const;
};
#endif

