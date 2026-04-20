import QtQuick
import QtQuick.Controls
import LMS

Window {
    width: 1024
    height: 800
    visible: true
    title: "LMS"

    Rectangle {
        anchors.fill: parent
        color: "#0b1220"
    }

    //  sidebar preview
    Rectangle {
        x: 0
        y: 0
        width: 200
        height: parent.height
        color: "#111827"
    }

    // top bar preview
    Rectangle {
        x: 200
        y: 0
        width: parent.width - 200
        height: 60
        color: "#161c2d"
    }

    // content area

    // BookDetail {
    //     x: 200
    //     y: 60
    //     width: parent.width - 200
    //     height: parent.height - 60
    // }

    Transactions {
        x: 200
        y: 60
        width: parent.width - 200
        height: parent.height - 60
    }

}

