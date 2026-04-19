import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#0b1220"

    property string bookTitle: "Clean Code: A Handbook of Agile Software Craftsmanship"
    property string subtitleText: "A Handbook of Agile Software Craftsmanship"
    property string authorName: "Robert C. Martin"
    property string contributorsText: "Michael C. Feathers, Timothy R. Ottinger"
    property string ratingText: "4.6"
    property string reviewsCountText: "5 reviews"

    property string tag1: "Clean Code"
    property string tag2: "Best Practices"
    property string tag3: "Software Craftsmanship"
    property string tag4: "Refactoring"
    property string tag5: "Code Quality"

    property string publisherText: "Prentice Hall"
    property string yearText: "2008"
    property string pagesText: "464"
    property string editionText: "1st Edition"
    property string languageText: "English"
    property string genreText: "Software Engineering"

    property string totalCopiesText: "5"
    property string availableCopiesText: "3"
    property string borrowedCopiesText: "2"
    property string totalBorrowsText: "127"

    property string roomText: "Main Hall"
    property string floorText: "2nd Floor"
    property string sectionText: "CS-A"
    property string shelfText: "A-12"

    property string isbnText: "978-0132350884"

    property color pageBg: "#0b1220"
    property color cardBg: "#171e2f"
    property color softCardBg: "#1b2338"
    property color borderColor: "#2a3350"
    property color textPrimary: "#ffffff"
    property color textSecondary: "#9aa4bf"
    property color accent: "#6377f2"
    property color green: "#16c47f"
    property color chipBg: "#2a3248"

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight + 48
        clip: true
        contentY: 0

        Column {
            id: contentColumn
            width: parent.width
            spacing: 20
            anchors.top: parent.top
            anchors.topMargin: 12

            Item {
                width: parent.width
                height: 44

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Label {
                        text: "\u2190"
                        color: root.textSecondary
                        font.pixelSize: 22
                    }

                    Label {
                        text: "Back to Catalog"
                        color: root.textSecondary
                        font.pixelSize: 16
                        font.bold: true
                    }
                }
            }

            Row {
                width: parent.width - 250
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20

                Column {
                    width: 760
                    spacing: 28

                    Rectangle {
                        width: parent.width
                        height: 640
                        color: root.cardBg
                        radius: 18
                        border.color: root.borderColor
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 24
                            spacing: 22

                            Row {
                                spacing: 24

                                Rectangle {
                                    width: 190
                                    height: 255
                                    radius: 16
                                    color: "#d9dcf8"

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 14

                                        Label {
                                            text: "\ud83d\udcd6"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            font.pixelSize: 52
                                        }

                                        Label {
                                            text: "No Cover Image"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            color: "#6f7485"
                                            font.pixelSize: 16
                                        }
                                    }
                                }

                                Column {
                                    width: 500
                                    spacing: 12

                                    Label {
                                        width: parent.width
                                        text: root.bookTitle
                                        color: root.textPrimary
                                        wrapMode: Text.WordWrap
                                        font.pixelSize: 22
                                        font.bold: true
                                    }

                                    Label {
                                        width: parent.width
                                        text: root.subtitleText
                                        color: root.textSecondary
                                        wrapMode: Text.WordWrap
                                        font.pixelSize: 15
                                    }

                                    Label {
                                        text: root.authorName
                                        color: root.textPrimary
                                        font.pixelSize: 17
                                    }

                                    Label {
                                        width: parent.width
                                        text: "Contributors: " + root.contributorsText
                                        color: root.textSecondary
                                        wrapMode: Text.WordWrap
                                        font.pixelSize: 14
                                    }

                                    Row {
                                        spacing: 8

                                        Label {
                                            text: "\u2605\u2605\u2605\u2605\u2605"
                                            color: "#f0b429"
                                            font.pixelSize: 18
                                        }

                                        Label {
                                            text: root.ratingText + " (" + root.reviewsCountText + ")"
                                            color: root.textPrimary
                                            font.pixelSize: 16
                                        }
                                    }

                                    Flow {
                                        width: parent.width
                                        spacing: 10

                                        Repeater {
                                            model: [root.tag1, root.tag2, root.tag3, root.tag4, root.tag5]

                                            delegate: Rectangle {
                                                radius: 14
                                                color: root.chipBg
                                                height: 32
                                                width: chipText.implicitWidth + 22

                                                Label {
                                                    id: chipText
                                                    anchors.centerIn: parent
                                                    text: modelData
                                                    color: root.textPrimary
                                                    font.pixelSize: 13
                                                }
                                            }
                                        }
                                    }

                                    GridLayout {
                                        width: parent.width
                                        columns: 2
                                        columnSpacing: 28
                                        rowSpacing: 14

                                        Label {
                                            text: "Publisher: " + root.publisherText
                                            color: root.textSecondary
                                            font.pixelSize: 15
                                        }

                                        Label {
                                            text: "Year: " + root.yearText
                                            color: root.textSecondary
                                            font.pixelSize: 15
                                        }

                                        Label {
                                            text: "Pages: " + root.pagesText
                                            color: root.textSecondary
                                            font.pixelSize: 15
                                        }

                                        Label {
                                            text: "Edition: " + root.editionText
                                            color: root.textSecondary
                                            font.pixelSize: 15
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 86
                                radius: 14
                                color: root.softCardBg

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    spacing: 60

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 4
                                        Label { text: "Availability"; color: root.textSecondary; font.pixelSize: 14 }
                                        Label {
                                            text: root.availableCopiesText + " of " + root.totalCopiesText + " Available"
                                            color: root.green
                                            font.pixelSize: 16
                                            font.bold: true
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 4
                                        Label { text: "Currently Borrowed"; color: root.textSecondary; font.pixelSize: 14 }
                                        Label {
                                            text: root.borrowedCopiesText + " copies"
                                            color: root.textPrimary
                                            font.pixelSize: 16
                                            font.bold: true
                                        }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 4
                                        Label { text: "Total Borrows"; color: root.textSecondary; font.pixelSize: 14 }
                                        Label {
                                            text: root.totalBorrowsText + " times"
                                            color: root.textPrimary
                                            font.pixelSize: 16
                                            font.bold: true
                                        }
                                    }
                                }
                            }

                            Column {
                                width: parent.width
                                spacing: 14

                                Row {
                                    spacing: 24

                                    Label {
                                        text: "Overview"
                                        color: root.accent
                                        font.pixelSize: 17
                                        font.bold: true
                                    }

                                    Label {
                                        text: "Reviews (5)"
                                        color: root.textSecondary
                                        font.pixelSize: 17
                                    }
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    color: root.borderColor
                                }

                                Rectangle {
                                    width: parent.width
                                    color: "transparent"
                                    implicitHeight: overviewText.implicitHeight + 8

                                    Label {
                                        id: overviewText
                                        width: parent.width
                                        text: "This book focuses on writing clean, maintainable, and efficient software. It discusses coding principles, refactoring practices, naming conventions, readability, testing habits, and long-term craftsmanship in professional software development."
                                        color: root.textSecondary
                                        wrapMode: Text.WordWrap
                                        font.pixelSize: 14
                                        lineHeight: 1.3
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 190
                        color: root.cardBg
                        radius: 18
                        border.color: root.borderColor
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 22
                            spacing: 14

                            Label {
                                text: "Review Summary"
                                color: root.textPrimary
                                font.pixelSize: 18
                                font.bold: true
                            }

                            Row {
                                spacing: 40

                                Column {
                                    spacing: 6
                                    Label {
                                        text: root.ratingText
                                        color: "#f0b429"
                                        font.pixelSize: 28
                                        font.bold: true
                                    }
                                    Label {
                                        text: root.reviewsCountText
                                        color: root.textSecondary
                                        font.pixelSize: 14
                                    }
                                }

                                Column {
                                    spacing: 10

                                    Repeater {
                                        model: [
                                            { stars: "5★", count: "3", bar: 140 },
                                            { stars: "4★", count: "1", bar: 60 },
                                            { stars: "3★", count: "1", bar: 40 }
                                        ]

                                        delegate: Row {
                                            spacing: 10

                                            Label {
                                                text: modelData.stars
                                                color: root.textSecondary
                                                font.pixelSize: 14
                                                width: 30
                                            }

                                            Rectangle {
                                                width: 180
                                                height: 8
                                                radius: 4
                                                color: root.softCardBg

                                                Rectangle {
                                                    width: modelData.bar
                                                    height: parent.height
                                                    radius: 4
                                                    color: root.accent
                                                }
                                            }

                                            Label {
                                                text: modelData.count
                                                color: root.textPrimary
                                                font.pixelSize: 14
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Column {
                    width: 620
                    spacing: 30

                    Row {
                        spacing: 20

                        Column {
                            width: 300
                            spacing: 20

                            Rectangle {
                                width: parent.width
                                height: 220
                                color: root.cardBg
                                radius: 18
                                border.color: root.borderColor
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 22
                                    spacing: 14

                                    Label {
                                        text: "Book Status"
                                        color: root.textPrimary
                                        font.pixelSize: 18
                                        font.bold: true
                                    }

                                    Row {
                                        spacing: 10

                                        Rectangle {
                                            width: 110
                                            height: 30
                                            radius: 15
                                            color: "#123b32"

                                            Label {
                                                anchors.centerIn: parent
                                                text: "Available"
                                                color: "#4fe0a5"
                                                font.pixelSize: 13
                                                font.bold: true
                                            }
                                        }

                                        Rectangle {
                                            width: 120
                                            height: 30
                                            radius: 15
                                            color: "#1c2643"

                                            Label {
                                                anchors.centerIn: parent
                                                text: "Student Access"
                                                color: "#7f97ff"
                                                font.pixelSize: 13
                                                font.bold: true
                                            }
                                        }
                                    }

                                    GridLayout {
                                        width: parent.width
                                        columns: 2
                                        rowSpacing: 12
                                        columnSpacing: 18

                                        Label { text: "Condition"; color: root.textSecondary; font.pixelSize: 14 }
                                        Label { text: "Good"; color: root.textPrimary; font.pixelSize: 14; font.bold: true }

                                        Label { text: "Reservation"; color: root.textSecondary; font.pixelSize: 14 }
                                        Label { text: "Open"; color: root.textPrimary; font.pixelSize: 14; font.bold: true }

                                        Label { text: "Borrow Limit"; color: root.textSecondary; font.pixelSize: 14 }
                                        Label { text: "2 weeks"; color: root.textPrimary; font.pixelSize: 14; font.bold: true }
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 400
                                color: root.cardBg
                                radius: 18
                                border.color: root.borderColor
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 22
                                    spacing: 14

                                    Label {
                                        text: "Library Location"
                                        color: root.textPrimary
                                        font.pixelSize: 18
                                        font.bold: true
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 68
                                        radius: 14
                                        color: root.softCardBg

                                        Column {
                                            anchors.fill: parent
                                            anchors.margins: 14
                                            spacing: 6
                                            Label { text: "Room"; color: root.textSecondary; font.pixelSize: 13 }
                                            Label { text: root.roomText; color: root.textPrimary; font.pixelSize: 16; font.bold: true }
                                        }
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 68
                                        radius: 14
                                        color: root.softCardBg

                                        Column {
                                            anchors.fill: parent
                                            anchors.margins: 14
                                            spacing: 6
                                            Label { text: "Floor"; color: root.textSecondary; font.pixelSize: 13 }
                                            Label { text: root.floorText; color: root.textPrimary; font.pixelSize: 16; font.bold: true }
                                        }
                                    }

                                    Row {
                                        spacing: 12

                                        Rectangle {
                                            width: 133
                                            height: 68
                                            radius: 14
                                            color: root.softCardBg

                                            Column {
                                                anchors.fill: parent
                                                anchors.margins: 14
                                                spacing: 6
                                                Label { text: "Section"; color: root.textSecondary; font.pixelSize: 13 }
                                                Label { text: root.sectionText; color: root.textPrimary; font.pixelSize: 16; font.bold: true }
                                            }
                                        }

                                        Rectangle {
                                            width: 133
                                            height: 68
                                            radius: 14
                                            color: root.softCardBg

                                            Column {
                                                anchors.fill: parent
                                                anchors.margins: 14
                                                spacing: 6
                                                Label { text: "Shelf"; color: root.textSecondary; font.pixelSize: 13 }
                                                Label { text: root.shelfText; color: root.textPrimary; font.pixelSize: 16; font.bold: true }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 62
                                        radius: 14
                                        color: "#1c2643"
                                        border.color: "#5d77ff"
                                        border.width: 1

                                        Label {
                                            anchors.centerIn: parent
                                            width: parent.width - 24
                                            text: "Navigate to " + root.floorText + ", " + root.roomText + ", Section " + root.sectionText + ", Shelf " + root.shelfText
                                            color: "#7f97ff"
                                            wrapMode: Text.WordWrap
                                            horizontalAlignment: Text.AlignHCenter
                                            font.pixelSize: 13
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            width: 300
                            height: 612

                            Rectangle {
                                anchors.top: parent.top
                                anchors.topMargin: 16
                                width: parent.width
                                height: 600
                                color: root.cardBg
                                radius: 18
                                border.color: root.borderColor
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 22
                                    spacing: 14

                                    Label {
                                        text: "Quick Information"
                                        color: root.textPrimary
                                        font.pixelSize: 18
                                        font.bold: true
                                    }

                                    GridLayout {
                                        width: parent.width
                                        columns: 2
                                        columnSpacing: 28
                                        rowSpacing: 50

                                        Label { text: "Total Copies"; color: root.textSecondary; font.pixelSize: 15 }
                                        Label { text: root.totalCopiesText; color: root.textPrimary; font.pixelSize: 15; font.bold: true }

                                        Label { text: "Available"; color: root.textSecondary; font.pixelSize: 15 }
                                        Label { text: root.availableCopiesText; color: root.green; font.pixelSize: 15; font.bold: true }

                                        Label { text: "On Loan"; color: root.textSecondary; font.pixelSize: 15 }
                                        Label { text: root.borrowedCopiesText; color: root.textPrimary; font.pixelSize: 15; font.bold: true }

                                        Label { text: "Publisher"; color: root.textSecondary; font.pixelSize: 15 }
                                        Label { text: root.publisherText; color: root.textPrimary; font.pixelSize: 15; font.bold: true }

                                        Label { text: "Edition"; color: root.textSecondary; font.pixelSize: 15 }
                                        Label { text: root.editionText; color: root.textPrimary; font.pixelSize: 15; font.bold: true }

                                        Label { text: "Language"; color: root.textSecondary; font.pixelSize: 15 }
                                        Label { text: root.languageText; color: root.textPrimary; font.pixelSize: 15; font.bold: true }

                                        Label { text: "Genre"; color: root.textSecondary; font.pixelSize: 15 }
                                        Label { text: root.genreText; color: root.textPrimary; font.pixelSize: 15; font.bold: true }

                                        Label { text: "ISBN"; color: root.textSecondary; font.pixelSize: 15 }
                                        Label {
                                            text: root.isbnText
                                            color: root.textPrimary
                                            font.pixelSize: 14
                                            font.bold: true
                                            wrapMode: Text.WrapAnywhere
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Rectangle {
                        width: parent.width
                        height: 190
                        color: root.cardBg
                        radius: 18
                        border.color: root.borderColor
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 22
                            spacing: 16

                            Label {
                                text: "Actions"
                                color: root.textPrimary
                                font.pixelSize: 18
                                font.bold: true
                            }

                            Row {
                                spacing: 16

                                Rectangle {
                                    width: 180
                                    height: 44
                                    radius: 12
                                    color: root.accent

                                    Label {
                                        anchors.centerIn: parent
                                        text: "Borrow Book"
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                }

                                Rectangle {
                                    width: 180
                                    height: 44
                                    radius: 12
                                    color: root.softCardBg
                                    border.color: root.borderColor
                                    border.width: 1

                                    Label {
                                        anchors.centerIn: parent
                                        text: "Reserve Book"
                                        color: root.textPrimary
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                }

                                Rectangle {
                                    width: 180
                                    height: 44
                                    radius: 12
                                    color: root.softCardBg
                                    border.color: root.borderColor
                                    border.width: 1

                                    Label {
                                        anchors.centerIn: parent
                                        text: "Read Reviews"
                                        color: root.textPrimary
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
}
}
