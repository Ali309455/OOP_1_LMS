import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    anchors.fill: parent
    color: "#0b1220"

    signal backRequested()

    // ─────────────────────────────────────────────
    // REAL DATABASE DATA ONLY
    // ─────────────────────────────────────────────
    property var bookData: ({
        isbn: "123-1",
        bookname: "Clean Code: A Handbook of Agile Software Craftsmanship",
        author: "Robert C. Martin",
        genre: "Programming",
        section: "CS-A",
        publisher: "Prentice Hall",
        edition: "1st Edition",
        language: "English",
        publicationYear: 2008,
        totalcopies: 5,
        pages: 464,
        availablecopies: 3
    })

    // ─────────────────────────────────────────────
    // COLORS
    // ─────────────────────────────────────────────
    readonly property color pageBg: "#0b1220"
    readonly property color cardBg: "#171e2f"
    readonly property color softCardBg: "#1f2937"
    readonly property color borderColor: "#2d3748"
    readonly property color textPrimary: "#ffffff"
    readonly property color textSecondary: "#9ca3af"
    readonly property color accent: "#3b82f6"
    readonly property color success: "#10b981"

    // ─────────────────────────────────────────────
    // SCROLLABLE PAGE
    // ─────────────────────────────────────────────
    Flickable {
        id: flick
        anchors.fill: parent
        anchors.margins: 18

        contentWidth: width
        contentHeight: contentCol.implicitHeight + 20

        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: contentCol
            width: flick.width
            spacing: 16

            // ─────────────────────────────────────
            // TOP BAR
            // ─────────────────────────────────────
            Row {
                width: parent.width
                height: 36
                spacing: 8

                Text {
                    id: backTxt
                    text: "← Back to Catalog"
                    color: root.textSecondary
                    font.pixelSize: 13
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                MouseArea {
                    anchors.fill: backTxt
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.backRequested()
                }
            }

            // ─────────────────────────────────────
            // MAIN CONTENT
            // ─────────────────────────────────────
            Row {
                width: parent.width
                spacing: 16

                // =========================================
                // LEFT SIDE
                // =========================================
                Column {
                    width: parent.width * 0.58
                    spacing: 16

                    // ─────────────────────────────────
                    // HEADER CARD
                    // ─────────────────────────────────
                    Rectangle {
                        width: parent.width
                        radius: 16
                        color: root.cardBg
                        border.color: root.borderColor
                        border.width: 1

                        implicitHeight: headerCol.implicitHeight + 32

                        Column {
                            id: headerCol
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            Row {
                                width: parent.width
                                spacing: 16

                                // BOOK COVER
                                Rectangle {
                                    width: 130
                                    height: 180
                                    radius: 12
                                    color: "#dbe4ff"

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 8

                                        Text {
                                            text: "📚"
                                            font.pixelSize: 40
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        Text {
                                            text: "No Cover"
                                            color: "#6b7280"
                                            font.pixelSize: 11
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }

                                // BOOK INFO
                                Column {
                                    width: parent.width - 150
                                    spacing: 10

                                    Text {
                                        width: parent.width
                                        text: bookData.bookname
                                        wrapMode: Text.WordWrap
                                        color: root.textPrimary
                                        font.pixelSize: 22
                                        font.bold: true
                                    }

                                    Text {
                                        text: "by " + bookData.author
                                        color: root.textSecondary
                                        font.pixelSize: 14
                                    }

                                    Row {
                                        spacing: 8

                                        Rectangle {
                                            radius: 8
                                            height: 28
                                            width: genreTxt.implicitWidth + 20
                                            color: "#1e293b"

                                            Text {
                                                id: genreTxt
                                                anchors.centerIn: parent
                                                text: bookData.genre
                                                color: "#cbd5e1"
                                                font.pixelSize: 11
                                                font.bold: true
                                            }
                                        }

                                        Rectangle {
                                            radius: 8
                                            height: 28
                                            width: availTxt.implicitWidth + 20
                                            color: "#052e16"

                                            Text {
                                                id: availTxt
                                                anchors.centerIn: parent
                                                text: bookData.availableCopies + " Available"
                                                color: "#10b981"
                                                font.pixelSize: 11
                                                font.bold: true
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 1
                                        color: root.borderColor
                                    }

                                    GridLayout {
                                        width: parent.width
                                        columns: 2
                                        rowSpacing: 10
                                        columnSpacing: 20

                                        Repeater {
                                            model: [
                                                "Publisher", bookData.publisher,
                                                "Edition", bookData.edition,
                                                "Language", bookData.language,
                                                "Year", bookData.year,
                                                "Pages", bookData.pages,
                                                "Section", bookData.section
                                            ]

                                            delegate: Text {
                                                text: modelData
                                                color: index % 2 === 0
                                                       ? root.textSecondary
                                                       : root.textPrimary

                                                font.pixelSize: 12
                                                font.bold: index % 2 !== 0
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ─────────────────────────────────
                    // BOOK DETAILS CARD
                    // ─────────────────────────────────
                    Rectangle {
                        width: parent.width
                        radius: 16
                        color: root.cardBg
                        border.color: root.borderColor
                        border.width: 1

                        implicitHeight: detailCol.implicitHeight + 32

                        Column {
                            id: detailCol
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 18

                            Text {
                                text: "Book Information"
                                color: root.textPrimary
                                font.pixelSize: 16
                                font.bold: true
                            }

                            GridLayout {
                                width: parent.width
                                columns: 2
                                rowSpacing: 14
                                columnSpacing: 20

                                Repeater {
                                    model: [
                                        "ISBN", bookData.isbn,
                                        "Genre", bookData.genre,
                                        "Section", bookData.section,
                                        "Publisher", bookData.publisher,
                                        "Edition", bookData.edition,
                                        "Language", bookData.language,
                                        "Publication Year", bookData.year,
                                        "Pages", bookData.pages,
                                        "Total Copies", bookData.totalCopies,
                                        "Available Copies", bookData.availableCopies
                                    ]

                                    delegate: Text {
                                        Layout.fillWidth: true

                                        text: modelData
                                        wrapMode: Text.WrapAnywhere

                                        color: index % 2 === 0
                                               ? root.textSecondary
                                               : root.textPrimary

                                        font.pixelSize: 13
                                        font.bold: index % 2 !== 0
                                    }
                                }
                            }
                        }
                    }
                }

                // =========================================
                // RIGHT SIDE
                // =========================================
                Column {
                    width: parent.width * 0.42 - 16
                    spacing: 16

                    // ─────────────────────────────────
                    // AVAILABILITY CARD
                    // ─────────────────────────────────
                    Rectangle {
                        width: parent.width
                        radius: 16
                        color: root.cardBg
                        border.color: root.borderColor
                        border.width: 1

                        implicitHeight: availCol.implicitHeight + 32

                        Column {
                            id: availCol
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            Text {
                                text: "Availability"
                                color: root.textPrimary
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Row {
                                spacing: 12

                                Rectangle {
                                    width: 130
                                    height: 70
                                    radius: 12
                                    color: "#052e16"

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 4

                                        Text {
                                            text: bookData.availableCopies
                                            color: "#10b981"
                                            font.pixelSize: 20
                                            font.bold: true
                                        }

                                        Text {
                                            text: "Available"
                                            color: "#86efac"
                                            font.pixelSize: 11
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 130
                                    height: 70
                                    radius: 12
                                    color: "#1e293b"

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 4

                                        Text {
                                            text: bookData.totalCopies
                                            color: "#ffffff"
                                            font.pixelSize: 20
                                            font.bold: true
                                        }

                                        Text {
                                            text: "Total Copies"
                                            color: "#9ca3af"
                                            font.pixelSize: 11
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ─────────────────────────────────
                    // QUICK STATS
                    // ─────────────────────────────────
                    Rectangle {
                        width: parent.width
                        radius: 16
                        color: root.cardBg
                        border.color: root.borderColor
                        border.width: 1

                        implicitHeight: statsCol.implicitHeight + 32

                        Column {
                            id: statsCol
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 14

                            Text {
                                text: "Quick Stats"
                                color: root.textPrimary
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Repeater {
                                model: [
                                    { label: "ISBN", value: bookData.isbn },
                                    { label: "Author", value: bookData.author },
                                    { label: "Genre", value: bookData.genre },
                                    { label: "Pages", value: bookData.pages }
                                ]

                                delegate: Rectangle {
                                    width: parent.width
                                    height: 48
                                    radius: 10
                                    color: root.softCardBg

                                    Row {
                                        anchors.fill: parent
                                        anchors.leftMargin: 14
                                        anchors.rightMargin: 14

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: modelData.label
                                            color: root.textSecondary
                                            font.pixelSize: 12
                                        }

                                        Item {
                                            width: 1
                                            height: 1
                                        }

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.right: parent.right
                                            text: modelData.value
                                            color: root.textPrimary
                                            font.pixelSize: 12
                                            font.bold: true
                                            elide: Text.ElideRight
                                            width: 140
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                width: 1
                height: 20
            }
        }
    }

    // ─────────────────────────────────────────────
    // CUSTOM SCROLLBAR
    // ─────────────────────────────────────────────
    Rectangle {
        id: scrollTrack

        width: 5
        radius: 3
        color: "#1e2535"

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 6

        visible: flick.contentHeight > flick.height

        Rectangle {
            id: thumb

            width: parent.width
            radius: 3

            color: thumbMA.pressed
                   ? "#9ca3af"
                   : thumbMA.containsMouse
                     ? "#6b7280"
                     : "#374151"

            height: Math.max(
                40,
                scrollTrack.height * (flick.height / flick.contentHeight)
            )

            y: flick.contentY / (flick.contentHeight - flick.height)
               * (scrollTrack.height - height)

            MouseArea {
                id: thumbMA
                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.SizeVerCursor

                property real startY
                property real startContentY

                onPressed: {
                    startY = mouseY
                    startContentY = flick.contentY
                }

                onPositionChanged: {
                    if (pressed) {
                        var delta = mouseY - startY

                        flick.contentY = startContentY +
                                delta * (flick.contentHeight / scrollTrack.height)
                    }
                }
            }
        }
    }
}
