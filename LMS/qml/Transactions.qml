import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#0b1220"
    radius: 0

    property color pageBg: "#0b1220"
    property color cardBg: "#171e2f"
    property color borderColor: "#2a3350"
    property color textPrimary: "#ffffff"
    property color textSecondary: "#9aa4bf"
    property color accent: "#6377f2"
    property color green: "#16c47f"
    property color red: "#ff4d5a"
    property color yellow: "#f0b429"

    ListModel {
        id: transactionModel
        ListElement { txnId: "TXN-1245"; student: "John Doe"; studentId: "S001"; book: "Clean Code"; isbn: "978-0132350884"; issueDate: "2026-04-01"; dueDate: "2026-04-15"; returnDate: "-"; fine: "-"; status: "active" }
        ListElement { txnId: "TXN-1244"; student: "Jane Smith"; studentId: "S002"; book: "Design Patterns"; isbn: "978-0201633612"; issueDate: "2026-03-28"; dueDate: "2026-04-11"; returnDate: "2026-04-10"; fine: "-"; status: "returned" }
        ListElement { txnId: "TXN-1243"; student: "Bob Johnson"; studentId: "S003"; book: "Effective Java"; isbn: "978-0134685991"; issueDate: "2026-03-25"; dueDate: "2026-04-08"; returnDate: "-"; fine: "$15"; status: "overdue" }
        ListElement { txnId: "TXN-1242"; student: "John Doe"; studentId: "S001"; book: "The Pragmatic Programmer"; isbn: "978-0137081073"; issueDate: "2026-04-05"; dueDate: "2026-04-19"; returnDate: "-"; fine: "-"; status: "active" }
        ListElement { txnId: "TXN-1241"; student: "Alice Brown"; studentId: "S004"; book: "Introduction to Algorithms"; isbn: "978-0262033848"; issueDate: "2026-03-20"; dueDate: "2026-04-03"; returnDate: "-"; fine: "$30"; status: "overdue" }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        Label {
            text: "Transactions"
            color: root.textPrimary
            font.pixelSize: 28
            font.bold: true
        }

        Label {
            text: "Manage book borrowing and returns (5 transactions)"
            color: root.textSecondary
            font.pixelSize: 14
            Layout.topMargin: -8
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: root.cardBg
            radius: 18
            border.color: root.borderColor
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 22
                spacing: 18

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    Rectangle {
                        Layout.fillWidth: true
                        preferredHeight: 44
                        color: "#1b2338"
                        radius: 12
                        border.color: root.borderColor
                        border.width: 1

                        TextField {
                            anchors.fill: parent
                            anchors.margins: 10
                            placeholderText: "Search by transaction ID, student, or book..."
                            color: root.textPrimary
                            placeholderTextColor: root.textSecondary
                            background: null
                        }
                    }

                    ComboBox {
                        Layout.preferredWidth: 140
                        Layout.preferredHeight: 44
                        model: ["All Status", "active", "returned", "overdue"]
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    Column {
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            width: parent.width
                            height: 44
                            color: "transparent"

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 0

                                Repeater {
                                    model: [
                                        { label: "Transaction ID", w: 160 },
                                        { label: "Student", w: 145 },
                                        { label: "Book", w: 270 },
                                        { label: "Issue Date", w: 135 },
                                        { label: "Due Date", w: 135 },
                                        { label: "Return Date", w: 140 },
                                        { label: "Fine", w: 75 },
                                        { label: "Status", w: 110 }
                                    ]

                                    delegate: Label {
                                        width: modelData.w
                                        text: modelData.label
                                        color: "#9fb0d9"
                                        font.pixelSize: 14
                                        font.bold: true
                                        verticalAlignment: Text.AlignVCenter
                                        height: 44
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: root.borderColor
                        }

                        ListView {
                            width: parent.width
                            height: parent.height - 45
                            model: transactionModel
                            clip: true

                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 74
                                color: status === "overdue" ? "#2a1d28" : "transparent"

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 16
                                    spacing: 0

                                    Column {
                                        width: 160
                                        anchors.verticalCenter: parent.verticalCenter
                                        Label { text: txnId; color: root.textPrimary; font.pixelSize: 14; font.bold: true }
                                    }

                                    Column {
                                        width: 145
                                        anchors.verticalCenter: parent.verticalCenter
                                        Label { text: student; color: root.textPrimary; font.pixelSize: 14; font.bold: true }
                                        Label { text: studentId; color: root.textSecondary; font.pixelSize: 13 }
                                    }

                                    Column {
                                        width: 270
                                        anchors.verticalCenter: parent.verticalCenter
                                        Label { text: book; color: root.textPrimary; font.pixelSize: 14; font.bold: true }
                                        Label { text: isbn; color: root.textSecondary; font.pixelSize: 13 }
                                    }

                                    Label {
                                        width: 135
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: issueDate
                                        color: root.textPrimary
                                        font.pixelSize: 14
                                    }

                                    Label {
                                        width: 135
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: dueDate
                                        color: root.textPrimary
                                        font.pixelSize: 14
                                    }

                                    Label {
                                        width: 140
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: returnDate
                                        color: root.textPrimary
                                        font.pixelSize: 14
                                    }

                                    Label {
                                        width: 75
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: fine
                                        color: status === "overdue" ? root.red : root.textPrimary
                                        font.pixelSize: 14
                                        font.bold: status === "overdue"
                                    }

                                    Rectangle {
                                        width: 110
                                        height: 30
                                        radius: 15
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: status === "active" ? "#1c2d78"
                                              : status === "returned" ? "#123b32"
                                              : "#4a1f2a"

                                        Label {
                                            anchors.centerIn: parent
                                            text: status
                                            color: status === "active" ? "#7ea2ff"
                                                  : status === "returned" ? "#4fe0a5"
                                                  : "#ff6773"
                                            font.pixelSize: 13
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Repeater {
                model: [
                    { value: "2", label: "Total Active", color: "#ffffff" },
                    { value: "2", label: "Overdue", color: "#ff4d5a" },
                    { value: "1", label: "Total Completed", color: "#4fe0a5" }
                ]

                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 98
                    color: root.cardBg
                    radius: 16
                    border.color: root.borderColor
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 8

                        Label {
                            text: modelData.value
                            color: modelData.color
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Label {
                            text: modelData.label
                            color: root.textSecondary
                            font.pixelSize: 14
                        }
                    }
                }
            }
        }
    }
}