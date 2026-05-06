#include<iostream>
#include"LibrarySystem.h"
#include<qDebug>
#include <QDate>
#include <QString>
using namespace std;



QString getDate(int addDays = 0)
{
    QDate date = QDate::currentDate().addDays(addDays);
    return date.toString("yyyy-MM-dd");  // DB-friendly format
}

LibrarySystem::LibrarySystem()
{
    // initializeSystem();
}
string LibrarySystem::generateId(const std::string& prefix, int maxIdFromDB) {
    // return prefix + "-" + std::to_string(maxIdFromDB + 1);
    return prefix + "-" + std::to_string(maxIdFromDB + 1);
}
void LibrarySystem::loadUsersIntoSystem()
{
    QVariantList users = Database::getUsers();

    for (auto u : users) {
        try {
            QVariantMap map = u.toMap();

            // Extract values
            std::string id = map["id"].toString().toStdString();
            std::string name = map["name"].toString().toStdString();
            std::string email = map["email"].toString().toStdString();
            std::string password = map["password"].toString().toStdString();
            std::string status = map["status"].toString().toStdString();
            std::string role = map["role"].toString().toStdString();
            std::string membership = map["membership"].toString().toStdString();

            // Check for empty fields using standard logic
            if (id.empty() || name.empty() || email.empty() || password.empty() || role.empty()) {
                // std::invalid_argument is the standard way to flag bad data input
                throw std::invalid_argument("Crucial user data is missing in database record.");
            }

            Person* person = nullptr;

            if ( role == ROLE_STUDENT) {
                if (membership.empty()) {
                    throw std::invalid_argument("Membership field is empty for student: " + name);
                }
                person = new Student(id, name, email, password,status, membership);
            }
            else if (role == ROLE_LIBRARIAN) {
                person = new Librarian(id, name, email, password, "cs211");
            }
            else {
                // std::runtime_error is used for errors found during execution (like unknown roles)
                throw std::runtime_error("Unrecognized role type: " + role);
            }

            if (person) {
                authManager.registerPerson(person);
            }

        } catch (const std::invalid_argument& e) {
            qCritical() << "Data Validation Error:" << e.what();
            // Skip this user and move to the next
            continue;
        } catch (const std::runtime_error& e) {
            qCritical() << "System Runtime Error:" << e.what();
            continue;
        } catch (const std::exception& e) {
            // Catch-all for any other standard exceptions
            qCritical() << "Standard Exception:" << e.what();
            continue;
        }
    }
}

void LibrarySystem::loadBooksIntoSystem()
{
    QVariantList books = Database::getBooks();

    for (const auto& b : books) {
              // qDebug() << b.toMap();
        QVariantMap map = b.toMap();
              try {
                  std::string isbn = map["isbn"].toString().toStdString();
                  std::string title = map["bookname"].toString().toStdString();
                  std::string author = map["author"].toString().toStdString();
                  std::string category = map["genre"].toString().toStdString();
                  std::string section = map["section"].toString().toStdString();
                  std::string publisher = map["publisher"].toString().toStdString();
                  std::string edition = map["edition"].toString().toStdString();
                  std::string language = map["language"].toString().toStdString();

                  int publicationYear = map["publicationyear"].toInt();
                  int pages = map["pages"].toInt();
                  int totalCopies = map["totalcopies"].toInt();
                  int avaliableCopies = map["avaliablecopies"].toInt();

                  // Check if any critical string field is empty
                  if (isbn.empty() || title.empty() || author.empty() || category.empty() ||
                      section.empty() || publisher.empty() || language.empty()) {
                      throw std::runtime_error("One or more required text fields are empty.");
                  }

                  // Optional: Check for invalid numeric values
                  if (publicationYear <= 0 || pages <= 0 || totalCopies < 0) {
                      // qDebug()<< publicationYear<<","<<pages<<","<<totalCopies<<","<<avaliableCopies;
                      throw std::runtime_error("Numeric fields must contain valid positive values.");
                  }
                  // qDebug() <<avaliableCopies;
                  // Create Book object
                  Book book(isbn, title, author, category, section,
                            publisher, edition, language,
                            publicationYear, pages, totalCopies,avaliableCopies);

                  BooksManager.addBook(book);
                  // Proceed with using the book object...

              } catch (const std::exception& e) {
                  // Handle the error (e.g., log it or show a message box to the user)
                  qDebug() << "Error creating book:" << e.what();
                  // If using Qt Widgets: QMessageBox::critical(nullptr, "Error", e.what());
              }
        // Add to catalog
    }
}

void LibrarySystem::loadTransactionsIntoSystem()
{
    QVariantList transactions = Database::getTransactions();

    for (const auto& t : transactions) {
        try {
            QVariantMap map = t.toMap();

            // Extract values
            std::string transactionId = map["txid"].toString().toStdString();
            std::string studentId     = map["user_id"].toString().toStdString();
            std::string username      = map["username"].toString().toStdString();
            std::string isbn          = map["isbn"].toString().toStdString();
            std::string issueDate     = map["issuedate"].toString().toStdString();
            std::string dueDate       = map["duedate"].toString().toStdString();
            std::string returnDate    = map["returnDate"].toString().toStdString();
            std::string status        = map["status"].toString().toStdString();

            // Note: returnDate might be empty if the book hasn't been returned yet,
            // so we usually don't throw an error for that specific field.

            // 1. Check for crucial empty fields
            if (transactionId.empty() || studentId.empty() ||username.empty()|| isbn.empty() ||
                issueDate.empty() || dueDate.empty() || status.empty()) {
                throw std::invalid_argument("Transaction " + transactionId + " is missing required data.");
            }

            int fine = map["fine"].toInt();
            qDebug()<< username;
            // 2. Validate numeric logic (fine shouldn't be negative)
            if (fine < 0) {
                throw std::runtime_error("Invalid fine amount for Transaction ID: " + transactionId);
            }

            // 3. Create object
            transaction tr(transactionId, studentId, username, isbn,
                           issueDate, dueDate, returnDate,
                           status, fine);

            // 4. Add to manager
            TransactionManager.addTransaction(tr);

        } catch (const std::invalid_argument& e) {
            qCritical() << "Transaction Data Error:" << e.what();
            continue; // Skip this transaction
        } catch (const std::runtime_error& e) {
            qCritical() << "Transaction Runtime Error:" << e.what();
            continue;
        } catch (const std::exception& e) {
            qCritical() << "General Exception during transaction load:" << e.what();
            continue;
        }
    }
}

void LibrarySystem::loadReviewsIntoSystem()
{
    QVariantList reviews = Database::getReviews();

    for (const auto& r : reviews) {
        try {
            QVariantMap map = r.toMap();

            // Extract values
            std::string reviewId   = map["reviewid"].toString().toStdString();
            std::string studentId  = map["user_id"].toString().toStdString();
            std::string username   = map["username"].toString().toStdString();
            std::string isbn       = map["isbn"].toString().toStdString();
            std::string bookname   = map["bookname"].toString().toStdString();
            std::string comment    = map["comment"].toString().toStdString();
            std::string status     = map["status"].toString().toStdString();
            std::string reviewDate = map["review_date"].toString().toStdString();
            int rating             = map["rating"].toInt();

            // 1. Check for crucial empty fields
            // Note: comment might be allowed to be empty depending on your rules;
            // if so, remove it from this check.
            if (reviewId.empty() || studentId.empty() || isbn.empty() || status.empty()) {
                throw std::invalid_argument("Required review metadata is missing for ID: " + reviewId);
            }

            // 2. Validate rating range (Standard 1-5 scale check)
            if (rating < 1 || rating > 5) {
                throw std::out_of_range("Rating for review " + reviewId + " must be between 1 and 5.");
            }

            // 3. Create object
            Review review(reviewId, studentId, username, isbn, bookname,
                          rating, comment, status, reviewDate);

            // 4. Add to manager
            ReviewManager.addReview(review);

        } catch (const std::invalid_argument& e) {
            qCritical() << "Data Error:" << e.what();
            continue; // Skip and move to next review
        } catch (const std::out_of_range& e) {
            qCritical() << "Range Error:" << e.what();
            continue;
        } catch (const std::exception& e) {
            qCritical() << "General Exception loading review:" << e.what();
            continue;
        }
    }
}

void LibrarySystem::loadWalletsIntoSystem()
{
    QVariantList wallets = Database::getWallets();

    for (const auto& w : wallets) {
        QVariantMap map = w.toMap();

        std::string id = map["id"].toString().toStdString();
        double balance = map["balance"].toDouble();
        int sus = map["suspended"].toInt();

        // Create Wallet object

        // Add to manager
        WalletsManager.createWallet(id, balance,sus);
    }
}

void LibrarySystem::initializeSystem(){
    loadUsersIntoSystem();
    loadBooksIntoSystem();
    loadTransactionsIntoSystem();
    loadReviewsIntoSystem();
    loadWalletsIntoSystem();
}

// -------------------> Auht <---------------------------

#include <QVariantMap>

QVariantMap LibrarySystem::login(const std::string& email, const std::string& password) {
    QVariantMap result;
    try {
        currentUser = authManager.login(email, password);
        if (!currentUser) {
            result["success"] = false;
            result["message"] = "Invalid email or password";
            return result;
        }

        // Common fields for all
        result["success"]    = true;
        result["userId"]     = QString::fromStdString(currentUser->getUserID());
        result["name"]       = QString::fromStdString(currentUser->getName());
        result["email"]      = QString::fromStdString(currentUser->getEmail());
        result["role"]       = QString::fromStdString(currentUser->getRole());
        result["password"]       = QString::fromStdString(currentUser->getPassword());
        // Dynamic fields for students
        const Student* student = dynamic_cast<const Student*>(currentUser);
        if (student) {
            result["membership"] = QString::fromStdString(student->getMembershipTier());
            result["status"] = QString::fromStdString(student->getStatus());
        } else {
            // For librarians, status/membership might be "N/A" or something meaningful
            result["membership"] = "N/A";
            result["status"] = "N/A";
        }

        return result;

    } catch (const std::exception& ex) {
        result["success"] = false;
        result["message"] = ex.what();
        return result;
    }
}

void LibrarySystem::logout() { currentUser = nullptr; }

// -------------------> transaction <---------------------------

bool LibrarySystem::issueBook(const string& isbn, const string& sid) {
    if (!currentUser || currentUser->getRole() != ROLE_LIBRARIAN){;
        return false;
    }        // permission check HERE
    Book* b = BooksManager.findByIsbn(isbn);
    qDebug() << b<< b->getAvailableCopies();
    if (!b || b->getAvailableCopies() == 0) return false;
    qDebug() <<transactionlog::transactioncount;
    Person* p = authManager.findById(sid);
    if (!p) return false;
    string username = p->getName();
    string txid =  generateId("TX", Database::getMaxIdNumber("transactions", "txid", "TX"));
    bool dbresponse = Database::addTransaction(QString::fromStdString(txid),QString::fromStdString(sid),QString::fromStdString(isbn),"",QString::fromStdString("active"),0);
    return(dbresponse && TransactionManager.issueBook(txid,sid,username,isbn,getDate().toStdString(),getDate(7).toStdString()));
}

bool LibrarySystem::returnBook(const string& txnID) {
    if (!currentUser || currentUser->getRole() != ROLE_LIBRARIAN)
        return false;

    transaction* t = TransactionManager.findTransactionById(txnID);
    if (!t || t->isReturned())
        return false;

    // ✅ Step 1: get current return date
    string returnDate = getDate().toStdString();

    // ✅ Step 2: get student
    Person* p = authManager.findById(t->getStudentId());
    auto* s = dynamic_cast<Student*>(p);
    if (!s) return false;

    // ✅ Step 3: get membership tier (you must implement this getter)
    string tier = s->getMembershipTier();

    // ✅ Step 4: calculate fine correctly
    double fine = FineCalc.calculateFinalFine(
        t->getDueDate(),
        returnDate,
        tier
        );

    // ✅ Step 5: update transaction
    t->markReturned(returnDate, fine);

    // ✅ Step 6: safely update book copies
    Book* b = BooksManager.findByIsbn(t->getIsbn());
    if (!b) return false;
    b->returnOneCopy();

    // ✅ Step 7: update DB
    return Database::updateTransaction(
        QString::fromStdString(t->getTransactionId()),
        "returned",
        fine
        );
}

// -------------------> Book Manager <---------------------------

bool LibrarySystem::addbook(const string& isbn,const string&  title,const string&  author, const string& category,const string&  section, const string& publisher,const string&  edition, const string& language, int publicationYear, int pages,int totalCopies){
    // permission check HERE
    if (!currentUser || currentUser->getRole() != ROLE_LIBRARIAN)
        return false;
    Book book(isbn, title, author, category, section,publisher, edition, language,publicationYear, pages, totalCopies);
    BooksManager.addBook(book);
    return Database::addBook(QString::fromStdString(isbn),QString::fromStdString(title),QString::fromStdString(author),pages,QString::fromStdString(category),QString::fromStdString(section),QString::fromStdString(publisher),QString::fromStdString(edition),QString::fromStdString(language),publicationYear,totalCopies,totalCopies);
}

// bool LibrarySystem::updateBook(const std::string& isbn,const std::string&  title,const std::string&  author, const std::string& category,const std::string&  section, const std::string& publisher,const std::string&  edition, const std::string& language, int publicationYear, int pages,int totalCopies){
//     if (!currentUser || currentUser->getRole() != ROLE_LIBRARIAN)
//         return false;
//     BookManager.upd
// }

bool LibrarySystem::removeBook(const string& isbn){
    if (!currentUser || currentUser->getRole() != ROLE_LIBRARIAN)
        return false;
    BooksManager.removeBook(isbn);
    return Database::deleteBook(QString::fromStdString(isbn));
}


// -------------------> Review <---------------------------


bool LibrarySystem::approveReview(const string& reviewID) {

    qDebug() << "Approve called. User:"
             << (currentUser ? QString::fromStdString(currentUser->getRole()) : "NULL");

    if (!currentUser)
        return false;

    string role = currentUser->getRole();

    if (role != ROLE_LIBRARIAN && role != "LIBRARIAN" && role != "librarian")
        return false;

    ReviewManager.approveReview(reviewID);

    return Database::updateReview(
        QString::fromStdString(reviewID),
        std::nullopt,
        std::nullopt,
        QString::fromStdString("approved")
        );
}

bool LibrarySystem::deleteReview(const string& reviewID){
    if (!currentUser || currentUser->getRole() != ROLE_LIBRARIAN)
        return false;
    ReviewManager.deleteReview(reviewID);
    return Database::deleteReview(QString::fromStdString(reviewID));

}
bool LibrarySystem::submitReview(const string& studentID ,const string& isbn, int rating, const string& comment) {
    if (!currentUser){
        return false;
    }

    string role = currentUser->getRole();
qDebug()<<role;
    if (role != ROLE_STUDENT )
        return false;
    // qDebug()<<"id "<<Database::getMaxIdNumber("reviews", "reviewid", "RV")
    qDebug()<<"here";
    string rid = generateId("RV",Database::getMaxIdNumber("reviews", "reviewid", "RV"));
    string sid = currentUser->getUserID();
    string uname = currentUser->getName();
    Book* b = BooksManager.findByIsbn(isbn);
    string bname = (b ? b->getTitle() : "");
    Review r(rid, sid, uname, isbn, bname, rating, comment,"pending", getDate().toStdString());
    r.display();

    if(ReviewManager.addReview(r)) return  Database::addReview(QString::fromStdString(rid),QString::fromStdString(sid), QString::fromStdString(uname), QString::fromStdString(isbn), QString::fromStdString(bname), rating, QString::fromStdString(comment),QString::fromStdString("pending"));
    else{

        return false;
    }
}

// -------------------> User <---------------------------
RegistrationResult LibrarySystem::registerStudent(const string& name, const string& email, const string& pwd, const string& status, const string& membership, const string& role) {

    RegistrationResult result;
    result.success = false;
    result.userId = "";
    result.message = "";

    // 1. Generate the ID
    string id = generateId("SU", Database::getMaxIdNumber("users", "id", "SU"));

    // 2. Create the Student object (Heap allocation)
    Student* student = new Student(id, name, email, pwd, status, membership);

    // 3. Attempt to save to Database
    // We assign the boolean return value to our struct's success member
    result.success = Database::addUser(
        QString::fromStdString(id),
        QString::fromStdString(name),
        QString::fromStdString(email),
        QString::fromStdString(pwd),
        QString::fromStdString(membership),
        QString::fromStdString(role),
        QString::fromStdString(status)
        );

    // 4. Handle logic based on the boolean result
    if (result.success) {
        // Success: Track in memory and provide ID to the result
        authManager.registerPerson(student);
        result.userId = id;
        result.message = "Student registered successfully.";
    } else {
        // Failure: Cleanup the memory to prevent leaks
        delete student;
        result.message = "Database insertion failed.";
    }

    return result;
}
RegistrationResult LibrarySystem::registerLibrarian(const string& name, const string& email, const string& pwd, const string& role) {
    RegistrationResult result = { false, "", "" };

    string id = generateId("LIB", Database::getMaxIdNumber("users", "id", "LIB"));
    Librarian* librarian = new Librarian(id, name, email, pwd, "none");

    result.success = Database::addUser(
        QString::fromStdString(id),
        QString::fromStdString(name),
        QString::fromStdString(email),
        QString::fromStdString(pwd),
        "",
        QString::fromStdString(role),
        ""
        );

    if (result.success) {
        authManager.registerPerson(librarian);
        result.userId = id;
        result.message = "Librarian registered successfully.";
    } else {
        delete librarian;
        result.message = "Failed to save Librarian to database.";
    }

    return result;
}
RegistrationResult LibrarySystem::registerUser(const string& name, const string& email, const string& pwd, const string& status, const string& membership, const string& role)
{
    // 1. Authorization Check
    // Ensure only an authorized librarian can perform registration
    if (!currentUser || currentUser->getRole() != ROLE_LIBRARIAN) {
        return { false, "", "Unauthorized: Only librarians can register new users." };
    }

    // 2. Basic Validation
    if (name.empty() || email.empty() || pwd.empty() || role.empty()) {
        return { false, "", "Registration failed: Missing required fields." };
    }

    // 3. Routing based on Role
    // This calls your specific logic for Student or Librarian
    if (role == ROLE_STUDENT) {
        return registerStudent(name, email, pwd, status, membership, role);
    }
    else if (role == ROLE_LIBRARIAN) {
        return registerLibrarian(name, email, pwd, role);
    }
    else {
        // Handle unexpected roles
        return { false, "", "Registration failed: Unknown role '" + role + "'." };
    }
}
bool LibrarySystem::removeUser(const string& id){
    if (!currentUser || currentUser->getRole() != ROLE_LIBRARIAN)
        return false;
    return Database::deleteUser(QString::fromStdString(id));
};

bool LibrarySystem::updateStudent(
    const string& id,
    const string& name,
    const string& email,
    const string& pwd,
    const string& status,
    const string& membership,
    const string& role)
{
    Person* p = authManager.findById(id);
    if (!p){ return false;}

    // 🟢 CASE 2: Student
        Student* s = dynamic_cast<Student*>(p);
        if (!s){ return false;}

        string currentMembership = s->getMembershipTier();
        string finalMembership = currentMembership;

        // ✅ Only upgrade if different
        if (membership != currentMembership) {
            authManager.upgrademembership(membership, id);
            finalMembership = membership;
        }

        // ✅ Update basic details
        authManager.updateUser(id, name, email, pwd, status);

        return Database::updateUser(
            QString::fromStdString(id),
            QString::fromStdString(name),
            QString::fromStdString(email),
            QString::fromStdString(pwd),
            QString::fromStdString(finalMembership),
            QString::fromStdString(role),
            QString::fromStdString(status)
            );


    // ❌ Unknown role
    return false;
}
bool LibrarySystem::updateLibrarian( const string& id, const string& name, const string& email, const string& pwd, const string& role){


    authManager.updateUser( id, name,  email, pwd);

    return Database::updateUser(QString::fromStdString(id),QString::fromStdString(name),QString::fromStdString(email),QString::fromStdString(pwd),QString::fromStdString("none"),QString::fromStdString(role));
}
bool LibrarySystem::updateUser( const string& id, const string& name, const string& email, const string& pwd,  const string& membership, const string& role,const string& status)
{

    // Basic validation
    if (id.empty() ||name.empty() || email.empty()  || role.empty()) {
        qDebug() << "Invalid input for user registration";
        return false;
    }
    string password = pwd;
    qDebug()<<password;
    if (password.empty()){
        Person* p = authManager.findById(id);
        if(p){
            password = p->getPassword();
        }
        else{qDebug() << "password fetching failed";}
    }


    // Decide based on role
    if (role == ROLE_STUDENT ) {
        return updateStudent(id,name, email, password,  status , membership, role);
    }
    else if (role == ROLE_LIBRARIAN) {
        return updateLibrarian(id,name, email, password, role);
    }
    else {
        qDebug() << "Unknown user:" << QString::fromStdString(role);
        return false;
    }
}

// -------------------> membership <---------------------------
bool LibrarySystem::upgradeStudentMembership(const string& studentId, const string& newTier){
    authManager.upgrademembership(newTier, studentId);
    Person *p = authManager.findById(studentId);
    Database::updateUser(QString::fromStdString(studentId),QString::fromStdString(p->getName()),QString::fromStdString(p->getEmail()),QString::fromStdString(p->getPassword()),QString::fromStdString(newTier),QString::fromStdString(p->getRole()));
    return Database::updateUser(QString::fromStdString(studentId),QString::fromStdString(p->getName()),QString::fromStdString(p->getEmail()),QString::fromStdString(p->getPassword()),QString::fromStdString(newTier),QString::fromStdString(p->getRole()));;
}

QVariantMap LibrarySystem::getCurrentMembershipDetails() {
    QVariantMap map;

    if (!currentUser) return map;

    Student* s = dynamic_cast<Student*>(currentUser);
    if (!s) return map;

    string tier = s->getMembershipTier();

    Membership* m = createMembership(tier, s->getUserID());

    map["tier"] = QString::fromStdString(tier);
    map["borrowLimit"] = m->getBorrowedLimit();
    map["fineDiscount"] = QString::number(m->getFineDiscount() * 100) + "%";

    // expiry from DB (IMPORTANT)
    QVariantList users = Database::getUsers();
    for (auto u : users) {
        QVariantMap um = u.toMap();
        if (um["id"].toString().toStdString() == s->getUserID()) {
            map["expiry"] = um["expiry_date"].toString();
            break;
        }
    }

    map["active"] = true;

    delete m;
    return map;
}

bool LibrarySystem::renewMembership(const string& studentId) {
    Person* p = authManager.findById(studentId);
    if (!p) return false;

    string tier = p->getRole() == ROLE_STUDENT ?
                      dynamic_cast<Student*>(p)->getMembershipTier() : "";

    return Database::updateUser(
        QString::fromStdString(studentId),
        QString::fromStdString(p->getName()),
        QString::fromStdString(p->getEmail()),
        QString::fromStdString(p->getPassword()),
        QString::fromStdString(tier),
        QString::fromStdString(p->getRole())
        );
}

vector<Book> LibrarySystem::getAllBooks() const {
    // BookCatalog: getAllBooks() returns a const vector<Book>&
    return BooksManager.getAllBooks();
}

vector<Person*> LibrarySystem::getAllUsers() const {
    // If you have an accessor, such as AuthManager::getAllUsers(), use it
    // Otherwise, maintain your own registry in AuthManager (vector/array)
    return authManager.getAllUsers(); // Must exist in AuthManager!
}

vector<transaction> LibrarySystem::getAllTransactions() const {
    // TransactionLog: add a getter for const vector<transaction>&
    return TransactionManager.getAllTransactions(); // Must exist in transactionlog!
}

vector<Review> LibrarySystem::getAllReviews() const {
    // ReviewLog: add getter for const vector<Review>&
    return ReviewManager.getAllReviews(); // Must exist in Reviewlog!
}




void LibrarySystem::displayAllData() const {
    std::cout << "================ LIBRARY SYSTEM REPORT ================\n\n";

    // 1. Print Books
    std::cout << "--- BOOKS ---\n";
    for (const auto& book : getAllBooks()) {
        // Assuming operator<< is overloaded, otherwise: std::cout << book.getTitle() << "\n";
        std::cout << book << "\n";
    }

    // 2. Print Users (Note: these are pointers!)
    std::cout << "\n--- USERS ---\n";
    for (const auto* userPtr : getAllUsers()) {
        if (userPtr) {
            std::cout << *userPtr << "\n"; // Dereference pointer to print object
        }
    }

    // 3. Print Transactions
    std::cout << "\n--- TRANSACTIONS ---\n";
    for (const auto& t : getAllTransactions()) {
        t.display();
    }

    // 4. Print Reviews
    std::cout << "\n--- REVIEWS ---\n";
    for (const auto& r : getAllReviews()) {
         r.display() ;
    }

    std::cout << "\n=======================================================\n";
}
