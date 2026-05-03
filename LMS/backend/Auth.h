#ifndef AUTH_H
#define AUTH_H

#include <string>
#include<vector>
#include"BookMembership.h"
const std::string ROLE_LIBRARIAN = "LIBRARIAN";
const std::string ROLE_STUDENT   = "STUDENT";
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
    friend std::ostream& operator<<(std::ostream& os, const Person& person);
    std::string getUserID() const;
    std::string getName() const;
    std::string getEmail() const;
    std::string getPassword() const;
    void setName(const std::string& n){name = n;};
    void setEmail(const std::string& e){email = e;};
    void setPassword(const std::string& p){password = p;}
    bool authenticate(const std::string& tryPass) const;
};

// ========= DERIVED ENTITY CLASSES =========

class Student : public Person {
private:
    std::string department;
    int borrowedCount;
    int totalfineowed;
    Membership* membership;
    Wallet* wallet;

public:
    Student(const std::string& id, const std::string& nm, const std::string& em, const std::string& pwd,const std::string& tier);
    ~Student();
    void setmembership(Membership* m);
    std::string getMembershipTier() const;
    std::string getRole() const override;
    int getTotalFineOwed() const;
    int get_BorrowedCount() const;
    void setmembership(Membership& m );
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
    Person* findById(const std::string id);
    std::vector<Person*> getAllUsers() const;
    void registerPerson(Person* p);
    bool upgrademembership(const std::string& tier, const std::string& id);
    bool updateUser(const std::string& id,const std::string& name, const std::string& email, const std::string& password);
    Person* login(const std::string& email, const std::string& password) const;
};

#endif // LIBRARY_SYSTEM_H
