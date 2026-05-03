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

    bool issueOneCopy();
    void returnOneCopy();
    std::string statusToString() const;
};

class BookCatalog {
private:
    std::vector<Book> books;

public:
    bool addBook(const Book& book);
    bool removeBook(const std::string& isbn);
    const std::vector<Book>& getAllBooks() const;
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
    Membership(std::string id, int loandays);
    virtual ~Membership();

    virtual std::string getTierName() const = 0;
    virtual int getBorrowedLimit() const = 0;
    virtual double getFineDiscount() const = 0;
    virtual double getRenewalFee() const = 0;

    int getLoanDuration() const;
    std::string getStudentId() const;
    time_t getExpiryDate() const;
    time_t getStartDate() const;
    bool getStatus() const;
    bool isExpired();
    void renewMembership();
};

class Silver : public Membership {
public:
    Silver(std::string id);
    int getBorrowedLimit() const override;
    double getFineDiscount() const override;
    double getRenewalFee() const override;
    std::string getTierName() const override;
};

class Gold : public Membership {
public:
    Gold(std::string id);
    int getBorrowedLimit() const override;
    double getFineDiscount() const override;
    double getRenewalFee() const override;
    std::string getTierName() const override;
};

class Platinum : public Membership {
public:
    Platinum(std::string id);
    int getBorrowedLimit() const override;
    double getFineDiscount() const override;
    double getRenewalFee() const override;
    std::string getTierName() const override;
};

Membership* createMembership(std::string tier, std::string studentId);

// ========= WALLET SYSTEM =========
class Wallet {
private:
    std::string studentId;
    double balance;
    bool suspended;
    static constexpr double SUSPENSION_THRESHOLD = -30.0;

public:
    Wallet(std::string id, double initialDeposit);
    Wallet(std::string user_id, double Deposit, bool suspended);
    std::string getStudentId() const;
    double getBalance() const;
    bool isSuspended() const;
    void addAmount(double amount);
    void deductFine(double fineAmount);
    void deductMembershipRenewalFee(double feeAmount);
};

class WalletLog {
private:
    struct WalletEntry {
        std::string studentId;
        double amount;
        std::string type;
        time_t timestamp;
    };
    std::vector<Wallet> wallets;
    std::vector<WalletEntry> logs;

public:
    void createWallet(std::string studentId, double initialDeposit);
    void createWallet(std::string studentId, double initialDeposit, int sus);
    Wallet* getWallet(std::string studentId);
    bool isUserSuspended(std::string studentId);
    void applyFine(std::string studentId, double fineAmount);
    void payMembershipRenewalFee(std::string studentId, double feeAmount);
    void addMoney(std::string studentId, double amount);
};

#endif
