import QtQuick
import QtQuick.Controls
import LMS

Item {
    id: root
    anchors.fill: parent
    property var currentUser: null
    // User based switch

    property bool isLibrarian: false;

    Loader {
        anchors.fill: parent
        sourceComponent: root.isLibrarian ? adminView : studentView
    }
    // Admin
    Component {
        id: adminView
        TransactionsAdmin {
            anchors.fill: parent
            currentUser : root.currentUser
        }
    }
    // Student
    Component {
        id: studentView
        TransactionsStudent {
            anchors.fill: parent
            currentUser : root.currentUser
        }
    }
}
