#include <iostream>
#include <string>
using namespace std;

// ========= ENTITY BASE CLASS =========
class Person {
protected:
    string userID, name, email, password;
public:
    Person(const string& id, const string& nm, const string& em, const string& pwd)
        : userID(id), name(nm), email(em), password(pwd) { }
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
    int borrowedCount, totalfineowed;
    // Membership* membership
    // add student-specific fields here, e.g. department, semester, membership, etc (see UML)
public:
    Student(const string& id, const string& nm, const string& em, const string& pwd)
        : Person(id, nm, em, pwd) {}
    string getRole() const { return "STUDENT"; }
    int getTotalFineOwed(){return totalfineowed;}
    int get_BorrowedCount(){return borrowedCount;}
    // Membership get_Membership(){return membership;}
    // Methods on LMS entities should ONLY deal with their own state
};

class Librarian : public Person {
    string employeecode;
    // add librarian-specific fields here, e.g. employeeID, dept (see UML)
public:
    Librarian(const string& id, const string& nm, const string& em, const string& pwd)
        : Person(id, nm, em, pwd) {}
    string getRole() const { return "LIBRARIAN"; }
    // Methods on LMS entities should ONLY deal with their own state
};

// ========= SERVICE CLASS (AUTH MANAGER) =========
// Manages all registered users (students, librarians) and authentication
class AuthManager {
    int maxattempts;

    // In a real project, store unique_ptr or make the manager own the objects,
    // here just use pointers for demo simplicity.
    // In production code, use smart pointers for memory safety.
    Person* registeredUsers[100]; // Use vector<Person*> for scalable design
    int userCount;
public:
    AuthManager() : userCount(0), maxattempts(3) {}
    ~AuthManager() {
        for (int i = 0; i < userCount; ++i)
            delete registeredUsers[i];
    }
    bool registerPerson(Person* p) {
        if (userCount >= 100) return false;
        // Check unique email, for demo just ignore
        registeredUsers[userCount++] = p;
        return true;
    }
    Person* login(const string& email, const string& password) const {
        for (int i = 0; i < userCount; ++i) {
            if (registeredUsers[i]->getEmail() == email &&
                registeredUsers[i]->authenticate(password))
                return registeredUsers[i];
        }
        return NULL;
    }
    // Add find by role, etc. as needed.
};

// ========= Demo/Test =========
int main() {
    AuthManager auth;
    // Register librarian
    auth.registerPerson(new Librarian("lib1", "Meena", "meena@uni.edu", "libpass"));
    // Register students
    auth.registerPerson(new Student("stu1", "Alex", "alex@x.com", "abc"));
    auth.registerPerson(new Student("stu2", "Sandy", "san@x.com", "qwe"));

    // Login as librarian
    Person* p = auth.login("meena@uni.edu", "libpass");
    if (p && p->getRole() == "LIBRARIAN")
        cout << "[Librarian] Welcome " << p->getName() << endl;
    else
        cout << "Librarian login failed\n";

    // Login as student
    p = auth.login("alex@x.com", "abc");
    if (p && p->getRole() == "STUDENT")
        cout << "[Student] Welcome " << p->getName() << endl;
    else
        cout << "Student login failed\n";
}
