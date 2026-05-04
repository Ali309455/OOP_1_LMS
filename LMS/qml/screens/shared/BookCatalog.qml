import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import LMS
// BookCatalog.qml  —  Dark theme
Rectangle {
    id: booksView
    color: "#0f1117"
    anchors.fill: parent

    // ── Role: controls Add Book button visibility ──────────────────────────
    property bool isLibrarian: true   // set false for student view

    signal bookSelected(var book)
    signal filterChanged(string filterKey, var filterValue)

    // ── Book data as ListModel for full reactivity ─────────────────────────
    property var bookList: lms.getBooks();
    ListModel {
        id: booksModel
        // ListElement { isbn: "978-83323"; title: "Clean Code";                 author: "Robert C. Martin";   genre: "Programming"; section: "CS-A";  available: 5 }
        // ListElement { isbn: "90984";     title: "Design Patterns";            author: "Gang of Four";        genre: "Programming"; section: "CS-A";  available: 3 }
        // ListElement { isbn: "978-20112"; title: "Effective Java";             author: "Joshua Bloch";        genre: "Programming"; section: "CS-B";  available: 8 }
        // ListElement { isbn: "39812";     title: "Head First Design Patterns"; author: "Freeman & Freeman";   genre: "Programming"; section: "CS-B";  available: 2 }
        // ListElement { isbn: "978-83379"; title: "The Pragmatic Programmer";   author: "Hunt & Thomas";       genre: "Programming"; section: "CS-A";  available: 6 }
        // ListElement { isbn: "82628";     title: "Introduction to Algorithms"; author: "CLRS";                genre: "Algorithms";  section: "CS-C";  available: 4 }
        // ListElement { isbn: "33848";     title: "Cracking the Coding Interview"; author: "McDowell";         genre: "Programming"; section: "CS-B";  available: 7 }
        // ListElement { isbn: "978-89911"; title: "You Don't Know JS";          author: "Kyle Simpson";        genre: "Programming"; section: "CS-B";  available: 3 }
        // ListElement { isbn: "85955";     title: "Web Development with Django";author: "Douglas Hellmann";    genre: "Web";         section: "WEB-A"; available: 5 }
        // ListElement { isbn: "978-12345"; title: "Eloquent JavaScript";        author: "Marijn Haverbeke";    genre: "Web";         section: "WEB-B"; available: 2 }
        // ListElement { isbn: "67890";     title: "Python Crash Course";        author: "Eric Matthes";        genre: "Programming"; section: "CS-A";  available: 9 }
        // ListElement { isbn: "54321";     title: "The C Programming Language"; author: "Kernighan & Ritchie"; genre: "Programming"; section: "CS-C";  available: 1 }
        // ListElement { isbn: "978-11111"; title: "Modern JavaScript";          author: "Larry Ullman";        genre: "Web";         section: "WEB-A"; available: 4 }
        // ListElement { isbn: "22222";     title: "Advanced C Programming";     author: "Richard Reese";       genre: "Programming"; section: "CS-C";  available: 0 }
        // ListElement { isbn: "978-33333"; title: "Data Structures Simplified"; author: "Mark Allen Weiss";    genre: "Algorithms";  section: "CS-B";  available: 6 }
    }
    Component.onCompleted: {
        syncBooksModel()
    }

    function syncBooksModel() {
        booksModel.clear();

        console.log("--- Starting Sync. Total items in bookList: " + bookList.length + " ---");

        for (var i = 0; i < bookList.length; i++) {
            var item = bookList[i];

            // 1. Check if the item itself exists
            if (item === undefined) {
                console.error("Error: Item at index " + i + " is undefined.");
                continue;
            }

            // 2. Stringify the object to see its full structure in the console
            // This helps if the object is valid but the console just says [object Object]
            console.log("Index " + i + ": " + JSON.stringify(item));

            // 3. Append to model
            booksModel.append(item);
        }

        console.log("--- Sync Complete. Model count: " + booksModel.count + " ---");
    }

    // ── Available color helper ─────────────────────────────────────────────
    function availColor(n) { return n >= 5 ? "#10b981" : n >= 2 ? "#f59e0b" : "#ef4444" }

    // ── Row filter ─────────────────────────────────────────────────────────
    property string searchText: ""
    property string filterGenre: ""
    property string filterSection: ""
    property string filterAvailability: "all"

    function rowVisible(book) {
        if (searchText.length > 0) {
            var s = searchText.toLowerCase()
            if (!book.title.toLowerCase().includes(s) &&
                !book.author.toLowerCase().includes(s) &&
                !book.isbn.toLowerCase().includes(s)) return false
        }
        if (filterGenre    && book.genre    !== filterGenre)    return false
        if (filterSection  && book.section  !== filterSection)  return false
        if (filterAvailability === "available"   && book.available === 0) return false
        if (filterAvailability === "unavailable" && book.available > 0)   return false
        return true
    }

    function visibleCount() {
        var c = 0
        for (var i = 0; i < booksModel.count; i++)
            if (rowVisible(booksModel.get(i))) c++
        return c
    }

    // ── Add Book dialog state ──────────────────────────────────────────────
    property bool showAddDialog: false
    property string formIsbn: ""
    property string formTitle: ""
    property string formAuthor: ""
    property string formGenre: "Programming"
    property string formSection: "CS-A"
    property int    formAvailable: 1

    function resetForm() {
        formIsbn = ""; formTitle = ""; formAuthor = ""
        formGenre = "Programming"; formSection = "CS-A"; formAvailable = 1
    }

    function addBook() {
        if (!formIsbn || !formTitle || !formAuthor) return
        booksModel.insert(0, {
            isbn:      formIsbn,
            title:     formTitle,
            author:    formAuthor,
            genre:     formGenre,
            section:   formSection,
            available: formAvailable
        })
        resetForm()
        showAddDialog = false
    }

    // ══════════════════════════════════════════════════════════════════════
    // LAYOUT
    // ══════════════════════════════════════════════════════════════════════
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Header ────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 80
            color: "#1a1f2e"
            border.color: "#2d3748"; border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24; anchors.rightMargin: 24
                spacing: 0

                ColumnLayout {
                    spacing: 6
                    Text { text: "Book Catalog";  font.pixelSize: 22; font.bold: true; color: "#ffffff" }
                    Text {
                        text: "Browse and manage library books (" + booksModel.count + " books)"
                        font.pixelSize: 13; color: "#9ca3af"
                    }
                }

                Item { Layout.fillWidth: true }

                // ── Add Book button — only shown to librarians ─────────────
                Rectangle {
                    visible: booksView.isLibrarian   // ← librarian gate
                    width: 130; height: 40; radius: 8
                    color: addBtnMA.containsPress ? "#1d4ed8"
                         : addBtnMA.containsMouse ? "#2563eb"
                         : "#3b82f6"
                    Behavior on color { ColorAnimation { duration: 100 } }

                    RowLayout {
                        anchors.centerIn: parent; spacing: 8
                        Image{
                            Layout.preferredHeight: 30
                            Layout.preferredWidth: 30
                            source: "qrc:/assets/icons/addreview.png"
                            fillMode: Image.PreserveAspectFit
                        }
                        Text { text: "Add Book"; color: "#ffffff"; font.pixelSize: 13; font.bold: true }
                    }

                    MouseArea {
                        id: addBtnMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { booksView.resetForm(); booksView.showAddDialog = true }
                    }
                }
            }
        }

        // ── Filter bar ────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true; height: 64
            color: "#1a1f2e"; border.color: "#2d3748"; border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24; anchors.rightMargin: 24
                spacing: 12

                // Search
                Rectangle {
                    Layout.preferredWidth: 280; height: 40; radius: 8
                    color: "#0f1117"
                    border.color: searchInput.activeFocus ? "#3b82f6" : "#2d3748"; border.width: 1
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 8
                        Text { text: "🔍"; font.pixelSize: 14; opacity: 0.5 }
                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true; color: "#e5e7eb"; font.pixelSize: 13
                            clip: true; selectByMouse: true; verticalAlignment: TextInput.AlignVCenter
                            onTextChanged: booksView.searchText = text
                            Text { visible: !parent.text; text: "Search by title, author, ISBN..."; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }
                }

                // Genre dropdown
                Rectangle {
                    width: 140; height: 40; radius: 8
                    color: "#0f1117"; border.color: "#2d3748"; border.width: 1;
                    RowLayout { anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                        Text { Layout.fillWidth: true; text: genreCombo.currentText; color: "#e5e7eb"; font.pixelSize: 12 }
                        Text { text: "▼"; color: "#9ca3af"; font.pixelSize: 9 }
                    }
                    MouseArea { anchors.fill: parent; onClicked: genreCombo.popup.open() }
                    ComboBox {
                        id: genreCombo; visible: false
                        model: ["All Genres", "Programming", "Algorithms", "Web"]
                        onCurrentTextChanged: booksView.filterGenre = currentText === "All Genres" ? "" : currentText
                    }
                }

                // Section dropdown
                Rectangle {
                    width: 140; height: 40; radius: 8
                    color: "#0f1117"; border.color: "#2d3748"; border.width: 1
                    RowLayout { anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                        Text { Layout.fillWidth: true; text: sectionCombo.currentText; color: "#e5e7eb"; font.pixelSize: 12 }
                        Text { text: "▼"; color: "#9ca3af"; font.pixelSize: 9 }
                    }
                    MouseArea { anchors.fill: parent; onClicked: sectionCombo.popup.open() }
                    ComboBox {
                        id: sectionCombo; visible: false
                        model: ["All Sections", "CS-A", "CS-B", "CS-C", "WEB-A", "WEB-B"]
                        onCurrentTextChanged: booksView.filterSection = currentText === "All Sections" ? "" : currentText
                    }
                }

                // Availability dropdown
                Rectangle {
                    width: 140; height: 40; radius: 8
                    color: "#0f1117"; border.color: "#2d3748"; border.width: 1
                    RowLayout { anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                        Text { Layout.fillWidth: true; text: availCombo.currentText; color: "#e5e7eb"; font.pixelSize: 12 }
                        Text { text: "▼"; color: "#9ca3af"; font.pixelSize: 9 }
                    }
                    MouseArea { anchors.fill: parent; onClicked: availCombo.popup.open() }
                    ComboBox {
                        id: availCombo; visible: false
                        model: ["All", "Available", "Unavailable"]
                        onCurrentTextChanged: {
                            if (currentText === "Available")        booksView.filterAvailability = "available"
                            else if (currentText === "Unavailable") booksView.filterAvailability = "unavailable"
                            else                                    booksView.filterAvailability = "all"
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: booksView.visibleCount() + " books"
                    color: "#6b7280"; font.pixelSize: 12; font.bold: true
                }
            }
        }

        // ── Table header ──────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true; height: 44
            color: "#1a1f2e"; border.color: "#2d3748"; border.width: 1

            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24; spacing: 0
                Text { Layout.preferredWidth: 110; text: "ISBN";      color: "#9ca3af"; font.pixelSize: 11; font.bold: true; verticalAlignment: Text.AlignVCenter }
                Text { Layout.fillWidth: true;     text: "Title";     color: "#9ca3af"; font.pixelSize: 11; font.bold: true; verticalAlignment: Text.AlignVCenter }
                Text { Layout.preferredWidth: 150; text: "Author";    color: "#9ca3af"; font.pixelSize: 11; font.bold: true; verticalAlignment: Text.AlignVCenter }
                Text { Layout.preferredWidth: 100; text: "Genre";     color: "#9ca3af"; font.pixelSize: 11; font.bold: true; verticalAlignment: Text.AlignVCenter }
                Text { Layout.preferredWidth: 80;  text: "Section";   color: "#9ca3af"; font.pixelSize: 11; font.bold: true; verticalAlignment: Text.AlignVCenter }
                Text { Layout.preferredWidth: 80;  text: "Available"; color: "#9ca3af"; font.pixelSize: 11; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter }
                Text { Layout.preferredWidth: 46;  text: "Action";    color: "#9ca3af"; font.pixelSize: 11; font.bold: true; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter }
            }
        }

        // ── Table body ────────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true; Layout.fillHeight: true

            Flickable {
                id: tableFlick
                anchors.fill: parent; anchors.rightMargin: 8
                contentWidth: width; contentHeight: tableCol.implicitHeight
                clip: true; boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: tableCol
                    width: tableFlick.width
                    spacing: 0

                    Repeater {
                        model: booksModel
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: visible ? 52 : 0
                            visible: booksView.rowVisible(booksModel.get(index))
                            color: rowHover.containsMouse ? "#1e2535" : "#0f1117"
                            border.color: "#1e2535"; border.width: 1
                            Behavior on color { ColorAnimation { duration: 100 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 24; anchors.rightMargin: 24
                                spacing: 0

                                Text { Layout.preferredWidth: 110; text: model.isbn;   font.pixelSize: 12; font.bold: true; color: "#9ca3af"; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                                Text { Layout.fillWidth: true;     text: model.title;  font.pixelSize: 13; font.bold: true; color: "#ffffff";  verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                                Text { Layout.preferredWidth: 150; text: model.author; font.pixelSize: 12; color: "#9ca3af"; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                                Text { Layout.preferredWidth: 100; text: model.genre;  font.pixelSize: 12; color: "#9ca3af"; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }

                                // Section badge
                                Item {
                                    Layout.preferredWidth: 80; height: parent.height
                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 52; height: 22; radius: 4
                                        color: "#1e2535"; border.color: "#2d3748"; border.width: 1
                                        Text { anchors.centerIn: parent; text: model.section; font.pixelSize: 11; font.bold: true; color: "#e5e7eb" }
                                    }
                                }

                                // Available pill
                                Item {
                                    Layout.preferredWidth: 80; height: parent.height
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 48; height: 26; radius: 13
                                        color: booksView.availColor(model.availableCopies) + "22"
                                        Text { anchors.centerIn: parent; text: model.availableCopies; font.pixelSize: 12; font.bold: true; color: booksView.availColor(model.availableCopies) }
                                    }
                                }

                                // Eye action
                                Rectangle {
                                    Layout.preferredWidth: 46; height: 32; radius: 8
                                    color: actionMA.containsPress ? "#1e3a5f" : actionMA.containsMouse ? "#162d4a" : "transparent"
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                    Image{
                                        anchors.centerIn: parent
                                        width: 20
                                        height: 20
                                        source: "qrc:/assets/icons/eye.png"
                                        fillMode: Image.PreserveAspectFit
                                    }
                                    MouseArea {
                                        id: actionMA; anchors.fill: parent
                                        hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                        onClicked: booksView.bookSelected(model)
                                    }
                                }
                            }

                            MouseArea { id: rowHover; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                        }
                    }

                    // Empty state
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.max(200, tableFlick.height - 44)
                        color: "transparent"
                        visible: booksView.visibleCount() === 0

                        ColumnLayout {
                            anchors.centerIn: parent; spacing: 12
                            Text { Layout.alignment: Qt.AlignHCenter; text: "📚"; font.pixelSize: 48 }
                            Text { Layout.alignment: Qt.AlignHCenter; text: "No books found"; font.pixelSize: 16; font.bold: true; color: "#6b7280" }
                            Text { Layout.alignment: Qt.AlignHCenter; text: "Try adjusting your search or filters"; font.pixelSize: 13; color: "#4b5563" }
                        }
                    }
                }
            }

            // Scrollbar
            ScrollBar {
                id: vBar
                anchors.right: parent.right; anchors.rightMargin: 1
                anchors.top: parent.top; anchors.bottom: parent.bottom
                orientation: Qt.Vertical
                size: tableFlick.visibleArea.heightRatio
                position: tableFlick.visibleArea.yPosition
                width: 6; policy: ScrollBar.AsNeeded
                onPositionChanged: if (pressed) tableFlick.contentY = position * tableFlick.contentHeight
                contentItem: Rectangle { radius: 3; color: vBar.pressed ? "#9ca3af" : "#374151" }
                background: Rectangle { color: "transparent" }
            }

            Connections {
                target: tableFlick
                function onContentYChanged() { if (!vBar.pressed) vBar.position = tableFlick.contentY / tableFlick.contentHeight }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // ADD BOOK DIALOG  (librarian only — showAddDialog only set from button
    //                   which is already gated by isLibrarian)
    // ══════════════════════════════════════════════════════════════════════

    // Dim overlay
    Rectangle {
        visible: booksView.showAddDialog
        anchors.fill: parent; color: "#000000"; opacity: 0.65
        MouseArea { anchors.fill: parent; onClicked: booksView.showAddDialog = false }
    }

    // Dialog card
    Rectangle {
        visible: booksView.showAddDialog
        anchors.centerIn: parent
        width: 520
        implicitHeight: addCol.implicitHeight + 48
        radius: 12
        color: "#1a1f2e"; border.color: "#2d3748"; border.width: 1

        ColumnLayout {
            id: addCol
            anchors.fill: parent; anchors.margins: 28
            spacing: 22

            // Title row
            RowLayout {
                Layout.fillWidth: true
                Text { text: "Add New Book"; color: "#ffffff"; font.pixelSize: 18; font.bold: true }
                Item { Layout.fillWidth: true }
                Text {
                    text: "✕"; color: "#9ca3af"; font.pixelSize: 16
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: booksView.showAddDialog = false }
                }
            }

            // ISBN + Title
            RowLayout { spacing: 14; Layout.fillWidth: true
                ColumnLayout { spacing: 8; Layout.fillWidth: true
                    Text { text: "ISBN"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true; height: 40; radius: 8
                        color: "#0f1117"; border.color: isbnInput.activeFocus ? "#3b82f6" : "#2d3748"; border.width: 1
                        TextInput {
                            id: isbnInput
                            anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                            color: "#e5e7eb"; font.pixelSize: 13; clip: true; selectByMouse: true; verticalAlignment: TextInput.AlignVCenter
                            onTextChanged: booksView.formIsbn = text
                            Text { visible: !parent.text; text: "e.g. 978-12345"; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }
                }
                ColumnLayout { spacing: 8; Layout.fillWidth: true
                    Text { text: "Title"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true; height: 40; radius: 8
                        color: "#0f1117"; border.color: titleInput.activeFocus ? "#3b82f6" : "#2d3748"; border.width: 1
                        TextInput {
                            id: titleInput
                            anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                            color: "#e5e7eb"; font.pixelSize: 13; clip: true; selectByMouse: true; verticalAlignment: TextInput.AlignVCenter
                            onTextChanged: booksView.formTitle = text
                            Text { visible: !parent.text; text: "Enter book title"; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }
                }
            }

            // Author (full width)
            ColumnLayout { spacing: 8; Layout.fillWidth: true
                Text { text: "Author"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                Rectangle {
                    Layout.fillWidth: true; height: 40; radius: 8
                    color: "#0f1117"; border.color: authorInput.activeFocus ? "#3b82f6" : "#2d3748"; border.width: 1
                    TextInput {
                        id: authorInput
                        anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                        color: "#e5e7eb"; font.pixelSize: 13; clip: true; selectByMouse: true; verticalAlignment: TextInput.AlignVCenter
                        onTextChanged: booksView.formAuthor = text
                        Text { visible: !parent.text; text: "Author name(s)"; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }

            // Genre + Section + Available
            RowLayout { spacing: 14; Layout.fillWidth: true
                // Genre
                ColumnLayout { spacing: 8; Layout.fillWidth: true
                    Text { text: "Genre"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true; height: 40; radius: 8
                        color: "#0f1117"; border.color: "#2d3748"; border.width: 1
                        RowLayout { anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                            Text { Layout.fillWidth: true; text: booksView.formGenre; color: "#e5e7eb"; font.pixelSize: 12 }
                            Text { text: "▼"; color: "#9ca3af"; font.pixelSize: 9 }
                        }
                        MouseArea { anchors.fill: parent; onClicked: formGenreMenu.open() }
                        Menu {
                            id: formGenreMenu
                            MenuItem { text: "Programming"; onTriggered: booksView.formGenre = text }
                            MenuItem { text: "Algorithms";  onTriggered: booksView.formGenre = text }
                            MenuItem { text: "Web";         onTriggered: booksView.formGenre = text }
                        }
                    }
                }
                // Section
                ColumnLayout { spacing: 8; Layout.fillWidth: true
                    Text { text: "Section"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true; height: 40; radius: 8
                        color: "#0f1117"; border.color: "#2d3748"; border.width: 1
                        RowLayout { anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                            Text { Layout.fillWidth: true; text: booksView.formSection; color: "#e5e7eb"; font.pixelSize: 12 }
                            Text { text: "▼"; color: "#9ca3af"; font.pixelSize: 9 }
                        }
                        MouseArea { anchors.fill: parent; onClicked: formSectionMenu.open() }
                        Menu {
                            id: formSectionMenu
                            MenuItem { text: "CS-A";  onTriggered: booksView.formSection = text }
                            MenuItem { text: "CS-B";  onTriggered: booksView.formSection = text }
                            MenuItem { text: "CS-C";  onTriggered: booksView.formSection = text }
                            MenuItem { text: "WEB-A"; onTriggered: booksView.formSection = text }
                            MenuItem { text: "WEB-B"; onTriggered: booksView.formSection = text }
                        }
                    }
                }
                // Available copies
                ColumnLayout { spacing: 8; Layout.preferredWidth: 60
                    Text { text: "Copies"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true; height: 40; radius: 8
                        color: "#0f1117"; border.color: copiesInput.activeFocus ? "#3b82f6" : "#2d3748"; border.width: 1
                        TextInput {
                            id: copiesInput
                            anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                            color: "#e5e7eb"; font.pixelSize: 13; clip: true; selectByMouse: true; verticalAlignment: TextInput.AlignVCenter
                            inputMethodHints: Qt.ImhDigitsOnly
                            text: "1"
                            validator: IntValidator { bottom: 0; top: 999 }
                            onTextChanged: booksView.formAvailable = parseInt(text) || 0
                        }
                    }
                }
            }

            // Buttons
            RowLayout { Layout.fillWidth: true; spacing: 12
                // Cancel
                Rectangle {
                    width: 110; height: 40; radius: 6
                    color: "transparent"; border.color: "#6b7280"; border.width: 1
                    Text { anchors.centerIn: parent; text: "Cancel"; color: "#e5e7eb"; font.pixelSize: 13; font.bold: true }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: booksView.showAddDialog = false }
                }
                // Add Book — disabled until required fields filled
                Rectangle {
                    Layout.fillWidth: true; height: 40; radius: 6
                    color: (booksView.formIsbn && booksView.formTitle && booksView.formAuthor) ? "#3b82f6" : "#374151"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text { anchors.centerIn: parent; text: "Add Book"; color: "#ffffff"; font.pixelSize: 13; font.bold: true }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        enabled: booksView.formIsbn && booksView.formTitle && booksView.formAuthor
                        onClicked: {
                            booksView.addBook()
                            // clear input text fields
                            isbnInput.text = ""; titleInput.text = ""; authorInput.text = ""; copiesInput.text = "1"
                        }
                    }
                }
            }
        }
    }
}
