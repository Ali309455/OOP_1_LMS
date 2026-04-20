import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import LMS

Item {
    id: centralBoxRoot

    ColumnLayout{
        anchors.fill: parent
        spacing: 0
        Navbar {
            id: navbar
            Layout.fillWidth: true
            Layout.preferredHeight: 56

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
            color: "#0f172a"

            StudentDashboard {
            anchors.fill: parent
            }
        }
    }


}
