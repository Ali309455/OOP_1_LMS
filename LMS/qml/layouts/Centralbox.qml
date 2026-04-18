import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import LMS

Item {
    anchors.fill: parent
    ColumnLayout{
        anchors.fill: parent
        Navbar {
            id: navbar
            Layout.fillWidth: true
            height: 56

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

            UserManagement {
            anchors.centerIn: parent
            }
        }
    }


}
