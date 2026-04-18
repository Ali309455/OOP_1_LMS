import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// Books.qml
Rectangle {
    id: booksView
    anchors.fill: parent
    color: "#f8f9fa"

    // ── Conditional Role Variable ──────────────────────────────────────────
    property bool isLibrarian: false// Set to false to hide the "Add Book" button

    signal bookSelected(string isbn, string title)
    signal filterChanged(string filterKey, var filterValue)
    signal addBookRequested() // Signal to handle the button click

    // ── All books data ─────────────────────────────────────────────────────
    property var allBooks: [
        { isbn: "978-83323", title: "Clean Code",                    author: "Robert C. Martin",      genre: "Programming", section: "CS-A", available: 5,  color: "#10b981" },
        { isbn: "90984",     title: "Design Patterns",               author: "Gang of Four",          genre: "Programming", section: "CS-A", available: 3,  color: "#f59e0b" },
        { isbn: "978-20112", title: "Effective Java",                author: "Joshua Bloch",          genre: "Programming", section: "CS-B", available: 8,  color: "#10b981" },
        { isbn: "39812",     title: "Head First Design Patterns",    author: "Freeman & Freeman",     genre: "Programming", section: "CS-B", available: 2,  color: "#f59e0b" },
        { isbn: "978-83379", title: "The Pragmatic Programmer",      author: "Hunt & Thomas",         genre: "Programming", section: "CS-A", available: 6,  color: "#10b981" },
        { isbn: "82628",     title: "Introduction to Algorithms",    author: "CLRS",                  genre: "Algorithms",  section: "CS-C", available: 4,  color: "#10b981" },
        { isbn: "33848",     title: "Cracking the Coding Interview", author: "McDowell",              genre: "Programming", section: "CS-B", available: 7,  color: "#10b981" },
        { isbn: "978-89911", title: "You Don't Know JS",             author: "Kyle Simpson",          genre: "Programming", section: "CS-B", available: 3,  color: "#f59e0b" },
        { isbn: "85955",     title: "Web Development with Django",   author: "Douglas Hellmann",      genre: "Web",         section: "WEB-A", available: 5,  color: "#10b981" },
        { isbn: "978-12345", title: "Eloquent JavaScript",           author: "Marijn Haverbeke",      genre: "Web",         section: "WEB-B", available: 2,  color: "#f59e0b" },
        { isbn: "67890",     title: "Python Crash Course",           author: "Eric Matthes",          genre: "Programming", section: "CS-A", available: 9,  color: "#10b981" },
        { isbn: "54321",     title: "The C Programming Language",    author: "Kernighan & Ritchie",   genre: "Programming", section: "CS-C", available: 1,  color: "#ef4444" },
        { isbn: "978-11111", title: "Modern JavaScript",             author: "Larry Ullman",          genre: "Web",         section: "WEB-A", available: 4,  color: "#10b981" },
        { isbn: "22222",     title: "Advanced C Programming",        author: "Richard Reese",         genre: "Programming", section: "CS-C", available: 0,  color: "#ef4444" },
        { isbn: "978-33333", title: "Data Structures Simplified",    author: "Mark Allen Weiss",      genre: "Algorithms",  section: "CS-B", available: 6,  color: "#10b981" }
    ]

    // ── Filtered books display ─────────────────────────────────────────────
    property var filteredBooks: allBooks
    property string searchText: ""
    property string filterGenre: ""
    property string filterSection: ""
    property string filterAvailability: "all"

    onSearchTextChanged: updateFilters()
    onFilterGenreChanged: updateFilters()
    onFilterSectionChanged: updateFilters()
    onFilterAvailabilityChanged: updateFilters()

    function updateFilters() {
        filteredBooks = allBooks.filter(function(book) {
            if (searchText.length > 0) {
                var search = searchText.toLowerCase()
                var matchesSearch = book.title.toLowerCase().includes(search) ||
                                   book.author.toLowerCase().includes(search) ||
                                   book.isbn.toLowerCase().includes(search)
                if (!matchesSearch) return false
            }
            if (filterGenre && book.genre !== filterGenre) return false
            if (filterSection && book.section !== filterSection) return false
            if (filterAvailability === "available" && book.available === 0) return false
            if (filterAvailability === "unavailable" && book.available > 0) return false
            return true
        })
    }

    // ── Header Title & Add Button ─────────────────────────────────────────
    Rectangle {
        id: headerArea
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        color: "transparent"

        ColumnLayout {
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                text: "Book Catalog"
                font.pixelSize: 22
                font.bold: true
                color: "#111827"
            }
            Text {
                text: "Browse and manage library books (" + booksView.allBooks.length + " books)"
                font.pixelSize: 13
                color: "#6b7280"
            }
        }

        // Conditional Add Button
        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 24
            anchors.verticalCenter: parent.verticalCenter
            width: 100
            height: 36
            radius: 6
            color: "#007bff"

            // This is the conditional rendering logic
            visible: booksView.isLibrarian

            Text {
                anchors.centerIn: parent
                text: "+ Add Book"
                color: "white"
                font.pixelSize: 13
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: booksView.addBookRequested()
            }
        }
    }

    // ── Top filter bar ────────────────────────────────────────────────────
    Rectangle {
        id: filterArea
        anchors.top: headerArea.bottom // Anchored below the new header
        anchors.left: parent.left
        anchors.right: parent.right
        height: 64
        color: "#ffffff"
        border.color: "#e5e7eb"
        border.width: 0

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#e5e7eb"
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            spacing: 12

            // Search box
            Rectangle {
                Layout.preferredWidth: 280
                height: 40
                radius: 8
                color: "#f3f4f6"
                border.color: searchInput.activeFocus ? "#3b82f6" : "transparent"
                border.width: searchInput.activeFocus ? 2 : 0

                Behavior on border.color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: "🔍"
                        font.pixelSize: 14
                        opacity: 0.5
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        color: "#374151"
                        font.pixelSize: 13
                        clip: true
                        selectByMouse: true
                        verticalAlignment: TextInput.AlignVCenter

                        onTextChanged: booksView.searchText = text

                        Text {
                            visible: !parent.text
                            text: "Search by title, author, ISBN..."
                            color: "#9ca3af"
                            font: parent.font
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            // Genre filter
            ComboBox {
                id: genreCombo
                Layout.preferredWidth: 90
                height: 40
                model: ["All Genres", "Programming", "Algorithms", "Web"]
                font.pixelSize: 12
                displayText: currentText

                onCurrentTextChanged: {
                    booksView.filterGenre = currentText === "All Genres" ? "" : currentText
                }

                contentItem: Text {
                    text: genreCombo.displayText
                    color: "#374151"
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }

                background: Rectangle {
                    radius: 8
                    color: "#f3f4f6"
                    border.color: "#e5e7eb"
                    border.width: 1
                }
            }

            // Section filter
            ComboBox {
                id: sectionCombo
                Layout.preferredWidth: 120
                height: 40
                model: ["All Sections", "CS-A", "CS-B", "CS-C", "WEB-A", "WEB-B"]
                font.pixelSize: 12
                displayText: currentText

                onCurrentTextChanged: {
                    booksView.filterSection = currentText === "All Sections" ? "" : currentText
                }

                contentItem: Text {
                    text: sectionCombo.displayText
                    color: "#374151"
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }

                background: Rectangle {
                    radius: 8
                    color: "#f3f4f6"
                    border.color: "#e5e7eb"
                    border.width: 1
                }
            }

            // Availability filter
            ComboBox {
                id: availCombo
                Layout.preferredWidth: 120
                height: 40
                model: ["All", "Available", "Unavailable"]
                font.pixelSize: 12
                displayText: currentText

                onCurrentTextChanged: {
                    if (currentText === "Available") {
                        booksView.filterAvailability = "available"
                    } else if (currentText === "Unavailable") {
                        booksView.filterAvailability = "unavailable"
                    } else {
                        booksView.filterAvailability = "all"
                    }
                }

                contentItem: Text {
                    text: availCombo.displayText
                    color: "#374151"
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                }

                background: Rectangle {
                    radius: 8
                    color: "#f3f4f6"
                    border.color: "#e5e7eb"
                    border.width: 1
                }
            }

            Item { Layout.fillWidth: true }

            // Results counter
            Text {
                text: filteredBooks.length + " books"
                color: "#6b7280"
                font.pixelSize: 12
                font.bold: true
            }
        }
    }

    // ── Books table ────────────────────────────────────────────────────────
    Rectangle {
        anchors.top: filterArea.bottom // Anchored below the filter bar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "#ffffff"

        Flickable {
            id: tableFlick
            anchors.fill: parent
            anchors.margins: 1
            anchors.rightMargin: 7
            contentWidth: width
            contentHeight: tableCol.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: tableCol
                width: tableFlick.width
                spacing: 0

                // Table header
                Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    color: "#f9fafb"
                    border.color: "#e5e7eb"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 0

                        Text {
                            Layout.preferredWidth: 100
                            text: "ISBN"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#6b7280"
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Title"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#6b7280"
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            Layout.preferredWidth: 140
                            text: "Author"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#6b7280"
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            Layout.preferredWidth: 90
                            text: "Genre"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#6b7280"
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            Layout.preferredWidth: 75
                            text: "Section"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#6b7280"
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            Layout.preferredWidth: 70
                            text: "Available"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#6b7280"
                            horizontalAlignment: Text.AlignCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            Layout.preferredWidth: 40
                            text: "Action"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#6b7280"
                            horizontalAlignment: Text.AlignCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                // Table rows
                Repeater {
                    model: booksView.filteredBooks
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 52
                        color: rowHover.containsMouse ? "#f9fafb" : "#ffffff"
                        border.color: "#f3f4f6"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 100 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            spacing: 0

                            Text {
                                Layout.preferredWidth: 100
                                text: modelData.isbn
                                font.pixelSize: 12
                                color: "#374151"
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.title
                                font.pixelSize: 12
                                color: "#111827"
                                font.bold: true
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.preferredWidth: 140
                                text: modelData.author
                                font.pixelSize: 12
                                color: "#6b7280"
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.preferredWidth: 90
                                text: modelData.genre
                                font.pixelSize: 12
                                color: "#6b7280"
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            Rectangle {
                                Layout.preferredWidth: 75
                                height: 24
                                radius: 4
                                color: "#f3f4f6"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.section
                                    font.pixelSize: 11
                                    color: "#374151"
                                    font.bold: true
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 70
                                height: 26
                                radius: 12
                                color: modelData.color + "20"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.available
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: modelData.color
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 40
                                height: 32
                                radius: 8
                                color: actionMA.containsPress ? "#dbeafe"
                                     : actionMA.containsMouse ? "#e0f2fe"
                                     : "transparent"

                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "👁"
                                    font.pixelSize: 14
                                }

                                MouseArea {
                                    id: actionMA
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: booksView.bookSelected(modelData.isbn, modelData.title)
                                }
                            }
                        }

                        MouseArea {
                            id: rowHover
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                        }
                    }
                }

                // Empty state
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(200, tableFlick.height - 48)
                    color: "#ffffff"
                    visible: booksView.filteredBooks.length === 0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 12

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "📚"
                            font.pixelSize: 48
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "No books found"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#6b7280"
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Try adjusting your search or filters"
                            font.pixelSize: 13
                            color: "#9ca3af"
                        }
                    }
                }
            }
        }

        // ── Vertical scrollbar ─────────────────────────────────────────────
        ScrollBar {
            id: vBar
            anchors.right: parent.right
            anchors.rightMargin: 1
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            orientation: Qt.Vertical
            size: tableFlick.visibleArea.heightRatio
            position: tableFlick.visibleArea.yPosition
            width: 6
            policy: ScrollBar.AsNeeded

            onPositionChanged: {
                if (pressed)
                    tableFlick.contentY = position * tableFlick.contentHeight
            }

            contentItem: Rectangle {
                radius: 3
                color: vBar.pressed ? "#9ca3af" : "#d1d5db"
            }

            background: Rectangle {
                color: "transparent"
            }
        }

        Connections {
            target: tableFlick
            function onContentYChanged() {
                if (!vBar.pressed)
                    vBar.position = tableFlick.contentY / tableFlick.contentHeight
            }
        }
    }
}
