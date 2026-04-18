import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// Reviews.qml
Rectangle {
    id: reviewsView
    anchors.fill: parent
    color: "#0f1117"

    signal reviewSubmitted(string bookTitle, int rating, string comment)

    // ── User role (librarian or user) ─────────────────────────────────────
    property string userRole: "librarian"  // "librarian" or "user"

    // ── All books available ────────────────────────────────────────────────
    property var allBooks: [
        "Clean Code",
        "Design Patterns",
        "Effective Java",
        "The Pragmatic Programmer",
        "Introduction to Algorithms",
        "Cracking the Coding Interview",
        "You Don't Know JS",
        "Web Development with Django",
        "Eloquent JavaScript",
        "Python Crash Course"
    ]

    // ── All reviews data - use ListModel for proper reactivity ─────────────
    ListModel {
        id: reviewsModel

        ListElement {
            book: "Clean Code"
            rating: 5
            author: "John Doe"
            date: "2026-04-10"
            text: "Excellent book for learning clean coding practices. Highly recommended!"
            status: "approved"
        }
        ListElement {
            book: "Design Patterns"
            rating: 4
            author: "Jane Smith"
            date: "2026-04-11"
            text: "Great reference book, but can be dense at times."
            status: "pending"
        }
        ListElement {
            book: "Effective Java"
            rating: 5
            author: "Bob Johnson"
            date: "2026-04-08"
            text: "Must-read for Java developers. Clear and concise."
            status: "approved"
        }
        ListElement {
            book: "The Pragmatic Programmer"
            rating: 4
            author: "Alice Brown"
            date: "2026-04-12"
            text: "Good insights into software development practices."
            status: "pending"
        }
    }

    // ── Current tab state ──────────────────────────────────────────────────
    property string currentTab: "all"  // all, pending, approved

    // ── Modal state ────────────────────────────────────────────────────────
    property bool showReviewDialog: false
    property string selectedBook: allBooks.length > 0 ? allBooks[0] : ""
    property int selectedRating: 0
    property string reviewComment: ""
    property string bookSearchText: ""
    property var filteredBooks: allBooks

    // ── Update filtered books when search changes ──────────────────────────
    onBookSearchTextChanged: {
        var search = bookSearchText.toLowerCase()
        filteredBooks = allBooks.filter(function(book) {
            return book.toLowerCase().includes(search)
        })
    }

    // ── Get filtered reviews count ─────────────────────────────────────────
    function getPendingCount() {
        var count = 0
        for (var i = 0; i < reviewsModel.count; i++) {
            if (reviewsModel.get(i).status === "pending") count++
        }
        return count
    }

    // ── Submit review ──────────────────────────────────────────────────────
    function submitReview() {
        if (selectedBook && selectedRating > 0 && reviewComment) {
            reviewsModel.insert(0, {
                book: selectedBook,
                rating: selectedRating,
                author: "Current User",
                date: new Date().toISOString().split('T')[0],
                text: reviewComment,
                status: "pending"
            })
            // Reset form
            selectedBook = allBooks.length > 0 ? allBooks[0] : ""
            selectedRating = 0
            reviewComment = ""
            bookSearchText = ""
            showReviewDialog = false
            reviewSubmitted(selectedBook, selectedRating, reviewComment)
        }
    }

    // ── Approve review (librarian only) ────────────────────────────────────
    function approveReview(index) {
        if (index >= 0 && index < reviewsModel.count) {
            reviewsModel.setProperty(index, "status", "approved")
        }
    }

    // ── Reject review (librarian only) ────────────────────────────────────
    function rejectReview(index) {
        if (index >= 0 && index < reviewsModel.count) {
            reviewsModel.remove(index, 1)
        }
    }

    // ── Page header ────────────────────────────────────────────────────────
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 88
        color: "#1a1f2e"
        border.color: "#2d3748"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 28
            anchors.rightMargin: 28
            anchors.topMargin: 20
            anchors.bottomMargin: 16
            spacing: 6

            Text {
                text: "Reviews"
                color: "#ffffff"
                font.pixelSize: 24
                font.bold: true
            }

            Text {
                text: "Book reviews and ratings"
                color: "#9ca3af"
                font.pixelSize: 13
            }
        }

        // Write Review button (user only)
        Rectangle {
            visible: reviewsView.userRole === "user"
            anchors.right: parent.right
            anchors.rightMargin: 28
            anchors.verticalCenter: parent.verticalCenter
            width: 140
            height: 40
            radius: 8
            color: "#3b82f6"

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: "+"
                    color: "#ffffff"
                    font.pixelSize: 18
                    font.bold: true
                }

                Text {
                    text: "Write Review"
                    color: "#ffffff"
                    font.pixelSize: 12
                    font.bold: true
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: parent.color = "#2563eb"
                onExited: parent.color = "#3b82f6"
                onClicked: reviewsView.showReviewDialog = true
            }
        }
    }

    // ── Tabs bar (librarian only) ──────────────────────────────────────────
    Rectangle {
        visible: reviewsView.userRole === "librarian"
        anchors.top: parent.top
        anchors.topMargin: 88
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: "#0f1117"
        border.color: "#2d3748"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 28
            anchors.rightMargin: 28
            spacing: 32

            // All Reviews tab
            Rectangle {
                Layout.preferredWidth: 100
                Layout.fillHeight: true
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "All Reviews"
                        color: reviewsView.currentTab === "all" ? "#ffffff" : "#9ca3af"
                        font.pixelSize: 13
                        font.bold: reviewsView.currentTab === "all"
                    }

                    Rectangle {
                        visible: reviewsView.currentTab === "all"
                        Layout.alignment: Qt.AlignHCenter
                        width: 80; height: 3
                        radius: 1.5
                        color: "#3b82f6"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: reviewsView.currentTab = "all"
                }
            }

            // Pending tab
            Rectangle {
                Layout.preferredWidth: 160
                Layout.fillHeight: true
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10

                        Text {
                            text: "Pending"
                            color: reviewsView.currentTab === "pending" ? "#ffffff" : "#9ca3af"
                            font.pixelSize: 13
                            font.bold: reviewsView.currentTab === "pending"
                        }

                        Rectangle {
                            width: 24; height: 24
                            radius: 12
                            color: "#ef4444"
                            visible: reviewsView.getPendingCount() > 0

                            Text {
                                anchors.centerIn: parent
                                text: reviewsView.getPendingCount()
                                color: "#ffffff"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }

                    Rectangle {
                        visible: reviewsView.currentTab === "pending"
                        Layout.alignment: Qt.AlignHCenter
                        width: 80; height: 3
                        radius: 1.5
                        color: "#3b82f6"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: reviewsView.currentTab = "pending"
                }
            }

            // Approved tab
            Rectangle {
                Layout.preferredWidth: 120
                Layout.fillHeight: true
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Approved"
                        color: reviewsView.currentTab === "approved" ? "#ffffff" : "#9ca3af"
                        font.pixelSize: 13
                        font.bold: reviewsView.currentTab === "approved"
                    }

                    Rectangle {
                        visible: reviewsView.currentTab === "approved"
                        Layout.alignment: Qt.AlignHCenter
                        width: 80; height: 3
                        radius: 1.5
                        color: "#3b82f6"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: reviewsView.currentTab = "approved"
                }
            }

            Item { Layout.fillWidth: true }
        }
    }

    // ── Reviews list ───────────────────────────────────────────────────────
    Flickable {
        id: reviewsFlick
        anchors.top: parent.top
        anchors.topMargin: reviewsView.userRole === "librarian" ? 148 : 88
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 1
        anchors.rightMargin: 8
        anchors.bottomMargin: 1
        contentWidth: width
        contentHeight: reviewsCol.implicitHeight + 40
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: reviewsCol
            width: reviewsFlick.width - 8
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            anchors.topMargin: 24
            spacing: 16

            // Review cards using Repeater with ListModel
            Repeater {
                id: reviewRepeater
                model: reviewsModel

                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: 160
                    radius: 10
                    color: "#1a1f2e"
                    border.color: "#2d3748"
                    border.width: 1
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 0

                        // First row: Book title + stars + status
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            height: 26

                            Text {
                                text: model.book
                                color: "#ffffff"
                                font.pixelSize: 15
                                font.bold: true
                                font.weight: Font.Bold
                            }

                            // Star rating
                            RowLayout {
                                spacing: 0
                                Repeater {
                                    model: 5
                                    delegate: Text {
                                        text: index < reviewRepeater.model.get(reviewRepeater.currentIndex).rating ? "⭐" : "☆"
                                        font.pixelSize: 12
                                        color: index < reviewRepeater.model.get(reviewRepeater.currentIndex).rating ? "#fbbf24" : "#6b7280"
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true }

                            // Status badge
                            Rectangle {
                                width: 80; height: 24
                                radius: 4
                                color: model.status === "approved" ? "#065f46" : "#7c2d12"

                                Text {
                                    anchors.centerIn: parent
                                    text: model.status
                                    color: model.status === "approved" ? "#10b981" : "#f97316"
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }
                        }

                        // Second row: Author and date
                        Text {
                            Layout.topMargin: 6
                            text: "by " + model.author + " • " + model.date
                            color: "#9ca3af"
                            font.pixelSize: 12
                        }

                        // Third row: Review text
                        Text {
                            Layout.fillWidth: true
                            Layout.topMargin: 8
                            text: model.text
                            color: "#e5e7eb"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            lineHeight: 1.4
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        Item { Layout.fillHeight: true }

                        // Action buttons (librarian only, pending reviews)
                        RowLayout {
                            visible: reviewsView.userRole === "librarian" && model.status === "pending"
                            Layout.fillWidth: true
                            height: 28
                            spacing: 10

                            Item { Layout.fillWidth: true }

                            // Approve button
                            Rectangle {
                                width: 28; height: 28
                                radius: 5
                                color: approveMA.containsPress ? "#10b98140"
                                     : approveMA.containsMouse ? "#10b98130"
                                     : "transparent"
                                border.color: "#10b981"
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "✓"
                                    color: "#10b981"
                                    font.pixelSize: 14
                                    font.bold: true
                                }

                                MouseArea {
                                    id: approveMA
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: reviewsView.approveReview(index)
                                }
                            }

                            // Reject button
                            Rectangle {
                                width: 28; height: 28
                                radius: 5
                                color: rejectMA.containsPress ? "#ef444440"
                                     : rejectMA.containsMouse ? "#ef444430"
                                     : "transparent"
                                border.color: "#ef4444"
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "✕"
                                    color: "#ef4444"
                                    font.pixelSize: 14
                                    font.bold: true
                                }

                                MouseArea {
                                    id: rejectMA
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: reviewsView.rejectReview(index)
                                }
                            }
                        }
                    }

                    // Filter by tab
                    visible: {
                        if (reviewsView.currentTab === "pending") return model.status === "pending"
                        if (reviewsView.currentTab === "approved") return model.status === "approved"
                        return true
                    }
                }
            }

            Item { height: 12 }
        }
    }

    // Vertical scrollbar
    ScrollBar {
        id: vBar
        anchors.right: parent.right
        anchors.rightMargin: 1
        anchors.top: reviewsFlick.top
        anchors.bottom: parent.bottom
        orientation: Qt.Vertical
        size: reviewsFlick.visibleArea.heightRatio
        position: reviewsFlick.visibleArea.yPosition
        width: 6
        policy: ScrollBar.AsNeeded

        onPositionChanged: {
            if (pressed) reviewsFlick.contentY = position * reviewsFlick.contentHeight
        }

        contentItem: Rectangle {
            radius: 3
            color: vBar.pressed ? "#9ca3af" : "#4b5563"
        }
    }

    Connections {
        target: reviewsFlick
        function onContentYChanged() {
            if (!vBar.pressed) vBar.position = reviewsFlick.contentY / reviewsFlick.contentHeight
        }
    }

    // ── Modal overlay ──────────────────────────────────────────────────────
    Rectangle {
        visible: reviewsView.showReviewDialog
        anchors.fill: parent
        color: "#000000"
        opacity: 0.6

        MouseArea {
            anchors.fill: parent
            onClicked: reviewsView.showReviewDialog = false
        }
    }

    // ── Submit Review Dialog ───────────────────────────────────────────────
    Rectangle {
        visible: reviewsView.showReviewDialog
        anchors.centerIn: parent
        width: Math.min(520, parent.width - 48)
        implicitHeight: dialogCol.implicitHeight + 44
        radius: 12
        color: "#1a1f2e"
        border.color: "#2d3748"
        border.width: 1

        ColumnLayout {
            id: dialogCol
            anchors.fill: parent
            anchors.margins: 28
            spacing: 24

            // Title
            Text {
                text: "Submit a Review"
                color: "#ffffff"
                font.pixelSize: 18
                font.bold: true
            }

            // Book selection - AT THE TOP
            ColumnLayout {
                spacing: 10

                Text {
                    text: "Book"
                    color: "#e5e7eb"
                    font.pixelSize: 13
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: 8
                    color: "#0f1117"
                    border.color: bookCombo.activeFocus ? "#3b82f6" : "#2d3748"
                    border.width: 1

                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        Text {
                            text: "📖"
                            font.pixelSize: 16
                            opacity: 0.6
                        }

                        TextInput {
                            id: bookCombo
                            Layout.fillWidth: true
                            color: "#e5e7eb"
                            font.pixelSize: 13
                            clip: true
                            selectByMouse: true
                            verticalAlignment: TextInput.AlignVCenter
                            text: reviewsView.selectedBook

                            onTextChanged: reviewsView.bookSearchText = text

                            Text {
                                visible: !parent.text
                                text: "Select a book"
                                color: "#6b7280"
                                font: parent.font
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // Dropdown list
                    Rectangle {
                        visible: bookCombo.activeFocus && reviewsView.filteredBooks.length > 0
                        anchors.top: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.topMargin: 6
                        implicitHeight: Math.min(200, bookListCol.implicitHeight)
                        radius: 8
                        color: "#0f1117"
                        border.color: "#2d3748"
                        border.width: 1
                        z: 100

                        Flickable {
                            anchors.fill: parent
                            contentWidth: width
                            contentHeight: bookListCol.implicitHeight
                            clip: true

                            ColumnLayout {
                                id: bookListCol
                                width: parent.width
                                spacing: 0

                                Repeater {
                                    model: reviewsView.filteredBooks
                                    delegate: Rectangle {
                                        Layout.fillWidth: true
                                        height: 40
                                        color: dropMA.containsMouse ? "#2d3748" : "transparent"

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            anchors.leftMargin: 14
                                            text: modelData
                                            color: "#e5e7eb"
                                            font.pixelSize: 13
                                        }

                                        MouseArea {
                                            id: dropMA
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                reviewsView.selectedBook = modelData
                                                bookCombo.text = modelData
                                                bookCombo.focus = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Star rating
            ColumnLayout {
                spacing: 10

                Text {
                    text: "Rating"
                    color: "#e5e7eb"
                    font.pixelSize: 13
                    font.bold: true
                }

                RowLayout {
                    spacing: 12

                    Repeater {
                        model: 5
                        delegate: Text {
                            text: "☆"
                            font.pixelSize: 32
                            color: (index + 1) <= reviewsView.selectedRating ? "#fbbf24" : "#6b7280"

                            Behavior on color { ColorAnimation { duration: 120 } }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: reviewsView.selectedRating = index + 1
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }
                }
            }

            // Comment textarea
            ColumnLayout {
                spacing: 10

                Text {
                    text: "Comment"
                    color: "#e5e7eb"
                    font.pixelSize: 13
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 110
                    radius: 8
                    color: "#0f1117"
                    border.color: commentInput.activeFocus ? "#3b82f6" : "#2d3748"
                    border.width: 1

                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    TextEdit {
                        id: commentInput
                        anchors.fill: parent
                        anchors.margins: 12
                        color: "#e5e7eb"
                        font.pixelSize: 13
                        clip: true
                        selectByMouse: true
                        verticalAlignment: TextEdit.AlignTop
                        wrapMode: TextEdit.WordWrap
                        text: reviewsView.reviewComment

                        onTextChanged: reviewsView.reviewComment = text

                        Text {
                            visible: !parent.text
                            text: "Share your thoughts about this book..."
                            color: "#6b7280"
                            font: parent.font
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: 4 }

            // Action buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 110
                    height: 40
                    radius: 6
                    color: "transparent"
                    border.color: "#6b7280"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: "#e5e7eb"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: reviewsView.showReviewDialog = false
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 6
                    color: (reviewsView.selectedBook && reviewsView.selectedRating > 0 && reviewsView.reviewComment) ?
                           "#3b82f6" : "#6b7280"

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Submit Review"
                        color: "#ffffff"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: (reviewsView.selectedBook && reviewsView.selectedRating > 0 && reviewsView.reviewComment)
                        onClicked: reviewsView.submitReview()
                    }
                }
            }
        }
    }
}
