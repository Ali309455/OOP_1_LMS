#include "Auth.h"

int AuthManager::totalUsers = 0;

// --- Account Implementation ---
Account::Account(string id, string pass) : userID(id), password(pass), status(AccountStatus::Active) {}

bool Account::validateCredentials(string id, string pass)
{
    return (userID == id && password == pass);
}

// --- Person Implementation ---
Person::Person(string n, string e, string p, string id, string pass)
    : name(n), email(e), phone(p)
{
    account = make_unique<Account>(id, pass);
}

// --- Student & Librarian ---
Student::Student(string n, string e, string p, string id, string pass, MembershipTier t)
    : Person(n, e, p, id, pass), tier(t) {}

Librarian::Librarian(string n, string e, string p, string id, string pass)
    : Person(n, e, p, id, pass) {}

// --- AuthManager (Logic) ---
AuthManager::AuthManager()
{
    // Demo data for testing
    registerUser("Admin", "admin@lib.com", "000", "admin123", "Librarian", "-");
}

bool AuthManager::registerUser(string n, string e, string p, string pass, string role, string tierStr)
{
    try
    {
        if (role == "Librarian")
        {
            users.push_back(make_unique<Librarian>(n, e, p, e, pass));
        }
        else
        {
            MembershipTier t = MembershipTier::Silver;
            if (tierStr == "Gold")
                t = MembershipTier::Gold;
            else if (tierStr == "Platinum")
                t = MembershipTier::Platinum;

            users.push_back(make_unique<Student>(n, e, p, e, pass, t));
        }
        totalUsers++;
        return true;
    }
    catch (...)
    {
        return false;
    }
}

Person *AuthManager::login(string emailOrId, string pass)
{
    for (auto &u : users)
    {
        // Checking both Email and ID (As per your UI requirements)
        if ((u->getEmail() == emailOrId || u->getAccount()->getID() == emailOrId) &&
            u->getAccount()->getPassword() == pass)
        {

            if (u->getAccount()->getStatus() == AccountStatus::Active)
            {
                return u.get();
            }
        }
    }
    return nullptr;
}

// create your branch and based on uml and coedinate with the inddividual who is handling the class requried to make you code (like relations in uml ) and test and run your code by using main function 
// in your class when your code is ready just comment out your driver code(main function) and dummy data used to check the code

// --- YE AAPKA TESTING (DRIVER) CODE HAI ---

#include <iostream>

int main()
{
    AuthManager testSystem;

    // Dummy data register karna (Testing ke liye)
    testSystem.registerUser("Hassan", "hassan@ned.edu", "03001234567", "ned123", "Student", "Gold");

    // Login test karna
    cout << "Testing Login for Hassan..." << endl;
    Person *result = testSystem.login("hassan@ned.edu", "ned123");

    if (result != nullptr)
    {
        cout << "SUCCESS: Login Ho Gaya! Welcome " << result->getName() << endl;
    }
    else
    {
        cout << "FAILED: Login nahi ho saka." << endl;
    }

    return 0;
}