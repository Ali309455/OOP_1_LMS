import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    // ── Public API ────────────────────────────────────────────────
    signal backRequested()

    // Default book – replace by binding bookData from outside
    property var bookData: ({
        title:        "Clean Code: A Handbook of Agile Software Craftsmanship",
        subtitle:     "A Handbook of Agile Software Craftsmanship",
        author:       "Robert C. Martin",
        contributors: "Michael C. Feathers, Timothy R. Ottinger",
        rating:       "4.6",
        reviewsCount: "5 reviews",
        tags:         ["Clean Code","Best Practices","Software Craftsmanship","Refactoring","Code Quality"],
        publisher:    "Prentice Hall",
        year:         "2008",
        pages:        "464",
        edition:      "1st Edition",
        language:     "English",
        genre:        "Software Engineering",
        isbn:         "978-0132350884",
        totalCopies:  "5",
        available:    "3",
        borrowed:     "2",
        totalBorrows: "127",
        room:         "Main Hall",
        floor:        "2nd Floor",
        section:      "CS-A",
        shelf:        "A-12",
        overview:     "This book focuses on writing clean, maintainable, and efficient software. It discusses coding principles, refactoring practices, naming conventions, readability, testing habits, and long-term craftsmanship in professional software development."
    })

    // ── Palette ───────────────────────────────────────────────────
    readonly property color pageBg:      "#0b1220"
    readonly property color cardBg:      "#171e2f"
    readonly property color softCardBg:  "#1b2338"
    readonly property color borderColor: "#2a3350"
    readonly property color textPrimary: "#ffffff"
    readonly property color textSec:     "#9aa4bf"
    readonly property color accent:      "#6377f2"
    readonly property color green:       "#16c47f"
    readonly property color chipBg:      "#2a3248"

    color: pageBg
    clip:  true

    // ── Scrollable content ────────────────────────────────────────
    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth:  width
        contentHeight: mainCol.implicitHeight + 24
        clip: true
        // ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
            id: mainCol
            width: flick.width
            spacing: 10
            topPadding: 10
            bottomPadding: 14

            // ── Back button ───────────────────────────────────────
            Item {
                width:  parent.width
                height: 36

                Row {
                    anchors.left:           parent.left
                    anchors.leftMargin:     16
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    Label {
                        id: backlabel
                        text:  "Back to Catalog"
                        color:          root.textSec
                        font.pixelSize: 13
                        font.bold:      true
                    }

                    MouseArea {
                        anchors.fill: backlabel
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: {
                                root.backRequested()
                            }
                    }
                }
            }

            // ── Two-column row (left = main info | right = side cards) ──
            Row {
                id:             twoColRow
                width:          parent.width - 24
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                // ─ LEFT column ─────────────────────────────────────
                Column {
                    id:      leftCol
                    width:   Math.round(twoColRow.width * 0.56)   // ~450 px at 804
                    spacing: 12

                    // Book header card
                    Rectangle {
                        width:  parent.width
                        height: headerContent.implicitHeight + 32
                        color:  root.cardBg
                        radius: 14
                        border.color: root.borderColor
                        border.width: 1

                        Column {
                            id:             headerContent
                            anchors.left:   parent.left
                            anchors.right:  parent.right
                            anchors.top:    parent.top
                            anchors.margins: 16
                            spacing: 14

                            // Cover + title/meta
                            Row {
                                width:   parent.width
                                spacing: 14

                                // Cover placeholder
                                Rectangle {
                                    width:  120
                                    height: 162
                                    radius: 12
                                    color:  "#d9dcf8"

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 8

                                        Label {
                                            text:           "📖"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            font.pixelSize: 36
                                        }
                                        Label {
                                            text:           "No Cover"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            color:          "#6f7485"
                                            font.pixelSize: 11
                                        }
                                    }
                                }

                                // Title block
                                Column {
                                    width:   parent.width - 134
                                    spacing: 8

                                    Label {
                                        width:          parent.width
                                        text:           bookData.title
                                        color:          root.textPrimary
                                        wrapMode:       Text.WordWrap
                                        font.pixelSize: 15
                                        font.bold:      true
                                        lineHeight:     1.2
                                    }

                                    Label {
                                        width:          parent.width
                                        text:           bookData.subtitle
                                        color:          root.textSec
                                        wrapMode:       Text.WordWrap
                                        font.pixelSize: 12
                                    }

                                    Label {
                                        text:           bookData.author
                                        color:          root.textPrimary
                                        font.pixelSize: 13
                                        font.bold:      true
                                    }

                                    Label {
                                        width:          parent.width
                                        text:           "Contributors: " + bookData.contributors
                                        color:          root.textSec
                                        wrapMode:       Text.WordWrap
                                        font.pixelSize: 11
                                    }

                                    Row {
                                        spacing: 6
                                        Label {
                                            text:           "★★★★★"
                                            color:          "#f0b429"
                                            font.pixelSize: 14
                                        }
                                        Label {
                                            text:           bookData.rating + " (" + bookData.reviewsCount + ")"
                                            color:          root.textPrimary
                                            font.pixelSize: 12
                                        }
                                    }

                                    // Tags
                                    Flow {
                                        width:   parent.width
                                        spacing: 6

                                        Repeater {
                                            model: bookData.tags

                                            delegate: Rectangle {
                                                radius: 10
                                                color:  root.chipBg
                                                height: 24
                                                width:  tagLbl.implicitWidth + 14

                                                Label {
                                                    id:             tagLbl
                                                    anchors.centerIn: parent
                                                    text:           modelData
                                                    color:          root.textPrimary
                                                    font.pixelSize: 10
                                                }
                                            }
                                        }
                                    }

                                    // Publisher / Year / Pages / Edition
                                    GridLayout {
                                        width:         parent.width
                                        columns:       2
                                        columnSpacing: 16
                                        rowSpacing:    6

                                        Repeater {
                                            model: [
                                                "Publisher", bookData.publisher,
                                                "Year",      bookData.year,
                                                "Pages",     bookData.pages,
                                                "Edition",   bookData.edition
                                            ]

                                            delegate: Label {
                                                text:           modelData
                                                color:          (index % 2 === 0) ? root.textSec : root.textPrimary
                                                font.pixelSize: 11
                                                font.bold:      (index % 2 !== 0)
                                            }
                                        }
                                    }
                                }
                            }

                            // Availability strip
                            Rectangle {
                                width:  parent.width
                                height: 64
                                radius: 10
                                color:  root.softCardBg

                                Row {
                                    anchors.fill:    parent
                                    anchors.margins: 12
                                    spacing:         0

                                    Repeater {
                                        model: [
                                            { label: "Available",          value: bookData.available + " of " + bookData.totalCopies, highlight: true  },
                                            { label: "Borrowed",           value: bookData.borrowed + " copies",                      highlight: false },
                                            { label: "Total Borrows",      value: bookData.totalBorrows + " times",                   highlight: false }
                                        ]

                                        delegate: Column {
                                            width:   parent.width / 3
                                            spacing: 3
                                            anchors.verticalCenter: parent.verticalCenter

                                            Label {
                                                text:           modelData.label
                                                color:          root.textSec
                                                font.pixelSize: 10
                                            }
                                            Label {
                                                text:           modelData.value
                                                color:          modelData.highlight ? root.green : root.textPrimary
                                                font.pixelSize: 12
                                                font.bold:      true
                                            }
                                        }
                                    }
                                }
                            }

                            // Overview
                            Column {
                                width:   parent.width
                                spacing: 8

                                Row {
                                    spacing: 18
                                    Label {
                                        text:           "Overview"
                                        color:          root.accent
                                        font.pixelSize: 13
                                        font.bold:      true
                                    }
                                    Label {
                                        text:           "Reviews (5)"
                                        color:          root.textSec
                                        font.pixelSize: 13
                                    }
                                }

                                Rectangle { width: parent.width; height: 1; color: root.borderColor }

                                Label {
                                    width:          parent.width
                                    text:           bookData.overview
                                    color:          root.textSec
                                    wrapMode:       Text.WordWrap
                                    font.pixelSize: 12
                                    lineHeight:     1.4
                                }
                            }
                        }
                    }

                    // Review summary card
                    Rectangle {
                        width:  parent.width
                        height: 130
                        color:  root.cardBg
                        radius: 14
                        border.color: root.borderColor
                        border.width: 1

                        Column {
                            anchors.fill:    parent
                            anchors.margins: 16
                            spacing: 10

                            Label {
                                text:           "Review Summary"
                                color:          root.textPrimary
                                font.pixelSize: 13
                                font.bold:      true
                            }

                            Row {
                                spacing: 28

                                Column {
                                    spacing: 3
                                    Label {
                                        text:           bookData.rating
                                        color:          "#f0b429"
                                        font.pixelSize: 22
                                        font.bold:      true
                                    }
                                    Label {
                                        text:           bookData.reviewsCount
                                        color:          root.textSec
                                        font.pixelSize: 11
                                    }
                                }

                                Column {
                                    spacing: 6

                                    Repeater {
                                        model: [
                                            { stars: "5★", count: "3", pct: 0.75 },
                                            { stars: "4★", count: "1", pct: 0.30 },
                                            { stars: "3★", count: "1", pct: 0.20 }
                                        ]

                                        delegate: Row {
                                            spacing: 8

                                            Label {
                                                text:           modelData.stars
                                                color:          root.textSec
                                                font.pixelSize: 11
                                                width:          22
                                            }

                                            Rectangle {
                                                width:  120
                                                height: 6
                                                radius: 3
                                                color:  root.softCardBg

                                                Rectangle {
                                                    width:  parent.width * modelData.pct
                                                    height: parent.height
                                                    radius: 3
                                                    color:  root.accent
                                                }
                                            }

                                            Label {
                                                text:           modelData.count
                                                color:          root.textPrimary
                                                font.pixelSize: 11
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }   // end leftCol

                // ─ RIGHT column ────────────────────────────────────
                Column {
                    id:      rightCol
                    width:   twoColRow.width - leftCol.width - twoColRow.spacing  // remaining
                    spacing: 12

                    // Book Status card
                    Rectangle {
                        width:  parent.width
                        height: 150
                        color:  root.cardBg
                        radius: 14
                        border.color: root.borderColor
                        border.width: 1

                        Column {
                            anchors.fill:    parent
                            anchors.margins: 16
                            spacing: 10

                            Label {
                                text:           "Book Status"
                                color:          root.textPrimary
                                font.pixelSize: 13
                                font.bold:      true
                            }

                            Row {
                                spacing: 8

                                Rectangle {
                                    width:  90; height: 26; radius: 13
                                    color:  "#123b32"
                                    Label { anchors.centerIn: parent; text: "Available"; color: "#4fe0a5"; font.pixelSize: 11; font.bold: true }
                                }

                                Rectangle {
                                    width:  110; height: 26; radius: 13
                                    color:  "#1c2643"
                                    Label { anchors.centerIn: parent; text: "Student Access"; color: "#7f97ff"; font.pixelSize: 11; font.bold: true }
                                }
                            }

                            GridLayout {
                                width:         parent.width
                                columns:       2
                                rowSpacing:    8
                                columnSpacing: 12

                                Repeater {
                                    model: [
                                        "Condition",    "Good",
                                        "Reservation",  "Open",
                                        "Borrow Limit", "2 weeks"
                                    ]

                                    delegate: Label {
                                        text:           modelData
                                        color:          (index % 2 === 0) ? root.textSec : root.textPrimary
                                        font.pixelSize: 12
                                        font.bold:      (index % 2 !== 0)
                                    }
                                }
                            }
                        }
                    }

                    // Quick Information card
                    Rectangle {
                        width:  parent.width
                        height: 260
                        color:  root.cardBg
                        radius: 14
                        border.color: root.borderColor
                        border.width: 1

                        Column {
                            anchors.fill:    parent
                            anchors.margins: 16
                            spacing: 10

                            Label {
                                text:           "Quick Information"
                                color:          root.textPrimary
                                font.pixelSize: 13
                                font.bold:      true
                            }

                            GridLayout {
                                width:         parent.width
                                columns:       2
                                columnSpacing: 12
                                rowSpacing:    14

                                Repeater {
                                    model: [
                                        "Total Copies", bookData.totalCopies,
                                        "Available",    bookData.available,
                                        "On Loan",      bookData.borrowed,
                                        "Publisher",    bookData.publisher,
                                        "Edition",      bookData.edition,
                                        "Language",     bookData.language,
                                        "Genre",        bookData.genre,
                                        "ISBN",         bookData.isbn
                                    ]

                                    delegate: Label {
                                        text:           modelData
                                        color:          (index % 2 === 0) ? root.textSec : ((index === 3) ? root.green : root.textPrimary)
                                        font.pixelSize: 11
                                        font.bold:      (index % 2 !== 0)
                                        wrapMode:       Text.WrapAnywhere
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }

                    // Library Location card
                    Rectangle {
                        width:  parent.width
                        height: 220
                        color:  root.cardBg
                        radius: 14
                        border.color: root.borderColor
                        border.width: 1

                        Column {
                            anchors.fill:    parent
                            anchors.margins: 16
                            spacing: 10

                            Label {
                                text:           "Library Location"
                                color:          root.textPrimary
                                font.pixelSize: 13
                                font.bold:      true
                            }

                            // Room / Floor
                            Row {
                                width:   parent.width
                                spacing: 8

                                Repeater {
                                    model: [
                                        { label: "Room",  val: bookData.room  },
                                        { label: "Floor", val: bookData.floor }
                                    ]

                                    delegate: Rectangle {
                                        width:  (parent.width - 8) / 2
                                        height: 54
                                        radius: 10
                                        color:  root.softCardBg

                                        Column {
                                            anchors.fill:    parent
                                            anchors.margins: 10
                                            spacing:         4
                                            Label { text: modelData.label; color: root.textSec;     font.pixelSize: 10 }
                                            Label { text: modelData.val;   color: root.textPrimary; font.pixelSize: 12; font.bold: true; elide: Text.ElideRight; width: parent.width }
                                        }
                                    }
                                }
                            }

                            // Section / Shelf
                            Row {
                                width:   parent.width
                                spacing: 8

                                Repeater {
                                    model: [
                                        { label: "Section", val: bookData.section },
                                        { label: "Shelf",   val: bookData.shelf   }
                                    ]

                                    delegate: Rectangle {
                                        width:  (parent.width - 8) / 2
                                        height: 54
                                        radius: 10
                                        color:  root.softCardBg

                                        Column {
                                            anchors.fill:    parent
                                            anchors.margins: 10
                                            spacing:         4
                                            Label { text: modelData.label; color: root.textSec;     font.pixelSize: 10 }
                                            Label { text: modelData.val;   color: root.textPrimary; font.pixelSize: 12; font.bold: true }
                                        }
                                    }
                                }
                            }

                            // Navigate hint
                            Rectangle {
                                width:  parent.width
                                height: 40
                                radius: 10
                                color:  "#1c2643"
                                border.color: "#5d77ff"
                                border.width: 1

                                Label {
                                    anchors.centerIn: parent
                                    width:            parent.width - 16
                                    text:             "Navigate → " + bookData.floor + " · " + bookData.room + " · " + bookData.section + " · " + bookData.shelf
                                    color:            "#7f97ff"
                                    font.pixelSize:   10
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode:         Text.WordWrap
                                }
                            }
                        }
                    }

                    // Actions card
                    Rectangle {
                        width:  parent.width
                        height: 110
                        color:  root.cardBg
                        radius: 14
                        border.color: root.borderColor
                        border.width: 1

                        Column {
                            anchors.fill:    parent
                            anchors.margins: 16
                            spacing: 12

                            Label {
                                text:           "Actions"
                                color:          root.textPrimary
                                font.pixelSize: 13
                                font.bold:      true
                            }

                            Row {
                                spacing: 8

                                Repeater {
                                    model: ["Borrow Book", "Reserve", "Reviews"]

                                    delegate: Rectangle {
                                        width:  (rightCol.width - 32 - 16) / 3
                                        height: 36
                                        radius: 10
                                        color:  index === 0 ? root.accent : root.softCardBg
                                        border.color: index === 0 ? "transparent" : root.borderColor
                                        border.width: 1

                                        Label {
                                            anchors.centerIn: parent
                                            text:           modelData
                                            color:          "#ffffff"
                                            font.pixelSize: 11
                                            font.bold:      true
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape:  Qt.PointingHandCursor
                                            // connect signals as needed
                                        }
                                    }
                                }
                            }
                        }
                    }

                }   // end rightCol
            }       // end twoColRow
        }           // end mainCol
    }               // end Flickable
    // ── Custom Thin Scrollbar ─────────────────────────────
    Rectangle {
        id: scrollTrack
        width: 4
        radius: 2
        color: "#1e2535"

        anchors.top: flick.top
        anchors.bottom: flick.bottom
        anchors.right: flick.right
        anchors.rightMargin: 4

        visible: flick.contentHeight > flick.height

        Rectangle {
            id: scrollThumb
            width: parent.width
            radius: 2

            color: thumbMA.pressed
                   ? "#9ca3af"
                   : thumbMA.containsMouse ? "#6b7280"
                                           : "#374151"

            Behavior on color { ColorAnimation { duration: 120 } }

            // dynamic height
            height: Math.max(
                30,
                scrollTrack.height * (flick.height / flick.contentHeight)
            )

            // sync position
            y: flick.contentY / (flick.contentHeight - flick.height)
               * (scrollTrack.height - height)
            // ── Drag logic ──
            MouseArea {
                id: thumbMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.SizeVerCursor
                preventStealing: true

                property real startY
                property real startContentY

                onPressed: {
                    startY = mouseY
                    startContentY = flick.contentY
                }

                onPositionChanged: {
                    if (pressed) {
                        var delta = mouseY - startY

                        var newContentY = startContentY +
                            delta * (flick.contentHeight / scrollTrack.height)

                        flick.contentY = Math.max(
                            0,
                            Math.min(newContentY, flick.contentHeight - flick.height)
                        )
                    }
                }
            }
        }

        // click on track to jump
        MouseArea {
            anchors.fill: parent
            onClicked: {
                flick.contentY =
                    (mouseY / scrollTrack.height) *
                    (flick.contentHeight - flick.height)
            }
        }
    } // end scrollbar
}
