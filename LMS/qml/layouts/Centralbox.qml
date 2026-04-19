import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import LMS

Item {
    width: 1000
    height: 700
    ColumnLayout{
        anchors.fill: parent
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
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f9fafb"

            LibrarianDashboard {
            anchors.centerIn: parent
            }
        }
    }


}
