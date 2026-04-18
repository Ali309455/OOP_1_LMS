import QtQuick
import QtQuick.Controls
import LMS

Window {
    width: 1536
    height: 864
    visible: true
    title: "LMS"

    Rectangle {
        anchors.fill: parent
        color: "#0b1220"
    }

    // Fake sidebar preview
    Rectangle {
        x: 0
        y: 0
        width: 200
        height: parent.height
        color: "#111827"
    }

    // Fake top bar preview
    Rectangle {
        x: 200
        y: 0
        width: parent.width - 200
        height: 60
        color: "#161c2d"
    }

    // Your actual content area
    Transactions {
        x: 200
        y: 60
        width: parent.width - 200
        height: parent.height - 60
    }
}