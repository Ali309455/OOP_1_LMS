#include "Auth.h"
#include <stdexcept>
#include <iostream>
#include<qDebug>

// ========= PERSON IMPLEMENTATION =========

Person::Person(const std::string& id, const std::string& nm, const std::string& em, const std::string& pwd)
    : userID(id), name(nm), email(em), password(pwd) {

    if (id.empty() || nm.empty() || em.empty() || pwd.empty()) {
        throw std::invalid_argument("All fields (ID, Name, Email, Password) are required.");
    }
    if (em.find('@') == std::string::npos) {
        throw std::invalid_argument("Invalid email format.");
    }
}

Person::~Person() {}
std::ostream& operator<<(std::ostream& os, const Person& person) {
    std::cout << "ID: " << person.getEmail() << " Name: " << person.getName();
    return os;
}
std::string Person::getUserID() const { return userID; }
std::string Person::getName() const { return name; }
std::string Person::getEmail() const { return email; }
std::string Person::getPassword() const{return password;}

bool Person::authenticate(const std::string& tryPass) const {
    return password == tryPass;
}

// ========= STUDENT IMPLEMENTATION =========

Student::Student(const std::string& id, const std::string& nm, const std::string& em, const std::string& pwd, const std::string& stat, const std::string& tier, double balance)
    : Person(id, nm, em, pwd),
    borrowedCount(0),
    totalfineowed(0),
    status(stat),
    // composition
    studentwallet(id, balance)
{
    // create membership dynamically
    membership = createMembership(tier, id);

    if (!membership) {
        membership = new Silver(id);
    }
}


void Student::setmembership(Membership* m) {
    // delete old membership to avoid memory leak
    delete membership;
    // assign new one
    membership = m;
}
std::string Student::getRole() const {
    return ROLE_STUDENT;
}
std::string Student::getStatus() const {
    return status;
}

void Student::setStatus( const std::string& s){
    status = s;
}

std::string Student::getMembershipTier() const {
    return membership ? membership->getTierName() : "silver";
}
int Student::getTotalFineOwed() const {
    return totalfineowed;
}

int Student::get_BorrowedCount() const {
    return borrowedCount;
}
void Student::paymembershipfee(double amount){
    studentwallet.deductMembershipRenewalFee(amount);
}
Student::~Student() {
    delete membership;
}
// ========= WALLET OPERATIONS =========

void Student::addWalletBalance(double amount) {
    studentwallet.addAmount(amount);
}

void Student::payFine(double amount) {
    studentwallet.deductFine(amount);

    if (totalfineowed >= amount)
        totalfineowed -= amount;
}

double Student::getWalletBalance() const {
    return studentwallet.getBalance();
}
Wallet* Student::getstudentwallet(){
    return &studentwallet;
}

bool Student::isWalletSuspended() const {
    return studentwallet.isSuspended();
}

// ========= LIBRARIAN IMPLEMENTATION =========

Librarian::Librarian(const std::string& id, const std::string& nm, const std::string& em, const std::string& pwd, const std::string& code)
    : Person(id, nm, em, pwd), employeeCode(code) {
    if (code.empty()) {
        throw std::invalid_argument("Employee code cannot be empty.");
    }
}

std::string Librarian::getRole() const {
    return ROLE_LIBRARIAN;
}

// ========= AUTHMANAGER IMPLEMENTATION =========



// AuthManager::~AuthManager() {
//     for (int i = 0; i < userCount; ++i) {
//         delete registeredUsers[i];
//     }
// }

// void AuthManager::registerPerson(Person* p) {
//     if (p == nullptr) {
//         throw std::invalid_argument("Cannot register a null user.");
//     }

//     if (userCount >= MAX_USERS) {
//         delete p; // Clean up memory to prevent leaks
//         throw std::overflow_error("System capacity reached.");
//     }

//     // Check for duplicates
//     for (int i = 0; i < userCount; ++i) {
//         if (registeredUsers[i]->getEmail() == p->getEmail()) {
//             delete p;
//             throw std::runtime_error("User with this email already exists.");
//         }
//     }

//     registeredUsers[userCount++] = p;
// }

// Person* AuthManager::login(const std::string& email, const std::string& password) const {
//     for (int i = 0; i < userCount; ++i) {
//         if (registeredUsers[i]->getEmail() == email) {
//             if (registeredUsers[i]->authenticate(password)) {
//                 return registeredUsers[i];
//             } else {
//                 throw std::runtime_error("Incorrect password.");
//             }
//         }
//     }
//     throw std::runtime_error("User not found.");
// }
\
// ========= AUTH MANAGER IMPLEMENTATION =========

int AuthManager::userCount = 0;

AuthManager::~AuthManager() {
    for (auto user : registeredUsers) {
        delete user; // Prevents memory leaks
    }
}
Person* AuthManager::findById(const std::string id) {
    for (auto* user : registeredUsers) {
        // qDebug()<<(user->getUserID() == id);
        if (user->getUserID() == id) {
            return user;
        }
    }
    return nullptr;
}
void AuthManager::registerPerson(Person* p) {
    if (!p) {
        throw std::invalid_argument("Null user.");
    }

    for (auto user : registeredUsers) {
        if (user->getEmail() == p->getEmail()) {
            delete p; // Clean up the pointer if registration fails
            throw std::runtime_error("User already exists.");
        }
    }

    registeredUsers.push_back(p);
    userCount++;
}

int AuthManager::getuserCount(){return userCount;}
bool AuthManager::addBalance(const std::string& studentId, double amount)
{
    Person* p = findById(studentId);
    if (!p)
        return false;

    Student* s = dynamic_cast<Student*>(p);

    if (!s)
        return false;

    s->addWalletBalance(amount);

    return true;
}
bool AuthManager::deductFine(const std::string& studentId, double fine){
    Person* p = findById(studentId);

    if (!p)
        return false;

    Student* s = dynamic_cast<Student*>(p);

    if (!s)
        return false;

    s->payFine(fine);

    return true;
}
double AuthManager::getStudentBalance(const std::string& studentId)
{
    Person* p = findById(studentId);

    if (!p)
        return -1;

    Student* s = dynamic_cast<Student*>(p);

    if (!s)
        return -1;

    return s->getWalletBalance();
}
bool AuthManager::isWalletSuspended(const std::string& studentId)
{
    Person* p = findById(studentId);

    if (!p)
        return true;

    Student* s = dynamic_cast<Student*>(p);

    if (!s)
        return true;

    return s->isWalletSuspended();
}
bool AuthManager::updateUser(const std::string& id,const std::string& name,const std::string& email,const std::string& password, const std::string& status, double balance)
{
    Person* user = findById(id);

    if (!user) {
        return false;
    }

    if (!name.empty())
        user->setName(name);

    if (!email.empty())
        user->setEmail(email);

    if (!password.empty())
        user->setPassword(password);
    Student* student = dynamic_cast<Student*>(user);
    if(student ){ student->setStatus(status); student->getstudentwallet()->setbalance(balance);};
    return true;
}

Person* AuthManager::login(const std::string& email, const std::string& password) const {
    for (auto user : registeredUsers) {
        if (user->getEmail() == email) {
            if (user->authenticate(password)) {
                return user;
            }
            throw std::runtime_error("Incorrect password.");
        }
    }
    throw std::runtime_error("User not found.");
};

bool AuthManager::upgrademembership(const std::string& tier,
                                    const std::string& id)
{
    Person* p = findById(id);

    if (!p)
        return false;

    Student* s = dynamic_cast<Student*>(p);

    if (!s)
        return false;

    Membership* newMembership = createMembership(tier, id);

    if (!newMembership)
        return false;

    // replace membership
    s->setmembership(newMembership);
    return true;
}


std::vector<Person*> AuthManager::getAllUsers() const {
    return registeredUsers;
}
