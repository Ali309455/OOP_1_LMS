#include <iostream>
#include <string>
#include <stdexcept> // Required for standard exceptions
#include <vector>

using namespace std;

// ========= ENTITY BASE CLASS =========
class Person {
protected:
    string userID, name, email, password;
public:
    Person(const string& id, const string& nm, const string& em, const string& pwd)
        : userID(id), name(nm), email(em), password(pwd) {
        
        // Validation logic
        if (id.empty() || nm.empty() || em.empty() || pwd.empty()) {
            throw invalid_argument("All fields (ID, Name, Email, Password) are required.");
        }
        if (em.find('@') == string::npos) {
            throw invalid_argument("Invalid email format.");
        }
    }
    virtual ~Person() {}
    virtual string getRole() const = 0;
    string getUserID() const { return userID; }
    string getName() const { return name; }
    string getEmail() const { return email; }
    bool authenticate(const string& tryPass) const { return password == tryPass; }
};

// ========= DERIVED ENTITY CLASSES =========
class Student : public Person {
    string department;
    int borrowedCount = 0;
    int totalfineowed = 0;
public:
    Student(const string& id, const string& nm, const string& em, const string& pwd)
        : Person(id, nm, em, pwd) {}
    
    string getRole() const override { return "STUDENT"; }
    int getTotalFineOwed() const { return totalfineowed; }
    int get_BorrowedCount() const { return borrowedCount; }
};

class Librarian : public Person {
    string employeeCode;
public:
    Librarian(const string& id, const string& nm, const string& em, const string& pwd, const string& code)
        : Person(id, nm, em, pwd), employeeCode(code) {
        if (code.empty()) throw invalid_argument("Employee code cannot be empty.");
    }
    string getRole() const override { return "LIBRARIAN"; }
};

// ========= SERVICE CLASS (AUTH MANAGER) =========
class AuthManager {
    Person* registeredUsers[100]; 
    int userCount;
public:
    AuthManager() : userCount(0) {}
    ~AuthManager() {
        for (int i = 0; i < userCount; ++i)
            delete registeredUsers[i];
    }

    void registerPerson(Person* p) {
        if (p == nullptr) throw invalid_argument("Cannot register a null user.");
        if (userCount >= 100) {
            delete p; // Clean up memory if we can't store it
            throw overflow_error("System capacity reached. Cannot register more users.");
        }
        
        // Check for duplicate emails
        for (int i = 0; i < userCount; ++i) {
            if (registeredUsers[i]->getEmail() == p->getEmail()) {
                delete p;
                throw runtime_error("User with this email already exists.");
            }
        }

        registeredUsers[userCount++] = p;
    }

    Person* login(const string& email, const string& password) const {
        for (int i = 0; i < userCount; ++i) {
            if (registeredUsers[i]->getEmail() == email) {
                if (registeredUsers[i]->authenticate(password)) {
                    return registeredUsers[i];
                } else {
                    throw runtime_error("Incorrect password.");
                }
            }
        }
        throw runtime_error("User not found.");
    }
};

// ========= Demo/Test =========
// int main() {
//     AuthManager auth;

//     try {
//         // Successful registrations
//         auth.registerPerson(new Librarian("lib1", "Meena", "meena@uni.edu", "libpass", "EMP001"));
//         auth.registerPerson(new Student("stu1", "Alex", "alex@x.com", "abc"));

//         // Trigger an error: Invalid Email
//         // auth.registerPerson(new Student("stu2", "Sandy", "bad-email", "qwe")); 

//         // Login attempts
//         Person* p = auth.login("meena@uni.edu", "libpass");
//         cout << "Login successful: " << p->getName() << " (" << p->getRole() << ")\n";

//         // Trigger an error: Wrong Password
//         p = auth.login("alex@x.com", "wrong-pass");

//     } catch (const exception& e) {
//         cerr << "ERROR: " << e.what() << endl;
//     }

//     return 0;
// }