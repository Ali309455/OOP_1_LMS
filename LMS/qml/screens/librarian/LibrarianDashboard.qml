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

    property var transactions: [
        { id: "TXN-1245", student: "John Doe", book: "Clean Code", date: "2026-04-12", status: "active" },
        { id: "TXN-1244", student: "Jane Smith", book: "Design Patterns", date: "2026-04-11", status: "returned" },
        { id: "TXN-1243", student: "Bob Johnson", book: "Refactoring", date: "2026-04-10", status: "overdue" },
        { id: "TXN-1242", student: "Alice Brown", book: "SICP", date: "2026-04-09", status: "active" }
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

            // ───────────────── HEADER ─────────────────
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

            // ───────────────── CHART ─────────────────
            Rectangle {
                width: parent.width
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

            // ───────────────── TABLE (FIXED + DYNAMIC) ─────────────────
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

                    // ───── HEADER ─────
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

                    // ───── ROWS (FULL DYNAMIC HEIGHT FIX) ─────
                    Repeater {
                        model: dashboard.transactions

                        delegate: Row {
                            width: parent.width
                            height: 50

                            // ID
                            Text {
                                width: dashboard.colW[0]
                                text: modelData.id
                                font.bold: true
                                font.pixelSize: 12
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 8
                            }

                            // Student
                            Text {
                                width: dashboard.colW[1]
                                text: modelData.student
                                font.pixelSize: 12
                                verticalAlignment: Text.AlignVCenter
                            }

                            // Book
                            Text {
                                width: dashboard.colW[2]
                                text: modelData.book
                                font.pixelSize: 12
                                verticalAlignment: Text.AlignVCenter
                            }

                            // Date
                            Text {
                                width: dashboard.colW[3]
                                text: modelData.date
                                font.pixelSize: 12
                                color: "#6b7280"
                                verticalAlignment: Text.AlignVCenter
                            }

                            // Status
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
