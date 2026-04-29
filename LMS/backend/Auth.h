#ifndef AUTH_H
#define AUTH_H

#include <iostream>
#include <string>
#include <vector>
#include <memory>
#include <stdexcept>

using namespace std;

// UML Section: Enums for State Management
enum class AccountStatus
{
  Active,
  Frozen,
  Closed,
  Blacklisted,
  Pending
};
enum class MembershipTier
{
  Silver,
  Gold,
  Platinum,
  None
};

// Composition: Account details separated from Person
class Account
{
private:
  string userID;
  string password;
  AccountStatus status;
  string lastLogin; // Professional touch
public:
  Account(string id, string pass);

  // Getters & Setters
  string getID() const { return userID; }
  string getPassword() const { return password; }
  AccountStatus getStatus() const { return status; }
  void setStatus(AccountStatus s) { status = s; }
  bool validateCredentials(string id, string pass);
};

// Base Class: Person (Abstract-like)
class Person
{
protected:
  string name;
  string email;
  string phone;
  unique_ptr<Account> account; // Modern C++ (Smart Pointers)
public:
  Person(string n, string e, string p, string id, string pass);
  virtual ~Person() = default;

  // UML Methods
  string getName() const { return name; }
  string getEmail() const { return email; }
  Account *getAccount() const { return account.get(); }
  virtual void displayRole() = 0; // Pure virtual for professional structure
};

// Derived: Student (With Membership Logic)
class Student : public Person
{
private:
  MembershipTier tier;
  static const int MAX_BOOKS = 5;

public:
  Student(string n, string e, string p, string id, string pass, MembershipTier t);
  void displayRole() override { cout << "Role: Student (" << (int)tier << ")" << endl; }
  MembershipTier getTier() const { return tier; }
};

// Derived: Librarian
class Librarian : public Person
{
public:
  Librarian(string n, string e, string p, string id, string pass);
  void displayRole() override { cout << "Role: Librarian" << endl; }
};

// Manager: AuthManager (The Bridge)
class AuthManager
{
private:
  static int totalUsers;
  vector<unique_ptr<Person>> users;

public:
  AuthManager();

  // Signup Logic matching your QML
  bool registerUser(string n, string e, string p, string pass, string role, string tier);

  // Login Logic matching your QML Email/ID field
  Person *login(string emailOrId, string pass);

  static int getTotalUsersCount() { return totalUsers; }
};

#endif