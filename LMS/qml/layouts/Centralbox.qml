import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import LMS

Item {
    id: centralbox
    width: 1000
    height: 700
    property string route: "dashboard"
    signal routeChangeRequested(string newRoute)
    property bool islibrarian: false
    property var selectedBook : null
    property var currentUser: null
    ColumnLayout{
        anchors.fill: parent
        spacing: 0
        Navbar {
            id: navbar
            Layout.preferredWidth: 800
            height: 56
            clip: true
            userName: "Admin User"
            userRole: "Librarian"
            notificationCount: 3

            onSearchTextChanged: function(text) {
            console.log("Search:", text)
            }

        }
        Rectangle {
            color: "#0f172a"
            Layout.fillWidth: true
            Layout.fillHeight: true


        Loader {
            anchors.fill: parent
            sourceComponent: {
                   console.log("Loading route:", route)

                   if (route === "Reviews") return reviewsComp
                   if (route === "Books") return booksComp
                   if (route === "Transactions") return transactionComp
                   if (route === "Users") return usersComp
                   if (route === "Settings") return settingsComp
                   if (route === "Membership") return membershipComp
                   if (route === "BookDetail") return bookDetailComp
                   return islibrarian? librariandashboardComp: studentdashboardComp
                   // return librariandashboardComp
               }
        }

        Component { id: reviewsComp; Reviews {userRole: centralbox.islibrarian?"librarian":"user" }}
        Component { id: membershipComp; Membership {} }
        Component { id: usersComp; UserManagement {} }
        Component { id: settingsComp; Profile { currentUser: centralbox.currentUser} }
        Component { id: transactionComp; Transactions {isLibrarian: centralbox.islibrarian} }
        Component { id: librariandashboardComp;  LibrarianDashboard {} }
        Component { id: studentdashboardComp;  StudentDashboard {} }
        Component {
            id: booksComp
            BookCatalog {
                isLibrarian: centralbox.islibrarian
                onBookSelected: function(book) {
                            centralbox.selectedBook = book
                            centralbox.routeChangeRequested("BookDetail")
                }
            }
        }
        Component {
            id: bookDetailComp; BookDetail {bookData: centralbox.selectedBook
            onBackRequested: { centralbox.routeChangeRequested("Books") }
            }
        }
        }
    }
}


