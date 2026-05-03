#include "BookMembership.h"
#include <stdexcept>
#include <algorithm>
#include <iostream>

using namespace std;

const int YEAR_IN_SECONDS = 365 * 24 * 60 * 60;

// ========= BOOK IMPLEMENTATION =========

Book::Book(string isbn, string title, string author, string category, string section,
           string publisher, string edition, string language, int publicationYear, int pages, int totalCopies, int avaliableCopies) {
    if(isbn.empty() || title.empty() || author.empty() || category.empty() || section.empty() || totalCopies <= 0) {
        throw invalid_argument("Invalid book details provided.");
    }
    this->isbn = isbn;
    this->title = title;
    this->author = author;
    this->category = category;
    this->section = section;
    this->publisher = publisher;
    this->edition = edition;
    this->language = language;
    this->publicationYear = publicationYear;
    this->pages = pages;
    this->totalCopies = totalCopies;
    this->availableCopies = avaliableCopies;
    updateStatus();
}

string Book::getIsbn() const { return isbn; }
string Book::getTitle() const { return title; }
string Book::getAuthor() const { return author; }
string Book::getCategory() const { return category; }
string Book::getSection() const { return section; }
string Book::getPublisher() const { return publisher; }
string Book::getEdition() const { return edition; }
string Book::getLanguage() const { return language; }
int Book::getPublicationYear() const { return publicationYear; }
int Book::getPages() const { return pages; }
int Book::getTotalCopies() const { return totalCopies; }
int Book::getAvailableCopies() const { return availableCopies; }
BookStatus Book::getStatus() const { return status; }

bool Book::issueOneCopy() {
    if(availableCopies <= 0) throw runtime_error("No copies available.");
    availableCopies--;
    updateStatus();
    return true;
}

void Book::returnOneCopy() {
    if (availableCopies < totalCopies) {
        availableCopies++;
        updateStatus();
    }
}

void Book::updateStatus() {
    if (availableCopies == 0) status = UNAVAILABLE;
    else if (availableCopies <= totalCopies / 2) status = LIMITED;
    else status = AVAILABLE;
}

std::ostream& operator<<(std::ostream& os, const Book& book) {
    std::cout << "ID: " << book.getIsbn() << " Name: " << book.getTitle();
    return os;
}
string Book::statusToString() const {
    switch (status) {
    case AVAILABLE: return "Available";
    case LIMITED: return "Limited";
    case UNAVAILABLE: return "Unavailable";
    default: return "Unknown";
    }
}

// ========= CATALOG IMPLEMENTATION =========

int BookCatalog::bookcount = 0;

bool BookCatalog::addBook(const Book& book) {
    for (const auto& b : books) {
        if (b.getIsbn() == book.getIsbn()) throw runtime_error("ISBN already exists.");
    }
    books.push_back(book);
    bookcount++;
    return true;
}

bool BookCatalog::removeBook(const string& isbn) {
    for (auto it = books.begin(); it != books.end(); ++it) {
        if (it->getIsbn() == isbn) {
            books.erase(it);
            bookcount--;
            return true;
        }
    }
    throw runtime_error("Book not found.");
}

const vector<Book>& BookCatalog::getAllBooks() const { return books; }

Book* BookCatalog::findByIsbn(const string& isbn) {
    for (auto& b : books) {
        if (b.getIsbn() == isbn) return &b;
    }
    return nullptr;
}

// ... (Other search methods searchByTitle, searchByAuthor, etc. follow the same pattern)

// ========= MEMBERSHIP IMPLEMENTATION =========

Membership::Membership(string id, int loandays) {
    if(id.empty() || loandays <= 0) throw invalid_argument("Invalid details.");
    studentId = id;
    loanDurationDays = loandays;
    isActive = true;
    startDate = time(0);
    expiryDate = startDate + YEAR_IN_SECONDS;
}

Membership::~Membership() {}

bool Membership::isExpired() {
    if(time(0) > expiryDate) {
        isActive = false;
        return true;
    }
    return false;
}

void Membership::renewMembership() {
    startDate = time(0);
    expiryDate = startDate + YEAR_IN_SECONDS;
    isActive = true;
}

// Tier-specific constructors
Silver::Silver(string id) : Membership(id, 14) {}
int Silver::getBorrowedLimit() const { return 3; }
double Silver::getFineDiscount() const { return 0.0; }
double Silver::getRenewalFee() const { return 0.0; }
string Silver::getTierName() const { return "Silver"; }

// (Add Gold and Platinum implementations similarly...)
// ========= GOLD IMPLEMENTATION =========

Gold::Gold(string id) : Membership(id, 21) {}

int Gold::getBorrowedLimit() const {return 5;}
double Gold::getFineDiscount() const {return 0.2;}
double Gold::getRenewalFee() const {return 29.0;}
string Gold::getTierName() const {return "Gold";}

// ========= PLATINUM IMPLEMENTATION =========

Platinum::Platinum(string id) : Membership(id, 30) {}
int Platinum::getBorrowedLimit() const {return 7;}
double Platinum::getFineDiscount() const {return 0.5;}
double Platinum::getRenewalFee() const {return 59.0;}
string Platinum::getTierName() const {return "Platinum";}

Membership* createMembership(string tier, string studentId) {
    transform(tier.begin(), tier.end(), tier.begin(), ::tolower);
    if(tier == "silver") return new Silver(studentId);
    if(tier == "gold") return new Gold(studentId);
    if(tier == "platinum") return new Platinum(studentId);
    throw invalid_argument("Invalid tier.");
}

// ========= WALLET IMPLEMENTATION =========

Wallet::Wallet(string id, double initialDeposit) {
    studentId = id;
    balance = initialDeposit;
    suspended = false;
}
Wallet::Wallet(std::string user_id, double Deposit, bool sus){
    studentId = user_id;
    balance = Deposit;
    suspended = sus;
}
string Wallet::getStudentId() const {return studentId;}
void Wallet::addAmount(double amount) {
    balance += amount;
    suspended = (balance < SUSPENSION_THRESHOLD);
}

void Wallet::deductFine(double fineAmount) {
    balance -= fineAmount;
    if (balance < SUSPENSION_THRESHOLD) suspended = true;
}

// ========= WALLET LOG IMPLEMENTATION =========

void WalletLog::createWallet(string studentId, double initialDeposit) {
    wallets.push_back(Wallet(studentId, initialDeposit));
    logs.push_back({studentId, initialDeposit, "initial_deposit", time(0)});
}
void WalletLog::createWallet(string studentId, double initialDeposit, int sus) {
    wallets.push_back(Wallet(studentId, initialDeposit, sus));
    logs.push_back({studentId, initialDeposit, "initial_deposit", time(0)});
}
// void WalletLog::addWallet( Wallet& w, const string& sid, double initialDeposit){
//     wallets.push_back(w);
//     logs.push_back({sid, initialDeposit, "initial_deposit", time(0)});
// }

Wallet* WalletLog::getWallet(string studentId) {
    for (auto& w : wallets) {
        if (w.getStudentId() == studentId) return &w;
    }
    return nullptr;
}
