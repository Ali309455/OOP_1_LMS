import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// Reviews.qml
Rectangle {
    id: reviewsView
    color: "#0f1117"

    property var rData: [];

    signal reviewSubmitted(string bookTitle, int rating, string comment)

    property string userRole: "librarian"

    property var allBooks: []

    ListModel {
        id: reviewsModel/*
        ListElement { book: "Clean Code";             rating: 5; author: "John Doe";    date: "2026-04-10"; text: "Excellent book for learning clean coding practices. Highly recommended!"; status: "approved" }
        ListElement { book: "Design Patterns";        rating: 4; author: "Jane Smith";  date: "2026-04-11"; text: "Great reference book, but can be dense at times.";                       status: "pending"  }
        ListElement { book: "Effective Java";         rating: 5; author: "Bob Johnson"; date: "2026-04-08"; text: "Must-read for Java developers. Clear and concise.";                       status: "approved" }
        ListElement { book: "The Pragmatic Programmer"; rating: 4; author: "Alice Brown"; date: "2026-04-12"; text: "Good insights into software development practices.";                   status: "pending"  }*/
    }

    Component.onCompleted: {
        if (lms !== null && lms !== undefined) {
            console.log("Calling getReviews...");
            rData = lms.getReviews();
        } else {
            console.log("ERROR: lms is NULL");
        }

        reviewsModel.clear()

        for (let i = 0; i < rData.length; i++) {
            reviewsModel.append(rData[i])
        }

        // LOAD BOOKS FROM DATABASE
        let booksData = lms.getBooks()

        allBooks = []

        for (let j = 0; j < booksData.length; j++) {
            allBooks.push(booksData[j].title)
        }

        filteredBooks = allBooks
    }

    property string currentTab: "all"
    property bool   showReviewDialog: false
    property string selectedBook: allBooks.length > 0 ? allBooks[0] : ""
    property int    selectedRating: 0
    property string reviewComment: ""
    property string bookSearchText: ""
    property var    filteredBooks: allBooks

    onBookSearchTextChanged: {
        var s = bookSearchText.toLowerCase()
        filteredBooks = allBooks.filter(function(b) { return b.toLowerCase().includes(s) })
    }

    function getPendingCount() {
        var c = 0
        for (var i = 0; i < reviewsModel.count; i++)
            if (reviewsModel.get(i).status === "pending") c++
        return c
    }

    function submitReview() {

        if (!selectedBook || selectedRating <= 0 || !reviewComment)
            return

        // FIND ISBN FROM BOOK TITLE
        let booksData = lms.getBooks()

        let selectedIsbn = ""

        for (let i = 0; i < booksData.length; i++) {

            if (booksData[i].title === selectedBook) {
                selectedIsbn = booksData[i].isbn
                break
            }
        }

        if (selectedIsbn === "") {
            console.log("ISBN NOT FOUND")
            return
        }

        // SEND TO BACKEND
        let ok = lms.submitReview(
                    selectedIsbn,
                    selectedRating,
                    reviewComment
                    )

        if (ok) {

            console.log("Review submitted")

            // RELOAD REVIEWS
            rData = lms.getReviews()

            reviewsModel.clear()

            for (let j = 0; j < rData.length; j++) {
                reviewsModel.append(rData[j])
            }

            // RESET
            selectedRating = 0
            reviewComment = ""
            bookSearchText = ""
            selectedBook = ""

            showReviewDialog = false
            successPopup.visible = true
        } else {

            console.log("Review submission failed")
        }
    }

    function approveReview(idx) {
        if (idx >= 0 && idx < reviewsModel.count) {
            let review = reviewsModel.get(idx)

            if (lms && lms.approveReview(review.reviewId)) {
                reviewsModel.setProperty(idx, "status", "approved")
            } else {
                console.log("Approve failed")
            }
        }
    }
    function rejectReview(idx) {
        if (idx >= 0 && idx < reviewsModel.count) {
            let review = reviewsModel.get(idx)

            if (lms && lms.deleteReview(review.reviewId)) {
                reviewsModel.remove(idx, 1)
            } else {
                console.log("Delete failed")
            }
        }
    }

    // ── Page header ────────────────────────────────────────────────────────
    Rectangle {
        id: headerBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 88
        color: "#1a1f2e"
        border.color: "#2d3748"; border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 28; anchors.rightMargin: 28
            anchors.topMargin: 20; anchors.bottomMargin: 16
            spacing: 6
            Text { text: "Reviews"; color: "#ffffff"; font.pixelSize: 24; font.bold: true }
            Text { text: "Book reviews and ratings"; color: "#9ca3af"; font.pixelSize: 13 }
        }

        Rectangle {
            visible: reviewsView.userRole === "student"
            anchors.right: parent.right; anchors.rightMargin: 28
            anchors.verticalCenter: parent.verticalCenter
            width: 148; height: 40; radius: 8
            color: writeMA.containsPress ? "#1d4ed8" : writeMA.containsMouse ? "#2563eb" : "#3b82f6"
            Behavior on color { ColorAnimation { duration: 100 } }
            RowLayout { anchors.centerIn: parent; spacing: 8
                Text { text: "+"; color: "#ffffff"; font.pixelSize: 18; font.bold: true }
                Text { text: "Write Review"; color: "#ffffff"; font.pixelSize: 12; font.bold: true }
            }
            MouseArea { id: writeMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: reviewsView.showReviewDialog = true }
        }
    }

    // ── Tabs bar (librarian only) ──────────────────────────────────────────
    Rectangle {
        id: tabsBar
        visible: reviewsView.userRole === "librarian"
        anchors.top: headerBar.bottom
        anchors.left: parent.left; anchors.right: parent.right
        height: 52
        color: "#0f1117"
        border.color: "#2d3748"; border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 28; anchors.rightMargin: 28
            spacing: 0

            // helper tab component inline via Repeater
            Repeater {
                model: [
                    { key: "all",      label: "All Reviews", showBadge: false },
                    { key: "pending",  label: "Pending",     showBadge: true  },
                    { key: "approved", label: "Approved",    showBadge: false }
                ]

                delegate: Rectangle {
                    Layout.preferredWidth: 140
                    Layout.fillHeight: true
                    color: "transparent"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 8

                            Text {
                                text: modelData.label
                                color: reviewsView.currentTab === modelData.key ? "#ffffff" : "#9ca3af"
                                font.pixelSize: 13
                                font.bold: reviewsView.currentTab === modelData.key
                            }

                            Rectangle {
                                visible: modelData.showBadge && reviewsView.getPendingCount() > 0
                                width: 22; height: 22; radius: 11
                                color: "#ef4444"
                                Text { anchors.centerIn: parent; text: reviewsView.getPendingCount(); color: "#ffffff"; font.pixelSize: 10; font.bold: true }
                            }
                        }

                        Rectangle {
                            visible: reviewsView.currentTab === modelData.key
                            Layout.alignment: Qt.AlignHCenter
                            width: 80; height: 3; radius: 1.5
                            color: "#3b82f6"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: reviewsView.currentTab = modelData.key
                    }
                }
            }

            Item { Layout.fillWidth: true }
        }
    }

    // ── Review list — Flickable with real draggable scrollbar ──────────────
    // Same pattern as LibrarianDashboard: Flickable + external ScrollBar
    Flickable {
        id: reviewsFlick
        anchors.top: reviewsView.userRole === "librarian" ? tabsBar.bottom : headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 0
        anchors.rightMargin: 32          // leave room for the draggable scrollbar
        contentWidth: width
        contentHeight: reviewsCol.implicitHeight + 48
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: reviewsCol
            width: reviewsFlick.width
            anchors.leftMargin: 28
            anchors.rightMargin: 28
            spacing: 14

            Item { height: 12 }

            Repeater {
                id: reviewRepeater
                model: reviewsModel

                delegate: Rectangle {
                    Layout.fillWidth: true
                    height: visible ? implicitHeight : 0
                    implicitHeight: cardCol.implicitHeight + 32
                    radius: 10
                    color: "#1a1f2e"
                    border.color: "#2d3748"; border.width: 1
                    clip: true

                    visible: {
                        if (reviewsView.currentTab === "pending")
                            return model.status === "pending"

                        if (reviewsView.currentTab === "approved")
                            return model.status === "approved"

                        if (reviewsView.userRole === "student")
                            return model.status === "approved"

                        return true
                    }

                    ColumnLayout {
                        id: cardCol
                        anchors { fill: parent; margins: 18 }
                        spacing: 0

                        // Row 1: title + stars + badge
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Text {
                                text: model.book ? model.book : model.bookname
                                color: "#ffffff"; font.pixelSize: 15; font.bold: true
                            }

                            RowLayout {
                                spacing: 1
                                Repeater {
                                    model: 5
                                    delegate: Text {
                                        property int starIdx: index
                                        text: starIdx < reviewsModel.get(reviewRepeater.currentIndex >= 0 ? reviewRepeater.currentIndex : 0).rating ? "⭐" : "☆"
                                        font.pixelSize: 12
                                        color: starIdx < reviewsModel.get(reviewRepeater.currentIndex >= 0 ? reviewRepeater.currentIndex : 0).rating ? "#fbbf24" : "#4b5563"
                                    }
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                width: 82; height: 26; radius: 5
                                color: model.status === "approved" ? "#052e16" : "#7c2d12"
                                border.color: model.status === "approved" ? "#10b981" : "#f97316"; border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: model.status
                                    color: model.status === "approved" ? "#10b981" : "#f97316"
                                    font.pixelSize: 11; font.bold: true
                                }
                            }
                        }

                        // Row 2: author + date
                        Text {
                            Layout.topMargin: 8
                            text: "by " + model.author + "  •  " + model.date
                            color: "#9ca3af"; font.pixelSize: 12
                        }

                        // Divider
                        Rectangle { Layout.fillWidth: true; height: 1; color: "#2d3748"; Layout.topMargin: 10 }

                        // Row 3: review text
                        Text {
                            Layout.fillWidth: true
                            Layout.topMargin: 10
                            text: model.text
                            color: "#e5e7eb"; font.pixelSize: 13
                            wrapMode: Text.WordWrap; lineHeight: 1.5
                        }

                        // Row 4: action buttons (librarian + pending only)
                        RowLayout {
                            visible: reviewsView.userRole === "librarian" && model.status === "pending"
                            Layout.fillWidth: true
                            Layout.topMargin: 12
                            spacing: 10

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                width: 32; height: 32; radius: 6
                                color: approveMA.containsPress ? "#10b98140" : approveMA.containsMouse ? "#10b98125" : "transparent"
                                border.color: "#10b981"; border.width: 1
                                Behavior on color { ColorAnimation { duration: 100 } }
                                Text { anchors.centerIn: parent; text: "✓"; color: "#10b981"; font.pixelSize: 16; font.bold: true }
                                MouseArea { id: approveMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: reviewsView.approveReview(index) }
                            }

                            Rectangle {
                                width: 32; height: 32; radius: 6
                                color: rejectMA.containsPress ? "#ef444440" : rejectMA.containsMouse ? "#ef444425" : "transparent"
                                border.color: "#ef4444"; border.width: 1
                                Behavior on color { ColorAnimation { duration: 100 } }
                                Text { anchors.centerIn: parent; text: "✕"; color: "#ef4444"; font.pixelSize: 16; font.bold: true }
                                MouseArea { id: rejectMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: reviewsView.rejectReview(index) }
                            }
                        }
                    }
                }
            }

            Item { height: 16 }
        }
    }

    // ── Draggable scrollbar — identical pattern to LibrarianDashboard ──────
    Rectangle {
        id: scrollTrack
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.top: reviewsFlick.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 8; anchors.bottomMargin: 8
        width: 6
        radius: 3
        color: "#1e2535"
        visible: reviewsFlick.contentHeight > reviewsFlick.height

        // Thumb
        Rectangle {
            id: scrollThumb
            width: parent.width
            radius: 3
            color: thumbMA.pressed ? "#9ca3af" : thumbMA.containsMouse ? "#6b7280" : "#374151"
            Behavior on color { ColorAnimation { duration: 100 } }

            // height and y are two-way bound to the Flickable
            height: Math.max(32, scrollTrack.height * (reviewsFlick.height / reviewsFlick.contentHeight))
            y: reviewsFlick.contentY / reviewsFlick.contentHeight * scrollTrack.height

            MouseArea {
                id: thumbMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.SizeVerCursor
                preventStealing: true

                property real pressY: 0
                property real pressContentY: 0

                onPressed: {
                    pressY = mouseY
                    pressContentY = reviewsFlick.contentY
                }

                onPositionChanged: {
                    if (pressed) {
                        var delta = mouseY - pressY
                        var ratio = delta / scrollTrack.height
                        var newY = pressContentY + ratio * reviewsFlick.contentHeight
                        reviewsFlick.contentY = Math.max(0, Math.min(newY, reviewsFlick.contentHeight - reviewsFlick.height))
                    }
                }
            }
        }

        // Click on track (jump to position)
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var ratio = mouseY / scrollTrack.height
                reviewsFlick.contentY = Math.max(0, Math.min(ratio * reviewsFlick.contentHeight, reviewsFlick.contentHeight - reviewsFlick.height))
            }
        }
    }

    // ── Modal overlay ──────────────────────────────────────────────────────
    Rectangle {
        visible: reviewsView.showReviewDialog
        anchors.fill: parent; color: "#000000"; opacity: 0.65
        MouseArea { anchors.fill: parent; onClicked: reviewsView.showReviewDialog = false }
    }

    // ── Submit Review Dialog ───────────────────────────────────────────────
    Rectangle {
        visible: reviewsView.showReviewDialog
        anchors.centerIn: parent
        width: Math.min(520, parent.width - 48)
        implicitHeight: dialogCol.implicitHeight + 48
        radius: 12
        color: "#1a1f2e"; border.color: "#2d3748"; border.width: 1

        ColumnLayout {
            id: dialogCol
            anchors.fill: parent; anchors.margins: 28
            spacing: 22

            RowLayout {
                Layout.fillWidth: true
                Text { text: "Submit a Review"; color: "#ffffff"; font.pixelSize: 18; font.bold: true }
                Item { Layout.fillWidth: true }
                Text { text: "✕"; color: "#9ca3af"; font.pixelSize: 16
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: reviewsView.showReviewDialog = false } }
            }

            // ================= BOOK PICKER =================
            Item {
                Layout.fillWidth: true
                height: 260
                z: 9999

                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: "Book"
                        color: "#e5e7eb"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Rectangle {
                        id: bookField
                        width: parent.width
                        height: 44
                        radius: 8
                        color: "#0f1117"
                        border.color: bookInput.activeFocus ? "#3b82f6" : "#2d3748"
                        border.width: 1
                        z: 9999

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 10

                            Text {
                                text: "📖"
                                font.pixelSize: 16
                                opacity: 0.7
                            }

                            TextInput {
                                id: bookInput
                                Layout.fillWidth: true
                                color: "#e5e7eb"
                                font.pixelSize: 13
                                verticalAlignment: TextInput.AlignVCenter
                                clip: true
                                selectByMouse: true

                                text: reviewsView.selectedBook

                                onTextChanged: {
                                    reviewsView.bookSearchText = text
                                }

                                Text {
                                    visible: !parent.text
                                    text: "Search book..."
                                    color: "#6b7280"
                                    font: parent.font
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }

                    // ================= DROPDOWN =================
                    Rectangle {
                        id: resultsDropdown

                        visible: bookInput.activeFocus
                                 && reviewsView.filteredBooks.length > 0

                        width: parent.width
                        height: Math.min(220, booksColumn.implicitHeight)

                        radius: 10
                        color: "#111827"

                        border.color: "#3b82f6"
                        border.width: 1

                        clip: true
                        z: 10000

                        Flickable {
                            anchors.fill: parent
                            contentWidth: width
                            contentHeight: booksColumn.implicitHeight
                            clip: true

                            Column {
                                id: booksColumn
                                width: parent.width
                                spacing: 0

                                Repeater {
                                    model: reviewsView.filteredBooks

                                    delegate: Rectangle {

                                        width: parent.width
                                        height: 42

                                        color: itemMouse.containsMouse
                                               ? "#1e293b"
                                               : "#111827"

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            anchors.leftMargin: 14

                                            text: modelData
                                            color: "#f9fafb"
                                            font.pixelSize: 13
                                        }

                                        MouseArea {
                                            id: itemMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor

                                            onClicked: {

                                                reviewsView.selectedBook = modelData
                                                bookInput.text = modelData

                                                bookInput.focus = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            // // Book picker
            // ColumnLayout { spacing: 8
            //     Text { text: "Book"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
            //     Rectangle {
            //         Layout.fillWidth: true; height: 44; radius: 8
            //         color: "#0f1117"
            //         border.color: bookInput.activeFocus ? "#3b82f6" : "#2d3748"; border.width: 1
            //         Behavior on border.color { ColorAnimation { duration: 150 } }

            //         RowLayout {
            //             anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 10
            //             Text { text: "📖"; font.pixelSize: 16; opacity: 0.6 }
            //             TextInput {
            //                 id: bookInput
            //                 Layout.fillWidth: true; color: "#e5e7eb"; font.pixelSize: 13
            //                 clip: true; selectByMouse: true; verticalAlignment: TextInput.AlignVCenter
            //                 text: reviewsView.selectedBook
            //                 onTextChanged: reviewsView.bookSearchText = text
            //                 Text { visible: !parent.text; text: "Select a book"; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
            //             }
            //         }
            //         // Drop-down
            //         Rectangle {
            //             id: resultsDropdown
            //             visible: bookInput.activeFocus && reviewsView.filteredBooks.length > 0
            //             anchors.top: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
            //             anchors.topMargin: 6
            //             height: Math.min(220, dropList.implicitHeight)
            //             radius: 8; color: "#111827"; border.color: "#3b82f6"; border.width: 1
            //             z: 9999; clip: true

            //             Flickable {
            //                 anchors.fill: parent; contentWidth: width
            //                 contentHeight: dropList.implicitHeight; clip: true

            //                 ColumnLayout {
            //                     id: dropList; width: parent.width; spacing: 0
            //                     Repeater {
            //                         model: reviewsView.filteredBooks
            //                         delegate: Rectangle {
            //                             Layout.fillWidth: true; height: 40
            //                             color: dMA.containsMouse ? "#2d3748" : "transparent"
            //                             Text { anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: 14; text: modelData; color: "#e5e7eb"; font.pixelSize: 13 }
            //                             MouseArea {
            //                                 id: dMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            //                                 onClicked: { reviewsView.selectedBook = modelData; bookInput.text = modelData; bookInput.focus = false }
            //                             }
            //                         }
            //                     }
            //                 }
            //             }
            //         }

            // Star rating
            ColumnLayout {
                visible: !bookInput.activeFocus
                spacing: 8
                Text { text: "Rating"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                RowLayout { spacing: 10
                    Repeater {
                        model: 5
                        delegate: Text {
                            text: "☆"; font.pixelSize: 30
                            color: (index + 1) <= reviewsView.selectedRating ? "#fbbf24" : "#4b5563"
                            Behavior on color { ColorAnimation { duration: 120 } }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: reviewsView.selectedRating = index + 1 }
                        }
                    }
                    Item { Layout.fillWidth: true }
                }
            }

            // Comment
            ColumnLayout {
                visible: !bookInput.activeFocus
                spacing: 8
                Text { text: "Comment"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                Rectangle {
                    Layout.fillWidth: true; height: 110; radius: 8
                    color: "#0f1117"
                    border.color: commentEdit.activeFocus ? "#3b82f6" : "#2d3748"; border.width: 1
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    TextEdit {
                        id: commentEdit; anchors.fill: parent; anchors.margins: 12
                        color: "#e5e7eb"; font.pixelSize: 13; wrapMode: TextEdit.WordWrap
                        clip: true; selectByMouse: true
                        text: reviewsView.reviewComment
                        onTextChanged: reviewsView.reviewComment = text
                        Text { visible: !parent.text; text: "Share your thoughts about this book..."; color: "#6b7280"; font: parent.font }
                    }
                }
            }

            Item { Layout.preferredHeight: 2 }

            // Buttons
            RowLayout { Layout.fillWidth: true; spacing: 12
                Rectangle {
                    width: 110; height: 42; radius: 6; color: "transparent"; border.color: "#6b7280"; border.width: 1
                    Text { anchors.centerIn: parent; text: "Cancel"; color: "#e5e7eb"; font.pixelSize: 13; font.bold: true }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: reviewsView.showReviewDialog = false }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 42; radius: 6
                    color: (reviewsView.selectedBook && reviewsView.selectedRating > 0 && reviewsView.reviewComment) ? "#3b82f6" : "#374151"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text { anchors.centerIn: parent; text: "Submit Review"; color: "#ffffff"; font.pixelSize: 13; font.bold: true }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        enabled: reviewsView.selectedBook !== "" && reviewsView.selectedRating > 0 && reviewsView.reviewComment.trim() !== ""
                        onClicked: {
                            reviewsView.submitReview()
                            bookInput.text = ""
                            commentEdit.text = ""
                        }
                    }
                }
            }
        }
    }
    // --- Success Message Popup (Paste before the very last '}') ---
        Rectangle {
            id: successPopup
            visible: false
            anchors.fill: parent; color: "#cc000000"; z: 10000
            Rectangle {
                anchors.centerIn: parent; width: 320; height: 180; radius: 12; color: "#1a1f2e"; border.color: "#3b82f6"
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 20; spacing: 10
                    Text { text: "✅ Success!"; color: "#10b981"; font.pixelSize: 20; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "Review submitted successfully!\nWaiting for Admin's approval!!"; color: "white"; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                    Button {
                        text: "OK"; Layout.alignment: Qt.AlignHCenter
                        onClicked: successPopup.visible = false
                    }
                }
            }
        }
}

