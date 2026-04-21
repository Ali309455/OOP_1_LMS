import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import LMS

Item {
    width: 1000
    height: 700
    property string route: "dashboard"
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

        //     Transactions {
        //     anchors.fill: parent
        //     }
        // }


        Loader {
            anchors.fill: parent
            sourceComponent: {
                   console.log("Loading route:", route)

                   if (route === "Reviews") return reviewsComp
                   if (route === "Books") return booksComp
                   if (route === "Transactions") return transactionComp
                   if (route === "Users") return usersComp
                   if (route === "Settings") return settingsComp
                   return dashboardComp
               }
        }

        Component { id: reviewsComp; Reviews {} }
        Component { id: usersComp; UserManagement {} }
        Component { id: settingsComp; Profile {} }
        Component { id: transactionComp; Transactions {} }
        Component { id: booksComp; BookCatalog {} }
        Component { id: dashboardComp; LibrarianDashboard {} }
        }
    }
}


