
// #ifndef AUTH_H
// #define AUTH_H
// #include <iostream>
// #include <string>
// #include <vector>
// using namespace std;

// class Person {
// protected:
//     string name, id, password, role;
// public:
//     Person(string n, string i, string p, string r) : name(n), id(i), password(p), role(r) {}
//     virtual ~Person() {}
//     virtual void showDashboard() = 0;
//     string getID() { return id; }
//     string getPass() { return password; }
//     string getRole() { return role; }
// };

// class Student : public Person {
// public:
//     Student(string n, string i, string p) : Person(n, i, p, "Student") {}
//     void showDashboard() override { cout << "Student Dashboard Loaded."; }
// };

// class Librarian : public Person {
// public:
//     Librarian(string n, string i, string p) : Person(n, i, p, "Librarian") {}
//     void showDashboard() override { cout << "Librarian Dashboard Loaded."; }
// };

// class AuthManager {
// private:
//     static int totalUsers;
//     vector<Person*> users;
// public:
//     AuthManager();
//     ~AuthManager();
//     void registerUser(Person* newUser);
//     Person* authenticate(string inputID, string inputPass);
//     static int getTotalUsersCount();
// };
// #endif
// #include <iostream>
// #include <string>
// #include <memory>
// #include "database.h" // your project-specific database interface
// using namespace std;
// // ========== PERSON (Abstract Base) ==========
// class Person {
// protected:
//     string userID;
//     string name;
//     string passwordHash; // You should use actual hash in real life
//     string email;

// public:
//     Person(const string& id, const string& nm, const string& em, const string& pwd)
//         : userID(id), name(nm), email(em) {
//         // Here, in real code, hash the password
//         passwordHash = pwd; // For demo, store as is
//     }

//     virtual ~Person() { }
//     //getter
//     string getUserID() const { return userID; }
//     string getName() const { return name; }
//     string getEmail() const { return email; }

//     // Auth with DB dependency


//     // Abstract (pure virtual) methods
//     virtual string getRole() const = 0;
// };

// // ========== LIBRARIAN ==========
// class Librarian : public Person {
//     int employeeCode;
//     string department;
//     // BookCatalog

// public:
//     Librarian(const string& id, const string& nm, const string& em,
//               const string& pwd, int empCode, const string& dept)
//         : Person(id, nm, em, pwd), employeeCode(empCode), department(dept) {}

//     string getRole() const override {
//         return "LIBRARIAN";
//     }
//     //
//     // Demo: Add book by interacting with database
//     // add book fromm book catalog
//     // You can expand with other methods per UML...

// };

// ========== STUDENT ==========
// class Student : public Person {
//     string department;
//     int semester;
//     int borrowedCount;
//     double totalFineOwed;

//     // For simplicity assume Membership is a string tier for now,
//     // but you should replace with pointer to Membership* polymorphic class, as per your UML.
//     string membership; // e.g., "Silver", "Gold", "Platinum"// class hogi

// public:
//     Student(const string& id, const string& nm, const string& em, const string& pwd,
//             const string& dept, int sem, string tier)
//         : Person(id, nm, em, pwd), department(dept), semester(sem),
//         borrowedCount(0), totalFineOwed(0.0), membership(tier) {}

//     string getRole() const override {
//         return "STUDENT";
//     }


//     int getBorrowLimit(Database& db) { // membership class getter will be called
//         // In your project this should be dynamic from Membership*
//         if (membership == "Platinum") return 10;
//         if (membership == "Gold")     return 6;
//         return 3; // Silver
//     }

    // book catalog search book by id and all

    // void serialize(ostream& out) const override {
    //     out << "Student: " << userID << ',' << name << ',' << email << ',' << department
    //         << ',' << semester << ',' << borrowedCount << ',' << totalFineOwed
    //         << ',' << membership << '\n';
    // }
// };

// ========== Example Usage ==========

// int main() {
//     // You must implement your own Database derived from an interface for this to work.
//     // Here we use a dummy stub of "Database" for concept demonstration.
//     // Database db;

//     Librarian lib("lib1", "Meena", "meena@univ.edu", "pass123", 456, "Science");
//     Student stu("st01", "Alex", "alex@student.edu", "abc123", "Engineering", 2, "Silver");

//     // "Login" with database (you'll use real logic here)
//     string username, password;
//     cout << "Username: ";
//     cin >> username;
//     cout << "Password: ";
//     cin >> password;

//     Person* user = nullptr;

//     // Show appropriate dashboard:


//     // Serialize (save) example:


//     return 0;
// }




#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <memory>

using namespace std;

// ===========================
// == ENTITY CLASSES       ==
// ===========================

class Book {
    string isbn, title, author, genre, section;
    int totalCopies, availableCopies;
public:
    Book(const string& i, const string& t, const string& a,
         const string& g, const string& s, int n)
        : isbn(i), title(t), author(a), genre(g), section(s), totalCopies(n), availableCopies(n) {}
    string getISBN() const { return isbn; }
    int getAvailableCopies() const { return availableCopies; }
    bool issueOneCopy() { if (availableCopies > 0) { --availableCopies; return true; } return false; }
    void returnOneCopy() { if (availableCopies < totalCopies) ++availableCopies; }
};

class Transaction {
    string transactionID, studentID, isbn;
    bool isReturned;
public:
    Transaction(const string& tid, const string& sid, const string& bookisbn)
        : transactionID(tid), studentID(sid), isbn(bookisbn), isReturned(false) {}
    void markReturned() { isReturned = true; }
    bool getIsReturned() const { return isReturned; }
    string getStudentID() const { return studentID; }
    string getISBN() const { return isbn; }
};

class Review {
    string reviewID, studentID, isbn, comment;
    int rating;
    bool isApproved;
public:
    Review(const string& rid, const string& sid, const string& book, int rate, const string& comm)
        : reviewID(rid), studentID(sid), isbn(book), rating(rate), comment(comm), isApproved(false) {}
    void approve() { isApproved = true; }
    bool getIsApproved() const { return isApproved; }
    string getReviewID() const { return reviewID; }
};

// ===========================
// == SERVICE CLASSES      ==
// ===========================

class BookCatalog {
    map<string, Book> books;
public:
    void addBook(const Book& b) { books.insert(make_pair(b.getISBN(), b)); }
    bool issueBook(const string& isbn) {
        map<string, Book>::iterator it = books.find(isbn);
        return (it != books.end()) ? it->second.issueOneCopy() : false;
    }
    void returnBook(const string& isbn) {
        map<string, Book>::iterator it = books.find(isbn);
        if (it != books.end()) it->second.returnOneCopy();
    }
    bool bookExists(const string& isbn) const { return books.count(isbn) > 0; }
    void listBooks() const {
        for (map<string, Book>::const_iterator it = books.begin(); it != books.end(); ++it) {
            cout << "ISBN: " << it->first << ", Copies: " << it->second.getAvailableCopies() << endl;
        }
    }
};

class TransactionLog {
    vector<Transaction> records;
public:
    void addTransaction(const Transaction& t) { records.push_back(t); }
    Transaction* findActive(const string& sid, const string& isbn) {
        for (size_t i = 0; i < records.size(); ++i)
            if (records[i].getStudentID() == sid && records[i].getISBN() == isbn && !records[i].getIsReturned())
                return &records[i];
        return NULL;
    }
};

class ReviewLog {
    vector<Review> reviews;
public:
    void addReview(const Review& r) { reviews.push_back(r); }
    Review* findReview(const string& reviewID) {
        for (size_t i = 0; i < reviews.size(); ++i)
            if (reviewID == reviews[i].getReviewID()) return &reviews[i];
        return NULL;
    }
    bool approveReview(const string& reviewID) {
        Review* r = findReview(reviewID);
        if (r) { r->approve(); return true; }
        return false;
    }
};

// ===========================
// == MOCK DATABASE (DEMO) ==
// ===========================
class Database {
    // Simulate user storage: email -> password
    map<string, string> creds;
public:
    bool registerUser(const string& email, const string& password) {
        if (creds.count(email)) return false;
        creds[email] = password;
        return true;
    }
    bool authenticate(const string& email, const string& password) const {
        map<string, string>::const_iterator it = creds.find(email);
        return (it != creds.end() && it->second == password);
    }
};

// ===========================
// == AUTH MANAGER         ==
// ===========================

class Person {
protected:
    string userID, name, email, password;
public:
    Person(const string& id, const string& nm, const string& em, const string& pwd)
        : userID(id), name(nm), email(em), password(pwd) {}
    virtual ~Person() {}
    virtual string getRole() const = 0;
    string getpass() { return password; }
    const string& getEmail() const { return email; }
    const string& getUserID() const { return userID; }
};

class Student : public Person {
public:
    Student(const string& id, const string& nm, const string& em, const string& pwd)
        : Person(id, nm, em, pwd) {}
    string getRole() const { return "STUDENT"; }
};

class Librarian : public Person {
public:
    Librarian(const string& id, const string& nm, const string& em, const string& pwd)
        : Person(id, nm, em, pwd) {}
    string getRole() const { return "LIBRARIAN"; }

    // Accepts references---UML "no ownership/dependency"
    bool issueBook(BookCatalog& cat, TransactionLog& tlog, const string& isbn, const string& studentID) {
        if (!cat.bookExists(isbn)) { cout << "Book not found\n"; return false; }
        if (cat.issueBook(isbn)) {
            tlog.addTransaction(Transaction(studentID + "-" + isbn, studentID, isbn));
            cout << "Book issued.\n"; return true;
        }
        cout << "No copies left.\n"; return false;
    }

    bool returnBook(BookCatalog& cat, TransactionLog& tlog, const string& isbn, const string& studentID) {
        Transaction* t = tlog.findActive(studentID, isbn);
        if (!t) { cout << "No active transaction.\n"; return false; }
        t->markReturned();
        cat.returnBook(isbn);
        cout << "Book returned.\n";
        return true;
    }

    void addStudent(class AuthManager& auth, Database& db, const string& id,
                    const string& nm, const string& em, const string& pwd);

    bool approveReview(ReviewLog& rlog, const string& reviewID) {
        if (rlog.approveReview(reviewID)) { cout << "Review approved.\n"; return true; }
        cout << "Review not found.\n"; return false;
    }
};

class AuthManager {
    Database& db;
    // People storage: email -> shared_ptr<Person>
    map<string, shared_ptr<Person> > users;
    string loggedInEmail;

public:
    AuthManager(Database& db_) : db(db_), loggedInEmail("") {}

    // Only students are registered by users; librarians are provisioned directly (see below)
    bool registerStudent(const string& id, const string& name,
                         const string& email, const string& password)
    {
        if (users.count(email)) { cout << "User already registered.\n"; return false; }
        bool dbok = db.registerUser(email, password);
        if (!dbok) { cout << "DB register failed.\n"; return false; }
        users[email] = shared_ptr<Person>(new Student(id, name, email, password));
        cout << "Student registered.\n";
        return true;
    }

    void addLibrarian(shared_ptr<Librarian> lib) {
        users[lib->getEmail()] = lib;
        db.registerUser(lib->getEmail(), lib->getpass()); // also add to DB
    }

    // Returns logged in user shared_ptr, or nullptr
    shared_ptr<Person> login(const string& email, const string& password) {
        if (!db.authenticate(email, password)) { cout << "Auth failed.\n"; return shared_ptr<Person>(); }
        map<string, shared_ptr<Person> >::iterator it = users.find(email);
        if (it == users.end()) { cout << "User not found.\n"; return shared_ptr<Person>(); }
        loggedInEmail = email;
        cout << "Login success: " << it->second->getRole() << endl;
        return it->second;
    }
    void logout() {
        loggedInEmail = "";
        cout << "Logged out.\n";
    }
    shared_ptr<Person> currentUser() {
        if (loggedInEmail.empty()) return shared_ptr<Person>();
        return users[loggedInEmail];
    }
    // Utility—for test/demo
    shared_ptr<Student> findStudentByEmail(const string& email) {
        if (!users.count(email)) return shared_ptr<Student>();
        if (users[email]->getRole() != "STUDENT") return shared_ptr<Student>();
        return dynamic_pointer_cast<Student>(users[email]);
    }
};

void Librarian::addStudent(AuthManager& auth, Database& db, const string& id,
                           const string& nm, const string& em, const string& pwd) {
    auth.registerStudent(id, nm, em, pwd);
}

// ================ MAIN DEMO ================
int main() {
    Database db;

    // Librarian: provisioned directly (not through registration)
    shared_ptr<Librarian> librarian(new Librarian("lib1", "Meena", "meena@uni.edu", "libpass"));

    // Auth management and user registration
    AuthManager auth(db);
    auth.addLibrarian(librarian); // Add initial librarian

    // Students via librarian
    librarian->addStudent(auth, db, "stu1", "Alex", "alex@x.com", "abc");
    librarian->addStudent(auth, db, "stu2", "Sandy", "san@x.com", "qwe");

    // Catalog and logs (business objects)
    BookCatalog catalog;
    TransactionLog tlog;
    ReviewLog rlog;

    catalog.addBook(Book("111", "Clean Code", "Martin", "CS", "Reference", 3));

    // Login as librarian
    shared_ptr<Person> user = auth.login("meena@uni.edu", "libpass");
    if (user && user->getRole() == "LIBRARIAN") {
        shared_ptr<Librarian> libPtr = dynamic_pointer_cast<Librarian>(user);
        libPtr->issueBook(catalog, tlog, "111", "stu1");
        libPtr->returnBook(catalog, tlog, "111", "stu1");
    }
    auth.logout();

    // Login as student
    user = auth.login("alex@x.com", "abc");
    if (user && user->getRole() == "STUDENT") {
        Review r("stu1-111", "stu1", "111", 5, "Excellent!");
        rlog.addReview(r);
        cout << "Review submitted by student.\n";
    }
    auth.logout();

    // Librarian approves the review
    user = auth.login("meena@uni.edu", "libpass");
    if (user && user->getRole() == "LIBRARIAN") {
        shared_ptr<Librarian> libPtr = dynamic_pointer_cast<Librarian>(user);
        libPtr->approveReview(rlog, "stu1-111");
    }
    // Done!
    return 0;
}

// // create your branch and based on uml and coedinate with the inddividual who is handling the class requried to make you code (like relations in uml ) and test and run your code by using main function
// // in your class when your code is ready just comment out your driver code(main function) and dummy data used to check the code
