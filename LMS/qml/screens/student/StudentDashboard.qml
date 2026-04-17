import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: centralDashboard
    anchors.fill: parent
    color: "#0f172a" // Deep dark background from the screenshot

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        clip: true

        ColumnLayout {
            width: centralDashboard.width - 60 // Accounting for margins
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 30
            spacing: 25

            // --- Header Section ---
            ColumnLayout {
                spacing: 4
                Text {
                    text: "Student Dashboard"
                    color: "white"
                    font.pixelSize: 28
                    font.bold: true
                }
                Text {
                    text: "overview of your library activity"
                    color: "#94a3b8"
                    font.pixelSize: 14
                }
            }

            // --- Stats Cards Row ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                // Card Component Logic
                Repeater {
                    model: ["Borrowed Books", "Due Books", "Total Fine", "Membership"]
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 140
                        color: "#1e293b" // Card color
                        radius: 12
                        border.color: "#334155"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20

                            // Icon Placeholder
                            Rectangle {
                                width: 32; height: 32
                                radius: 6
                                color: "#334155"
                                Text {
                                        anchors.centerIn: parent
                                        text: modelData === "Borrowed Books" ? "📚" :
                                              modelData === "Due Books"      ? "⏰" :
                                              modelData === "Total Fine"     ? "💰" : "💳"
                                    }
                            }

                            Item { Layout.fillHeight: true } // Spacer

                            Text {
                                text: modelData
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
                Layout.preferredHeight: 400 // Adjustable or dynamic
                color: "#1e293b"
                radius: 12
                border.color: "#334155"

                ListView {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    clip: true
                    model: 5 // Empty placeholder items

                    delegate: Rectangle {
                        width: parent.width
                        height: 70
                        color: "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10

                            ColumnLayout {
                                spacing: 4
                                Rectangle { width: 150; height: 18; color: "#334155"; radius: 4
                                Text{
                                    anchors.centerIn: parent
                                    text: "Book Title"
                                    color: "white"
                                    font.pixelSize: 10
                                    }
                                } // Title placeholder
                                Rectangle { width: 100; height: 12; color: "#334155"; radius: 4; opacity: 0.6
                                    Text{
                                        anchors.centerIn: parent
                                        text: "Due Date"
                                        color: "white"
                                        font.pixelSize: 8
                                        }} // Subtitle placeholder
                            }

                            Item { Layout.fillWidth: true } // Spacer

                            // Status Tag Placeholder
                            Rectangle {
                                width: 70; height: 26
                                radius: 13
                                color: "#334155"
                                opacity: 0.4
                                Text{
                                        anchors.centerIn: parent
                                        text: "status"
                                        color: "white"
                                        font.pixelSize: 8
                                    }
                            }
                        }

                        // Separator line
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 1
                            color: "#334155"
                            visible: index < 4
                        }
                    }
                }
            }
        }
    }
}