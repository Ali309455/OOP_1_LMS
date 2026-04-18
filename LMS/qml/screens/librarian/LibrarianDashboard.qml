import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: dashboard
    anchors.fill: parent
    color: "#f8f9fa"

    signal quickActionClicked(string action)

    // ───────────────── DATA ─────────────────
    property var colW: [140, 160, 190, 120, 120]

    property var statsData: [
        { icon: "📖", value: "2,847", label: "Total Books",         iconColor: "#3b82f6" },
        { icon: "📋", value: "156",   label: "Active Transactions", iconColor: "#8b5cf6" },
        { icon: "⏰", value: "23",    label: "Overdue Books",       iconColor: "#f59e0b" },
        { icon: "💬", value: "8",     label: "Pending Reviews",     iconColor: "#8b5cf6" }
    ]

    property var transactions: [
        { id: "TXN-1245", student: "John Doe", book: "Clean Code", date: "2026-04-12", status: "active" },
        { id: "TXN-1244", student: "Jane Smith", book: "Design Patterns", date: "2026-04-11", status: "returned" },
        { id: "TXN-1243", student: "Bob Johnson", book: "Refactoring", date: "2026-04-10", status: "overdue" },
        { id: "TXN-1242", student: "Alice Brown", book: "SICP", date: "2026-04-09", status: "active" }
    ]
    property var quickActions: [
        { label: "+ Add Book",       color: "#3b82f6", action: "addBook"       },
        { label: "📖 Issue Book",    color: "#10b981", action: "issueBook"     },
        { label: "↩ Return Book",    color: "#10b981", action: "returnBook"    },
        { label: "✓ Approve Review", color: "#8b5cf6", action: "approveReview" }
    ]
    property var chartData: [
        { month: "Jan", value: 180 },
        { month: "Feb", value: 210 },
        { month: "Mar", value: 260 },
        { month: "Apr", value: 320 },
        { month: "May", value: 370 },
        { month: "Jun", value: 340 }
    ]

    property int chartMax: 600

    Flickable {
        id: flick
        anchors.fill: parent
        anchors.margins: 24
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true

        Column {
            id: column
            width: flick.width
            spacing: 20

            // ───────── HEADER ─────────
            Column {
                Text {
                    text: "Dashboard"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#111827"
                }

                Text {
                    text: "Library management overview"
                    font.pixelSize: 13
                    color: "#6b7280"
                }
            }

            Row{
                width: parent.width
                spacing: 14

                Repeater {
                    model: dashboard.statsData
                    delegate: Rectangle {
                        width: 170
                        height: 130                  // taller card
                        radius: 12
                        color: "#ffffff"
                        border.color: "#e5e7eb"
                        border.width: 1

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 10              // more breathing room

                            // Icon badge
                            Rectangle {
                                width: 44; height: 44
                                radius: 12
                                color: modelData.iconColor + "18"
                                Layout.alignment: Qt.AlignHCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.icon
                                    font.pixelSize: 20
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.value
                                font.pixelSize: 22
                                font.bold: true
                                color: "#111827"
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.label
                                font.pixelSize: 11
                                color: "#6b7280"
                            }
                        }
                    }
                }
            }

            // ───────── CHART + QUICK ACTIONS ─────────
            Row {
                width: parent.width
                spacing: 20

                // ───── CHART ─────
                Rectangle {
                    width: parent.width * 0.7
                    height: 260
                    radius: 12
                    color: "#ffffff"
                    border.color: "#e5e7eb"

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 10

                        Text {
                            text: "Books Issued (Last 6 Months)"
                            font.bold: true
                        }

                        Item {
                            id: chartCanvas
                            width: parent.width
                            height: 200

                            property real usableH: height - 20

                            Row {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                    bottomMargin: 18
                                }

                                spacing: 10

                                Repeater {
                                    model: dashboard.chartData

                                    delegate: Item {
                                        width: (chartCanvas.width / dashboard.chartData.length) - 10
                                        height: chartCanvas.height

                                        Rectangle {
                                            width: parent.width
                                            height: chartCanvas.usableH * modelData.value / dashboard.chartMax
                                            radius: 4
                                            color: "#3b82f6"
                                            anchors.bottom: parent.bottom
                                        }
                                    }
                                }
                            }

                            Row {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                spacing: 10

                                Repeater {
                                    model: dashboard.chartData

                                    delegate: Text {
                                        width: (chartCanvas.width / dashboard.chartData.length) - 10
                                        text: modelData.month
                                        font.pixelSize: 10
                                        color: "#9ca3af"
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }
                    }
                }

                // ───── QUICK ACTIONS ─────
                Rectangle {
                    width: parent.width * 0.3

                    height: 250
                    radius: 12
                    color: "#ffffff"
                    border.color: "#e5e7eb"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 10

                        Text {
                            text: "Quick Actions"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#111827"
                        }

                        Repeater {
                            model: dashboard.quickActions
                            delegate: Rectangle {
                                Layout.preferredWidth: 150
                                height: 40
                                radius: 8
                                color: btnMA.containsPress ? Qt.darker(modelData.color, 1.15)
                                     : btnMA.containsMouse ? Qt.lighter(modelData.color, 1.06)
                                     : modelData.color
                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                MouseArea {
                                    id: btnMA
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: dashboard.quickActionClicked(modelData.action)
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }
                }
            }


            // ───────── RECENT TRANSACTIONS (UNCHANGED) ─────────
            Rectangle {
                width: parent.width
                radius: 12
                color: "#ffffff"
                border.color: "#e5e7eb"
                implicitHeight: tableColumn.implicitHeight + 60

                Item {
                    anchors.fill: parent
                    anchors.margins: 16

                    Column {
                        id: tableColumn
                        width: parent.width
                        spacing: 0

                        Text {
                            text: "Recent Transactions"
                            font.pixelSize: 20
                            font.bold: true
                            color: "#111827"
                            height: 30
                        }

                        Row {
                            width: parent.width
                            height: 36

                            Repeater {
                                model: ["ID", "Student", "Book", "Date", "Status"]

                                delegate: Rectangle {
                                    width: dashboard.colW[index]
                                    height: parent.height

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: 8
                                        text: modelData
                                        font.bold: true
                                        font.pixelSize: 12
                                        color: "#6b7280"
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#e5e7eb"
                        }

                        Repeater {
                            model: dashboard.transactions

                            delegate: Row {
                                width: parent.width
                                height: 50

                                Text {
                                    width: dashboard.colW[0]
                                    text: modelData.id
                                    font.bold: true
                                    font.pixelSize: 12
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 8
                                }

                                Text {
                                    width: dashboard.colW[1]
                                    text: modelData.student
                                    font.pixelSize: 12
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Text {
                                    width: dashboard.colW[2]
                                    text: modelData.book
                                    font.pixelSize: 12
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Text {
                                    width: dashboard.colW[3]
                                    text: modelData.date
                                    font.pixelSize: 12
                                    color: "#6b7280"
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Rectangle {
                                    width: dashboard.colW[4]
                                    height: parent.height
                                    color: "transparent"

                                    Rectangle {
                                        width: 72
                                        height: 22
                                        radius: 11
                                        anchors.verticalCenter: parent.verticalCenter

                                        color: modelData.status === "active" ? "#dcfce7"
                                             : modelData.status === "returned" ? "#dbeafe"
                                             : "#fee2e2"

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.status
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item { height: 20 }
        }
    }
}
