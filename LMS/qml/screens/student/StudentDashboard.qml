import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: centralDashboard
    property var currentUser: null

    property var dashboardData: ({})
    property var historyData: []
    anchors.fill: parent
    color: "#0f172a"

    Component.onCompleted: {

        if (!currentUser)
            return

        dashboardData =
            lms.getStudentDashboard(currentUser.userId)

        historyData =
            lms.getStudentBorrowHistory(currentUser.userId)

        console.log(historyData.length)
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentCol.implicitHeight + 40
        clip: true

        ColumnLayout {
            id: contentCol
            width: flick.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 30
            spacing: 25

            // --- Header Section ---
            ColumnLayout {
                spacing: 4
                Text { text: "Student Dashboard"; color: "white"; font.pixelSize: 28; font.bold: true }
                Text { text: "overview of your library activity"; color: "#94a3b8"; font.pixelSize: 14 }
            }

            // --- Stats Cards Row ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                Repeater {
                    model: [
                        {
                            name: "Borrowed Books",
                            value: dashboardData.borrowedBooks || 0,
                            img: "qrc:/assets/icons/book-read-fill.svg",
                            col: "#3b82f6"
                        },
                        {
                            name: "Due Books",
                            value: dashboardData.dueBooks || 0,
                            img: "qrc:/assets/icons/time-fill.svg",
                            col: "#f97316"
                        },
                        {
                            name: "Current Balance",
                            value: "$" + (dashboardData.balance || 0),
                            img: "qrc:/assets/icons/currency-fill.svg",
                            col: "#06b6d4"
                        },
                        {
                            name: "Membership",
                            value: dashboardData.membership || "N/A",
                            img: "qrc:/assets/icons/shield-user-fill.svg",
                            col: "#8b5cf6"
                        }
                    ]
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 160
                        color: "#1e293b"
                        radius: 15
                        border.color: "#334155"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20

                            // --- ICON SECTION ---
                            Rectangle {
                                width: 42; height: 42
                                radius: 10
                                color: modelData.col
                                border.color: Qt.rgba(modelData.col, 0.4, 1)
                                border.width: 1

                                Image {
                                    id: rawIcon
                                    anchors.centerIn: parent
                                    width: 28; height: 28
                                    source: modelData.img
                                    fillMode: Image.PreserveAspectFit

                                }
                                // ColorOverlay {
                                //     id: overlay
                                //     anchors.fill: rawIcon
                                //     source: rawIcon
                                //     color: modelData.col
                                //     visible: false
                                // }
                                // OpacityMask {
                                //     anchors.fill: rawIcon
                                //     source: overlay
                                //     maskSource: rawIcon
                                // }
                            }

                            Item { Layout.fillHeight: true }
                            Text {
                                text: modelData.value
                                color: "white"
                                font.pixelSize: 28
                                font.bold: true
                            }
                            Text {
                                text: modelData.name
                                color: "#94a3b8"
                                font.pixelSize: 14
                            }
                        }
                    }
                }
            }
            // --- Recent Activity Section ---
            Text {
                text: "Recent Activity"
                color: "white"
                font.pixelSize: 20
                font.bold: true
                Layout.topMargin: 10
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 400
                color: "#1e293b"
                radius: 12
                border.color: "#334155"

                ListView {
                    id: activityList
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    clip: true
                    model: historyData

                    delegate: Rectangle {
                        width: parent.width
                        height: 70
                        color: "transparent"
                        readonly property color statusTheme: {
                            var s = modelData.status || ""
                            if (s === "DUE" || s === "PENDING") return "#ef4444"
                            if (s === "RETURNED") return "#22c55e"
                            if (s === "ACTIVE") return "#3b82f6"
                            return "#334155"
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10

                            ColumnLayout {
                                spacing: 4
                                Rectangle { width: 150; height: 18; color: "#334155"; radius: 4
                                    Text{ anchors.centerIn: parent; text: modelData.bookName; color: "white"; font.pixelSize: 10 }
                                }
                                Rectangle { width: 100; height: 12; color: "#334155"; radius: 4; opacity: 0.6
                                    Text{ anchors.centerIn: parent; text: modelData.dueDate; color: "white"; font.pixelSize: 8 }
                                }
                            }

                            Item { Layout.fillWidth: true }
                            Rectangle {
                                width: 70; height: 26
                                radius: 13
                                color: modelData.status ? Qt.rgba(statusTheme.r, statusTheme.g, statusTheme.b, 0.2) : "#334155"
                                border.color: modelData.status ? statusTheme : "transparent"
                                border.width: modelData.status ? 1 : 0
                                opacity: modelData.status ? 1.0 : 0.4

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.status || "status"
                                    color: "white"
                                    font.pixelSize: 8
                                }

                            }
                        }
                    }
                    Rectangle {
                        property int  index
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: "#334155"
                        visible: index < activityList.count - 1
                    }
                }
            }
        }
    }
    Rectangle {
        id: scrollTrack
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.top: flick.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 8; anchors.bottomMargin: 8
        width: 6
        radius: 3
        color: "#1e2535"
        visible: flick.contentHeight > flick.height

        // Thumb
        Rectangle {
            id: scrollThumb
            width: parent.width
            radius: 3
            color: thumbMA.pressed ? "#9ca3af" : thumbMA.containsMouse ? "#6b7280" : "#374151"
            Behavior on color { ColorAnimation { duration: 100 } }

            // height and y are two-way bound to the Flickable
            height: Math.max(32, scrollTrack.height * (flick.height / flick.contentHeight))
            y: flick.contentY / flick.contentHeight * scrollTrack.height

            MouseArea {
                id: thumbMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.SizeVerCursor
                preventStealing: true

                property real pressY: 0
                property real pressContentY: 0

                onPressed: {
                    pressY = mouseY
                    pressContentY = flick.contentY
                }

                onPositionChanged: {
                    if (pressed) {
                        var delta = mouseY - pressY
                        var ratio = delta / scrollTrack.height
                        var newY = pressContentY + ratio * flick.contentHeight
                        flick.contentY = Math.max(0, Math.min(newY, flick.contentHeight - flick.height))
                    }
                }
            }
        }

        // Click on track (jump to position)
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var ratio = mouseY / scrollTrack.height
                flick.contentY = Math.max(0, Math.min(ratio * flick.contentHeight, flick.contentHeight - flick.height))
            }
        }
    }


}
