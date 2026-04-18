import QtQuick
import QtQuick.Controls
import LMS

Item {
    id: root
    anchors.fill: parent

    // Temporary testing switch
    // Later this value should come from C++ backend after login
    property bool isLibrarian: true

    Loader {
        anchors.fill: parent
        sourceComponent: root.isLibrarian ? adminView : studentView
    }

    Component {
        id: adminView
        TransactionsAdmin {
            anchors.fill: parent
        }
    }

    Component {
        id: studentView
        TransactionsStudent {
            anchors.fill: parent
        }
    }
}