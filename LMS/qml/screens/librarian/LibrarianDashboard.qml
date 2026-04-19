import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: dashboard
    color: "#0f1117"
    anchors.fill: parent

    signal quickActionClicked(string action)

    // ───────────────── DATA ─────────────────
    property var colW: [140, 160, 190, 120, 120]

    property var statsData: [
        { icon: "qrc:/assets/icons/book.png", value: "2,847", label: "Total Books",         iconColor: '#FF5722' },
        { icon: "qrc:/assets/icons/transaction.png", value: "156",   label: "Active Transactions", iconColor: "#FF5722" },
        { icon: "qrc:/assets/icons/addreview.png", value: "23",    label: "Overdue Books",       iconColor: "#091291" },
        { icon: "qrc:/assets/icons/addreview.png", value: "8",     label: "Pending Reviews",     iconColor: "#091291" }
    ]

    property var transactions: [
        { id: "TXN-1245", student: "John Doe",    book: "Clean Code",      date: "2026-04-12", status: "active"   },
        { id: "TXN-1244", student: "Jane Smith",  book: "Design Patterns", date: "2026-04-11", status: "returned" },
        { id: "TXN-1243", student: "Bob Johnson", book: "Refactoring",     date: "2026-04-10", status: "overdue"  },
        { id: "TXN-1242", student: "Alice Brown", book: "SICP",            date: "2026-04-09", status: "active"   }
    ]

    property var quickActions: [
        { label: "Add Book",       color: "#3b82f6", action: "addBook"       },
        { label: "Issue Book",    color: "#10b981", action: "issueBook"     },
        { label: "Return Book",    color: "#10b981", action: "returnBook"    },
        { label: "Approve Review", color: "#8b5cf6", action: "approveReview" }
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

    // ── Vertical scrollbar ─────────────────────────────────────────────────
    Flickable {
        id: flick
        anchors.fill: parent
        anchors.margins: 24
        anchors.rightMargin: 32
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: column
            width: flick.width
            spacing: 20

            // ── Header ─────────────────────────────────────────────────────
            Column {
                spacing: 6

                Text {
                    text: "Dashboard"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#ffffff"
                }
                Text {
                    text: "Library management overview"
                    font.pixelSize: 13
                    color: "#9ca3af"
                }
            }

            // ── Stat cards ─────────────────────────────────────────────────
            Row {
                width: parent.width
                spacing: 14

                Repeater {
                    model: dashboard.statsData
                    delegate: Rectangle {
                        width: (parent.width - 3 * 14) / 4
                        height: 120
                        radius: 12
                        color: "#1a1f2e"
                        border.color: "#2d3748"
                        border.width: 1

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 10

                            // Icon badge
                            Rectangle {
                                width: 44; height: 44
                                radius: 12
                                color: modelData.iconColor
                                Layout.alignment: Qt.AlignHCenter

                                Image{
                                    anchors.centerIn: parent
                                    height: 30
                                    width: 30
                                    source: modelData.icon
                                    fillMode: Image.PreserveAspectFit
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.value
                                font.pixelSize: 22
                                font.bold: true
                                color: "#ffffff"
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.label
                                font.pixelSize: 11
                                color: "#9ca3af"
                            }
                        }
                    }
                }
            }

            // ── Chart + Quick Actions ──────────────────────────────────────
            Row {
                width: parent.width
                spacing: 16

                // ── Bar Chart ──────────────────────────────────────────────
                Rectangle {
                    width: parent.width * 0.67 - 8
                    height: 270
                    radius: 12
                    color: "#1a1f2e"
                    border.color: "#2d3748"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12

                        Text {
                            text: "Books Issued (Last 6 Months)"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#ffffff"
                        }

                        Item {
                            id: chartCanvas
                            width: parent.width
                            height: 200

                            property real usableH: height - 20

                            // Grid lines
                            Repeater {
                                model: [600, 450, 300, 150]
                                delegate: Rectangle {
                                    x: 0
                                    y: chartCanvas.usableH * (1 - modelData / dashboard.chartMax)
                                    width: chartCanvas.width
                                    height: 1
                                    color: "#2d3748"
                                }
                            }

                            // Y-axis labels
                            Repeater {
                                model: [600, 450, 300, 150, 0]
                                delegate: Text {
                                    x: 0
                                    y: chartCanvas.usableH * (1 - modelData / dashboard.chartMax) - 7
                                    text: modelData
                                    font.pixelSize: 9
                                    color: "#6b7280"
                                }
                            }

                            // Bars
                            Row {
                                anchors {
                                    left: parent.left; leftMargin: 28
                                    right: parent.right
                                    bottom: parent.bottom
                                    bottomMargin: 18
                                }
                                spacing: 10

                                Repeater {
                                    model: dashboard.chartData
                                    delegate: Item {
                                        width: ((chartCanvas.width - 28) / dashboard.chartData.length) - 10
                                        height: chartCanvas.height - 18

                                        Rectangle {
                                            width: parent.width
                                            height: chartCanvas.usableH * modelData.value / dashboard.chartMax
                                            radius: 4
                                            color: "#3b82f6"
                                            anchors.bottom: parent.bottom

                                            Behavior on height {
                                                NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
                                            }
                                        }
                                    }
                                }
                            }

                            // Month labels
                            Row {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left; anchors.leftMargin: 28
                                anchors.right: parent.right
                                spacing: 10

                                Repeater {
                                    model: dashboard.chartData
                                    delegate: Text {
                                        width: ((chartCanvas.width - 28) / dashboard.chartData.length) - 10
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

                // ── Quick Actions ──────────────────────────────────────────
                Rectangle {
                    width: parent.width * 0.33 - 8
                    height: 270
                    radius: 12
                    color: "#1a1f2e"
                    border.color: "#2d3748"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 10

                        Text {
                            text: "Quick Actions"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#ffffff"
                        }

                        Repeater {
                            model: dashboard.quickActions
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: 42
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

            // ── Recent Transactions ────────────────────────────────────────
            Rectangle {
                width: parent.width
                radius: 12
                color: "#1a1f2e"
                border.color: "#2d3748"
                border.width: 1
                implicitHeight: tableColumn.implicitHeight + 48

                Item {
                    anchors.fill: parent
                    anchors.margins: 20

                    Column {
                        id: tableColumn
                        width: parent.width
                        spacing: 0

                        // Section title
                        Text {
                            text: "Recent Transactions"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#ffffff"
                            height: 40
                            verticalAlignment: Text.AlignVCenter
                        }

                        // Table header row
                        Row {
                            width: parent.width
                            height: 36

                            Repeater {
                                model: ["Transaction ID", "Student", "Book", "Date", "Status"]
                                delegate: Rectangle {
                                    width: dashboard.colW[index]
                                    height: parent.height
                                    color: "transparent"

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: 8
                                        text: modelData
                                        font.bold: true
                                        font.pixelSize: 11
                                        color: "#9ca3af"
                                    }
                                }
                            }
                        }

                        // Header divider
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#2d3748"
                        }

                        // Data rows
                        Repeater {
                            model: dashboard.transactions
                            delegate: Column {
                                width: parent.width
                                spacing: 0

                                Row {
                                    width: parent.width
                                    height: 54

                                    // Transaction ID
                                    Text {
                                        width: dashboard.colW[0]
                                        height: parent.height
                                        text: modelData.id
                                        font.bold: true
                                        font.pixelSize: 13
                                        color: "#ffffff"
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 8
                                    }

                                    // Student
                                    Text {
                                        width: dashboard.colW[1]
                                        height: parent.height
                                        text: modelData.student
                                        font.pixelSize: 13
                                        color: "#e5e7eb"
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    // Book
                                    Text {
                                        width: dashboard.colW[2]
                                        height: parent.height
                                        text: modelData.book
                                        font.pixelSize: 13
                                        color: "#e5e7eb"
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    // Date
                                    Text {
                                        width: dashboard.colW[3]
                                        height: parent.height
                                        text: modelData.date
                                        font.pixelSize: 12
                                        color: "#9ca3af"
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    // Status badge
                                    Rectangle {
                                        width: dashboard.colW[4]
                                        height: parent.height
                                        color: "transparent"

                                        Rectangle {
                                            width: 76; height: 26
                                            radius: 13
                                            anchors.verticalCenter: parent.verticalCenter

                                            color: modelData.status === "active"   ? "#052e16"
                                                 : modelData.status === "returned" ? "#1e3a5f"
                                                 : "#3b0f0f"

                                            border.color: modelData.status === "active"   ? "#10b981"
                                                        : modelData.status === "returned" ? "#3b82f6"
                                                        : "#ef4444"
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.status
                                                font.pixelSize: 11
                                                font.bold: true
                                                color: modelData.status === "active"   ? "#10b981"
                                                     : modelData.status === "returned" ? "#3b82f6"
                                                     : "#ef4444"
                                            }
                                        }
                                    }
                                }

                                // Row divider (hidden after last row)
                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    color: "#1e2535"
                                    visible: index < dashboard.transactions.length - 1
                                }
                            }
                        }
                    }
                }
            }

            Item { height: 16 }
        }
    }

    // ── Scrollbar ──────────────────────────────────────────────────────────
    ScrollBar {
        id: vBar
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.top: parent.top; anchors.topMargin: 24
        anchors.bottom: parent.bottom; anchors.bottomMargin: 24
        orientation: Qt.Vertical
        size: flick.visibleArea.heightRatio
        position: flick.visibleArea.yPosition
        width: 6
        policy: ScrollBar.AsNeeded

        onPositionChanged: if (pressed) flick.contentY = position * flick.contentHeight

        contentItem: Rectangle { radius: 3; color: vBar.pressed ? "#9ca3af" : "#374151" }
        background: Rectangle { color: "transparent" }
    }

    Connections {
        target: flick
        function onContentYChanged() {
            if (!vBar.pressed) vBar.position = flick.contentY / flick.contentHeight
        }
    }
}
