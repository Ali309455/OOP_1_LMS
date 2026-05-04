#include "Auth.h"
#include <stdexcept>
#include <iostream>

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
Student::Student(const std::string& id,const std::string& nm,const std::string& em,const std::string& pwd,const std::string& status, const std::string& tier): Person(id, nm, em, pwd),
    borrowedCount(0),
    totalfineowed(0),
    membership(nullptr),
    wallet(nullptr)
{
    // Create membership
    membership = createMembership(tier, id);
    this->status = status;
    // Create wallet (assuming WalletLog is global or accessible)
    // wallet = new Wallet(id, 0.0);   // local object for this student
    // WalletLog::addWallet(wallet, id,0);
    // Also log it (optional, depending on your design)

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
Student::~Student() {
    delete membership;
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

bool AuthManager::updateUser(const std::string& id,const std::string& name,const std::string& email,const std::string& password, const std::string& status)
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
    if(student ) student->setStatus(status);
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

bool AuthManager::upgrademembership(const std::string& tier,const std::string& id){
    Person* p = findById(id);

    if (!p) return false;

    Student* s = dynamic_cast<Student*>(p);

    if (!s) {
        // Not a student (maybe librarian)
        return false;
    }

    s->setmembership(createMembership(tier, id));

    return true;
}
std::vector<Person*> AuthManager::getAllUsers() const {
    return registeredUsers;
}
