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

std::string Person::getUserID() const { return userID; }
std::string Person::getName() const { return name; }
std::string Person::getEmail() const { return email; }

bool Person::authenticate(const std::string& tryPass) const {
    return password == tryPass;
}

// ========= STUDENT IMPLEMENTATION =========

Student::Student(const std::string& id, const std::string& nm, const std::string& em, const std::string& pwd)
    : Person(id, nm, em, pwd), borrowedCount(0), totalfineowed(0) {}

std::string Student::getRole() const {
    return "STUDENT";
}

int Student::getTotalFineOwed() const {
    return totalfineowed;
}

int Student::get_BorrowedCount() const {
    return borrowedCount;
}

// ========= LIBRARIAN IMPLEMENTATION =========

Librarian::Librarian(const std::string& id, const std::string& nm, const std::string& em, const std::string& pwd, const std::string& code)
    : Person(id, nm, em, pwd), employeeCode(code) {
    if (code.empty()) {
        throw std::invalid_argument("Employee code cannot be empty.");
    }
}

std::string Librarian::getRole() const {
    return "LIBRARIAN";
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
