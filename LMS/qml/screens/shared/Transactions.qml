import QtQuick
import QtQuick.Controls
import LMS

Item {
    id: root
    anchors.fill: parent

    // Temporary testing switch

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
