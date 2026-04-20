import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import LMS

Item {
    width: 1000
    height: 700
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
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#0f172a"

            Membership {
            anchors.fill: parent
            }
        }
    }


}
