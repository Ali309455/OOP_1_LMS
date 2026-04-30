#include<iostream>
#include<string>
#include<stdexcept>
#include<ctime>
#include<algorithm>
#include<vector>
using namespace std;

enum BookStatus { AVAILABLE, LIMITED , UNAVAILABLE };

const int YEAR_IN_SECONDS = 365 * 24 * 60 * 60;

class Book{
private:
    string isbn, title, author, category, section, publisher, edition, language;
    int totalCopies, availableCopies, publicationYear, pages;
    BookStatus status;

public:
    // Constructor 
    Book(string isbn, string title, string author, string category, string section, string publisher="", string edition="", string language="", int publicationYear=0, int pages=0, int totalCopies){
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
        this->availableCopies = totalCopies;
        updateStatus();
    }
    // Getters
    string getIsbn() const { return isbn; }
    string getTitle() const { return title; }
    string getAuthor() const { return author; }
    string getCategory() const { return category; }
    string getSection() const { return section; }
    string getPublisher() const { return publisher; }
    string getEdition() const { return edition; }
    string getLanguage() const { return language; }
    int getPublicationYear() const { return publicationYear; }
    int getPages() const { return pages; }
    int getTotalCopies() const { return totalCopies; }
    int getAvailableCopies() const { return availableCopies; }
    BookStatus getStatus() const { return status; }

    bool issueOneCopy() {
        if(availableCopies <=0){
            throw runtime_error("No copies available to issue.");
        }
            availableCopies--;
            updateStatus();
            return true;
    }

    void returnOneCopy() {
        if (availableCopies < totalCopies) {
            availableCopies++;
            updateStatus();
        }
    }
    void updateStatus() {
        if (availableCopies == 0) {
            status = UNAVAILABLE;
        } else if (availableCopies <= totalCopies / 2) {
            status = LIMITED;
        } else {
            status = AVAILABLE;
        }
    }

    string statusToString() const {
        switch (status) {
            case AVAILABLE: return "Available";
            case LIMITED: return "Limited";
            case UNAVAILABLE: return "Unavailable";
            default: return "Unknown";
        }
    }

    // string serialize() const {
    //     return isbn + "|" + title + "|" + author + "|" + category + "|" + section + "|" + to_string(totalCopies) + "|" + to_string(availableCopies);
    // }
    // static Book deserialize(string data) {
    //     string fields[7];
    //     int index=0;
    //     string temp = "";

    //     for (char c : data)
    //     {
    //         if (c == '|') {
    //             if(index < 7) {
    //                 fields[index++] = temp;
    //             }
    //             temp = "";
    //         } else {
    //             temp += c;
    //         }
    //     }
    //     if(index !=6) {
    //         throw invalid_argument("Invalid data format for deserialization.");
    //     }
    //     fields[6] = temp; // last field
        
    //     if(fields[5].empty() || fields[0].empty() || fields[1].empty() || fields[2].empty() || fields[3].empty() || fields[4].empty() || fields[6].empty()) {
    //         throw invalid_argument("Corrupted data: All fields must be present.");
    //     }

    //     Book book(fields[0], fields[1], fields[2], fields[3], fields[4], stoi(fields[5]));
    //     book.availableCopies = stoi(fields[6]);
    //     if(book.availableCopies > book.totalCopies) book.availableCopies = book.totalCopies; // Ensure available copies do not exceed total
    //     book.updateStatus();
    //     if(book.availableCopies < 0) book.availableCopies = 0; // Ensure available copies do not go negative
    //     book.updateStatus();
    //     return book;
    //     }
};

class BookCatalog{
private:
    vector<Book> books;
public:
    bool addBook(const Book& book) {
        for (const auto& b : books) {
            if (b.getIsbn() == book.getIsbn()) {
                throw runtime_error("Book with this ISBN already exists in the catalog.");
                return false;
            }
        }
        books.push_back(book);
        return true;
    }
    bool removeBook(const string& isbn) {
        for (auto it = books.begin(); it != books.end(); ++it) {
            if (it->getIsbn() == isbn) {
                books.erase(it);
                return true;
            }
        }
        throw runtime_error("Book with this ISBN not found in the catalog.");
        return false;
    }
    // Get/Display all books from the catalog
    const vector<Book>& getAllBooks() const {
        return books;
    }
    // Find/Search a book by its ISBN, title, author, category, or section
    const Book* findByIsbn(const string& isbn) const {
        for (const auto& b : books) {
            if (b.getIsbn() == isbn) {
                return &b;
            }
        }
        return nullptr; // Not found
    }
    vector<Book> searchByTitle(const string& title) const {
        vector<Book> results;
        for (const auto& b : books) {
            if (b.getTitle().find(title) != string::npos) {
                results.push_back(b);
            }
        }
        return results;
    }
    vector<Book> searchByAuthor(const string& author) const {
        vector<Book> results;
        for (const auto& b : books) {
            if (b.getAuthor().find(author) != string::npos) {
                results.push_back(b);
            }
        }
        return results;
    }
    vector<Book> searchByCategory(const string& category) const {
        vector<Book> results;
        for (const auto& b : books) {
            if (b.getCategory().find(category) != string::npos) {
                results.push_back(b);
            }
        }
        return results;
    }
    vector<Book> searchBySection(const string& section) const {
        vector<Book> results;
        for (const auto& b : books) {
            if (b.getSection()==section) {
                results.push_back(b);
            }
        }
        return results;
    }
};

class Membership{
    protected:
    string studentId;
    int loanDurationDays;
    bool isActive;
    time_t startDate, expiryDate;

    public:
    // Constructor
    Membership(string id, int loandays){
        if(id.empty() || loandays <= 0) {
            throw invalid_argument("Invalid membership details provided.");
        }
        studentId = id;
        loanDurationDays = loandays;
        isActive = true;
        startDate = time(0); // current time
        expiryDate = startDate + YEAR_IN_SECONDS; //1 year validity
    }
    // Pure virtual Getter functions
    virtual string getTierName() const = 0; 
    virtual int getBorrowedLimit() const = 0; 
    virtual double getFineDiscount() const = 0;
    virtual double getRenewalFee() const = 0; 
    // Rest of the Getter functions
    int getLoanDuration() const {
        return loanDurationDays;
    }
    string getStudentId() const {
        return studentId;
    }
    time_t getExpiryDate() const{
        return expiryDate;
    }
    time_t getStartDate() const{
        return startDate;
    }

    bool getStatus() const{ 
        return isActive;
    }
    bool isExpired(){
        time_t currentTime = time(0);
        if(currentTime > expiryDate){
            isActive = false; // mark as inactive if expired
            return true;
        }
        return false;
    }

    void renewMembership(){
        startDate = time(0); // reset start date to current time
        expiryDate = startDate + YEAR_IN_SECONDS;
        isActive = true;
    }

    virtual ~Membership(){} // virtual destructor
};

class Silver : public Membership{
    public:
    Silver(string id) : Membership(id, 14) {} // Constructor delegation
    // Overriding pure virtual functions
    int getBorrowedLimit() const override {
        return 3;
    }
    double getFineDiscount() const override {
        return 0.0;
    }
    double getRenewalFee() const override {
        return 0.0;
    }
    string getTierName() const override {
        return "Silver";
    }
};

class Gold : public Membership{
    public:
    Gold(string id) : Membership(id, 21) {} // Constructor delegation
    // Overriding pure virtual functions
    int getBorrowedLimit() const override {
        return 5;
    }
    double getFineDiscount() const override {
        return 0.2;
    }
    double getRenewalFee() const override {
        return 29.0;
    }
    string getTierName() const override {
        return "Gold";
    }
};

class Platinum : public Membership{
    public:
    Platinum(string id) : Membership(id, 30) {} // Constructor delegation
    // Overriding pure virtual functions
    int getBorrowedLimit() const override {
        return 7;
    }
    double getFineDiscount() const override {
        return 0.5;
    }
    double getRenewalFee() const override {
        return 59.0;
    }
    string getTierName() const override {
        return "Platinum";
    }
};
// Factory function to create Membership objects based on tier
Membership* createMembership(string tier, string studentId){
    transform(tier.begin(), tier.end(), tier.begin(), ::tolower); // convert to lowercase for case-insensitive comparison
    if(tier == "silver"){
        return new Silver(studentId);
    } else if(tier == "gold"){
        return new Gold(studentId);
    } else if(tier == "platinum"){
        return new Platinum(studentId);
    } else {
        throw invalid_argument("Invalid membership tier.");
    }
}



// create your branch and based on uml and coedinate with the inddividual who is handling the class requried to make you code (like relations in uml ) and test and run your code by using main function 
// in your class when your code is ready just comment out your driver code(main function) and dummy data used to check the code
