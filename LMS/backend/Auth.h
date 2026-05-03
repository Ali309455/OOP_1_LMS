#ifndef AUTH_H
#define AUTH_H

#include <string>
#include<vector>

// ========= ENTITY BASE CLASS =========
class Person {
protected:
    std::string userID;
    std::string name;
    std::string email;
    std::string password;

public:
    Person(const std::string& id, const std::string& nm, const std::string& em, const std::string& pwd);
    virtual ~Person();

    // Pure virtual function
    virtual std::string getRole() const = 0;

    // Getters and Logic
    std::string getUserID() const;
    std::string getName() const;
    std::string getEmail() const;
    bool authenticate(const std::string& tryPass) const;
};

// ========= DERIVED ENTITY CLASSES =========

class Student : public Person {
private:
    std::string department;
    int borrowedCount;
    int totalfineowed;

public:
    Student(const std::string& id, const std::string& nm, const std::string& em, const std::string& pwd);
    
    std::string getRole() const override;
    int getTotalFineOwed() const;
    int get_BorrowedCount() const;
};

class Librarian : public Person {
private:
    std::string employeeCode;

public:
    Librarian(const std::string& id, const std::string& nm, const std::string& em, const std::string& pwd, const std::string& code);
    
    std::string getRole() const override;
};

// ========= SERVICE CLASS (AUTH MANAGER) =========

class AuthManager {
private:
    static int userCount ;
    std::vector<Person*> registeredUsers;

public:
    AuthManager() = default;
    ~AuthManager(); // Destructor to clean up heap memory
    int getuserCount();
    void registerPerson(Person* p);
    Person* login(const std::string& email, const std::string& password) const;
};

#endif // LIBRARY_SYSTEM_H
