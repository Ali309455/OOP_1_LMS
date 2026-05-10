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
    // Get User ID, Name, Email, Password
    std::string getUserID() const;
    std::string getName() const;
    std::string getEmail() const;
    std::string getPassword() const;
    // Set Name, Email, Password
    void setName(const std::string& n){name = n;};
    void setEmail(const std::string& e){email = e;};
    void setPassword(const std::string& p){password = p;}
    // Authentication
    bool authenticate(const std::string& tryPass) const;
};

// ========= DERIVED ENTITY CLASSES =========

class Student : public Person {
private:
    int borrowedCount;
    int totalfineowed;
    std::string status;
    Membership* membership;  // add
    Wallet studentwallet;

public:
    // Constructor with membership tier and initial wallet balance
    Student(const std::string& id, const std::string& nm, const std::string& em, const std::string& pwd,const std::string& status,const std::string& tier,double balance);
    // Destructor to clean up heap memory
    ~Student();
    // Getter Setter Functions & Methods of Student Class
    void setmembership(Membership* m);
    std::string getMembershipTier() const;
    std::string getRole() const override;
    std::string getStatus() const;
    Wallet* getstudentwallet();
    void setStatus(const std::string& s);
    int getTotalFineOwed() const;
    int get_BorrowedCount() const;
    void addWalletBalance(double amount);
    void payFine(double amount);
    void paymembershipfee(double amount);
    double getWalletBalance() const;
    bool isWalletSuspended() const;

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
    // getter setter and other methods
    int getuserCount();
    Person* findById(const std::string id);
    std::vector<Person*> getAllUsers() const;
    void registerPerson(Person* p);
    bool removeUser(const std::string& id);
    bool upgrademembership(const std::string& tier, const std::string& id);
    Person* login(const std::string& email, const std::string& password) const;
    bool updateUser(const std::string& id,const std::string& name, const std::string& email, const std::string& password, const std::string& status="", double b=0);
    bool addBalance(const std::string& studentId, double amount);
    bool deductFine(const std::string& studentId, double fine);
    double getStudentBalance(const std::string& studentId);
    bool isWalletSuspended(const std::string& studentId);
};

#endif // LIBRARY_SYSTEM_H
