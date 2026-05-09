#include "BookMembership.h"
#include <stdexcept>
#include <algorithm>
#include <iostream>

using namespace std;

const int YEAR_IN_SECONDS = 365 * 24 * 60 * 60;

// ========= BOOK IMPLEMENTATION =========
// Constructor
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
// Getter Functions
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
// Setter Functions
void Book::setTitle(const string& t) { title = t; }
void Book::setAuthor(const string& a) { author = a; }
void Book::setCategory(const string& c) { category = c; }
void Book::setSection(const string& s) { section = s; }
void Book::setPublisher(const string& p) { publisher = p; }
void Book::setEdition(const string& e) { edition = e; }
void Book::setLanguage(const string& l) { language = l; }
void Book::setPublicationYear(int y) { publicationYear = y; }
void Book::setPages(int p) { pages = p; }
void Book::setTotalCopies(int total) {
    int issued = totalCopies - availableCopies;

    if (total < issued)
        throw runtime_error("Cannot reduce total below issued copies.");

    int diff = total - totalCopies;

    totalCopies = total;
    availableCopies += diff;

    if (availableCopies < 0) availableCopies = 0;
    if (availableCopies > totalCopies) availableCopies = totalCopies;

    updateStatus();
}
// Function to issue one copy 
bool Book::issueOneCopy() {
    if(availableCopies <= 0) throw runtime_error("No copies available.");
    availableCopies--;
    updateStatus();
    return true;
}
// Function to return one copy
void Book::returnOneCopy() {
    if (availableCopies < totalCopies) {
        availableCopies++;
        updateStatus();
    }
}
// Update Book availability status
void Book::updateStatus() {
    if (availableCopies == 0) status = UNAVAILABLE;
    else if (availableCopies <= totalCopies / 2) status = LIMITED;
    else status = AVAILABLE;
}

std::ostream& operator<<(std::ostream& os, const Book& book) {
    std::cout << "ID: " << book.getIsbn() << " Name: " << book.getTitle();
    return os;
}
// funtion to convert enum to string
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
// function to add books into catalog
bool BookCatalog::addBook(const Book& book) {
    for (const auto& b : books) {
        if (b.getIsbn() == book.getIsbn()) throw runtime_error("ISBN already exists.");
    }
    books.push_back(book);
    bookcount++;
    return true;
}
// funtion to uodate the total copies in case of restock
bool BookCatalog::updateBook(const string& isbn,int totalCopies){
    for (auto& b : books) {

        if (b.getIsbn() == isbn) {
            b.setTotalCopies(totalCopies);
            return true;
        }
    }

    throw runtime_error("Book not found.");
}
// function to remove book in case of outdated
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
// funtion to get all books in catalog
const vector<Book>& BookCatalog::getAllBooks() const { return books; }
// funtion to find all the books by their ISBN
Book* BookCatalog::findByIsbn(const string& isbn) {
    for (auto& b : books) {
        if (b.getIsbn() == isbn) return &b;
    }
    return nullptr;
}

// ... (Other search methods searchByTitle, searchByAuthor, etc. follow the same pattern)

// ========= MEMBERSHIP IMPLEMENTATION =========
// constructor
Membership::Membership(string id, int loandays) {
    if(id.empty() || loandays <= 0) throw invalid_argument("Invalid details.");
    studentId = id;
    loanDurationDays = loandays;
    isActive = true;
    startDate = time(0);
    expiryDate = startDate + YEAR_IN_SECONDS;
}
// destructor
Membership::~Membership() {}
// function to check the activity status of membership 
bool Membership::isExpired() {
    if(time(0) > expiryDate) {
        isActive = false;
        return true;
    }
    return false;
}
// function to renew current membership for another year
void Membership::renewMembership() {
    startDate = time(0);
    expiryDate = startDate + YEAR_IN_SECONDS;
    isActive = true;
}

// ======== SILVER IMPLEMENTATION =========
Silver::Silver(string id) : Membership(id, 14) {}

int Silver::getBorrowedLimit() const { return 3; }
double Silver::getFineDiscount() const { return 0.0; }
double Silver::getRenewalFee() const { return 0.0; }
string Silver::getTierName() const { return "Silver"; }

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
// Factory function 
Membership* createMembership(string tier, string studentId) {
    transform(tier.begin(), tier.end(), tier.begin(), ::tolower);
    if(tier == "silver") return new Silver(studentId);
    if(tier == "gold") return new Gold(studentId);
    if(tier == "platinum") return new Platinum(studentId);
    throw invalid_argument("Invalid tier.");
}

// Wallet Class
Wallet::Wallet(std::string id,
                   double initialDeposit)
{
    studentId = id;
    balance = initialDeposit;
    suspended = false;
}

Wallet::Wallet(std::string id,
               double deposit,
               bool sus)
{
    studentId = id;
    balance = deposit;
    suspended = sus;
}
// getter functions for wallet class
std::string Wallet::getStudentId() const
{
    return studentId;
}

double Wallet::getBalance() const
{
    return balance;
}

bool Wallet::isSuspended() const
{
    return suspended;
}

void Wallet::suspendWallet()
{
    suspended = true;
}

void Wallet::activateWallet()
{
    suspended = false;
}
// function to add amount to wallet balance
void Wallet::addAmount(double amount)
{
    if (amount <= 0)
    {
        std::cout << "Invalid amount.\n";
        return;
    }

    balance += amount;
}
// function to deduct amount from wallet balance
bool Wallet::deductAmount(double amount)
{
    if (amount <= 0)
    {
        std::cout << "Invalid deduction amount.\n";
        return false;
    }

    if (balance < amount)
    {
        std::cout << "Insufficient balance.\n";
        return false;
    }

    balance -= amount;

    return true;
}
// function to deduct fine from wallet balance and suspend if balance is insufficient
void Wallet::deductFine(double fineAmount)
{
    if (!deductAmount(fineAmount))
    {
        suspended = true;

        std::cout << "Wallet suspended due to unpaid fine.\n";
    }
}

void Wallet::setbalance(double b){
    balance = b;
}
// function to deduct membership renewal fee from wallet balance and suspend if balance is insufficient
void Wallet::deductMembershipRenewalFee(double feeAmount)
{
    if (!deductAmount(feeAmount))
    {
        std::cout << "Unable to pay membership renewal fee.\n";
    }
}

// ======================================================
// WALLET TRANSACTION CLASS
// ======================================================

WalletTransaction::WalletTransaction(std::string sid,
                                     double amt,
                                     std::string t)
{
    studentId = sid;
    amount = amt;
    type = t;
    timestamp = time(nullptr);
}
// getter functions for wallet transaction class
std::string WalletTransaction::getStudentId() const
{
    return studentId;
}

double WalletTransaction::getAmount() const
{
    return amount;
}

std::string WalletTransaction::getType() const
{
    return type;
}

time_t WalletTransaction::getTimestamp() const
{
    return timestamp;
}

// WALLET LOG CLASS
// constructor
void WalletLog::addLog(std::string studentId,
                       double amount,
                       std::string type)
{
    WalletEntry entry;

    entry.studentId = studentId;
    entry.amount = amount;
    entry.type = type;
    entry.timestamp = time(nullptr);

    logs.push_back(entry);
}
// getter functions for wallet log class
std::vector<WalletLog::WalletEntry>
WalletLog::getAllLogs() const
{
    return logs;
}

std::vector<WalletLog::WalletEntry>
WalletLog::getLogsByStudent(std::string studentId) const
{
    std::vector<WalletEntry> result;

    for (const WalletEntry& entry : logs)
    {
        if (entry.studentId == studentId)
        {
            result.push_back(entry);
        }
    }

    return result;
}




