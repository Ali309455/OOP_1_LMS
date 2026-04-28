
#ifndef AUTH_H
#define AUTH_H
#include <iostream>
#include <string>
#include <vector>
using namespace std;

class Person {
protected:
    string name, id, password, role;
public:
    Person(string n, string i, string p, string r) : name(n), id(i), password(p), role(r) {}
    virtual ~Person() {}
    virtual void showDashboard() = 0; 
    string getID() { return id; }
    string getPass() { return password; }
    string getRole() { return role; }
};

class Student : public Person {
public:
    Student(string n, string i, string p) : Person(n, i, p, "Student") {}
    void showDashboard() override { cout << "Student Dashboard Loaded."; }
};

class Librarian : public Person {
public:
    Librarian(string n, string i, string p) : Person(n, i, p, "Librarian") {}
    void showDashboard() override { cout << "Librarian Dashboard Loaded."; }
};

class AuthManager {
private:
    static int totalUsers; 
    vector<Person*> users;
public:
    AuthManager();
    ~AuthManager();
    void registerUser(Person* newUser);
    Person* authenticate(string inputID, string inputPass);
    static int getTotalUsersCount();
};
#endif


// create your branch and based on uml and coedinate with the inddividual who is handling the class requried to make you code (like relations in uml ) and test and run your code by using main function 
// in your class when your code is ready just comment out your driver code(main function) and dummy data used to check the code