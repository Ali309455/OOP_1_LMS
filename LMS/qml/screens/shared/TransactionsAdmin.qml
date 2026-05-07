import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import LMS
Rectangle {
    id: root
    color: "#0b1220"
    property var txData: lms.getTransactions();
    property var booksData: lms.getBooks();
    property var usersData: lms.getUsers();
    property var currentUser: null;
    // ── Theme ──────────────────────────────────────────────────────────────
    readonly property color cardBg:      "#171e2f"
    readonly property color borderColor: "#2a3350"
    readonly property color textPrimary: "#ffffff"
    readonly property color textMuted:   "#9aa4bf"
    readonly property color headerBg: "#1b2338"
    property string studentSearchText: ""
    property string bookSearchText: ""
    // ── Filter state ───────────────────────────────────────────────────────
    property string searchText:   ""
    property string statusFilter: "All Status"

    // ── Dialog state ───────────────────────────────────────────────────────
    property bool showStudentDropdown: false
    property bool showBookDropdown: false
    property bool showIssueDialog:  false
    property bool showReturnDialog: false

    // Issue form
    property string issueStudent:    ""
    property string issueStudentId:  ""
    property string selectBook:       ""
    property string issueIsbn:       ""
    property string issueDate:       ""
    property string issueDueDate:    ""
    property string issueMsg:        ""
    property bool   issueSuccess:    false

    // Return form
    property string returnTxnId:    ""
    property string returnMsg:      ""
    property bool   returnSuccess:  false

    // ── Available students & books for dropdowns ───────────────────────────
    ListModel {
      id: students
    }
    ListModel {
      id: booksModel
    }

    // ── Transaction data ───────────────────────────────────────────────────
    ListModel {
        id: txModel
    //     ListElement { txnId: "TXN-1245"; student: "John Doe";    sId: "S001"; book: "Clean Code";                 isbn: "978-0132350884"; issueDate: "2026-04-01"; dueDate: "2026-04-15"; returnDate: "-";          fine: "-";   status: "active"   }
    //     ListElement { txnId: "TXN-1244"; student: "Jane Smith";  sId: "S002"; book: "Design Patterns";            isbn: "978-0201633612"; issueDate: "2026-03-28"; dueDate: "2026-04-11"; returnDate: "2026-04-10"; fine: "-";   status: "returned" }
    //     ListElement { txnId: "TXN-1243"; student: "Bob Johnson"; sId: "S003"; book: "Effective Java";             isbn: "978-0134685991"; issueDate: "2026-03-25"; dueDate: "2026-04-08"; returnDate: "-";          fine: "$15"; status: "overdue"  }
    //     ListElement { txnId: "TXN-1242"; student: "John Doe";    sId: "S001"; book: "The Pragmatic Programmer";   isbn: "978-0137081073"; issueDate: "2026-04-05"; dueDate: "2026-04-19"; returnDate: "-";          fine: "-";   status: "active"   }
    //     ListElement { txnId: "TXN-1241"; student: "Alice Brown"; sId: "S004"; book: "Introduction to Algorithms"; isbn: "978-0262033848"; issueDate: "2026-03-20"; dueDate: "2026-04-03"; returnDate: "-";          fine: "$30"; status: "overdue"  }
     }
    function transactiondatafetching(){
        txModel.clear()

    for (let i = 0; i < txData.length; i++) {
        txModel.append(txData[i])
    }
}
    Component.onCompleted: {
        transactiondatafetching();
        for(let j =0; j<usersData.length; j++){
            students.append(usersData[j]);
        }
        for(let k =0; k<booksData.length; k++){
            booksModel.append(booksData[k]);
        }
    }

    // ── Next TXN ID counter ────────────────────────────────────────────────
    property int nextTxnNum: 1246

    // ── Row filter ─────────────────────────────────────────────────────────
    function rowVisible(item) {
        if (statusFilter !== "All Status" && item.status !== statusFilter) return false
        if (searchText.length > 0) {
            var s = searchText.toLowerCase()
            if (!item.txnId.toLowerCase().includes(s)   &&
                !item.student.toLowerCase().includes(s) &&
                !item.book.toLowerCase().includes(s))   return false
        }
        return true
    }

    function countByStatus(st) {
        var c = 0
        for (var i = 0; i < txModel.count; i++)
            if (txModel.get(i).status === st) c++
        return c
    }

    // ── Today helper ───────────────────────────────────────────────────────
    function todayStr() {
        var d = new Date()
        var m = d.getMonth() + 1
        var day = d.getDate()
        return d.getFullYear() + "-" + (m < 10 ? "0" + m : m) + "-" + (day < 10 ? "0" + day : day)
    }

    function dueDateStr(days) {
        var d = new Date()
        d.setDate(d.getDate() + days)
        var m = d.getMonth() + 1
        var day = d.getDate()
        return d.getFullYear() + "-" + (m < 10 ? "0" + m : m) + "-" + (day < 10 ? "0" + day : day)
    }

    // ── Fine calculator (Rs 10 / day overdue) ─────────────────────────────
    function calcFine(dueDateString) {
        var parts = dueDateString.split("-")
        if (parts.length !== 3) return "-"
        var due = new Date(parseInt(parts[0]), parseInt(parts[1]) - 1, parseInt(parts[2]))
        var today = new Date()
        today.setHours(0, 0, 0, 0)
        due.setHours(0, 0, 0, 0)
        var diff = Math.floor((today - due) / (1000 * 60 * 60 * 24))
        return diff > 0 ? "$" + (diff * 10) : "-"
    }

    // ── Issue Book logic ───────────────────────────────────────────────────
    function issueBook() {
        if (!issueStudent)  { issueMsg = "Please select a student."; issueSuccess = false; return }
        if (!issueBook)     { issueMsg = "Please select a book.";    issueSuccess = false; return }

        // var txnId = "TXN-" + nextTxnNum
        // nextTxnNum++
        if(lms.issueBook(issueIsbn, issueStudentId)){
            txData = lms.getTransactions()
            transactiondatafetching()
        issueMsg = "Book issued successfully! "
        issueSuccess = true
        issueFeedbackTimer.restart()
        issueStudent = ""; issueStudentId = ""; selectBook = ""; issueIsbn = ""}
        else{
            issueMsg = "Book issued Failed! "
            issueSuccess = false
            issueFeedbackTimer.restart()
        }
    }

    // ── Return Book logic ──────────────────────────────────────────────────
    function returnBook() {
        if (!returnTxnId) { returnMsg = "Please enter a Transaction ID."; returnSuccess = false; return }

        var id = returnTxnId.trim().toUpperCase()
        for (var i = 0; i < txModel.count; i++) {
            var row = txModel.get(i)
            if (row.txnId === id) {
                if (row.status === "returned") {
                    returnMsg = id + " is already returned."
                    returnSuccess = false
                    return
                }
                if(lms.returnBook(id)){
                    returnMsg = id+ " is returned."
                    txData = lms.getTransactions();
                    transactiondatafetching();
                    returnSuccess = true;
                    return
                }
                // var fine = calcFine(row.dueDate)
                // txModel.setProperty(i, "returnDate", todayStr())
                // txModel.setProperty(i, "fine",       fine)
                // txModel.setProperty(i, "status",     "returned")
                // returnMsg = "Book returned! " + (fine !== "-" ? "Fine applied: " + fine : "No fine.")
                // returnSuccess = true
                // returnFeedbackTimer.restart()
                // returnTxnId = ""
                // return
            }
        }
        returnMsg = "Transaction " + id + " not found."
        returnSuccess = false
    }

    Timer { id: issueFeedbackTimer;  interval: 3000; onTriggered: { issueMsg  = ""; if (issueSuccess) showIssueDialog  = false } }
    Timer { id: returnFeedbackTimer; interval: 2000; onTriggered: { returnMsg = ""; if (returnSuccess) showReturnDialog = false } }

    // ── Status helpers ─────────────────────────────────────────────────────
    function sBg(s)     { return s==="active"?"#1c2d78": s==="returned"?"#123b32": "#4a1f2a" }
    function sFg(s)     { return s==="active"?"#7ea2ff": s==="returned"?"#4fe0a5": "#ff6773" }
    function sBorder(s) { return s==="active"?"#3b82f6": s==="returned"?"#22c55e": "#ef4444" }

    // ══════════════════════════════════════════════════════════════════════
    // MAIN LAYOUT
    // ══════════════════════════════════════════════════════════════════════
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // ── Header row ─────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 4
                Text { text: "Transactions"; color: root.textPrimary; font.pixelSize: 26; font.bold: true }
                Text {
                    text: "Manage book borrowing and returns (" + txModel.count + " transactions)"
                    color: root.textMuted; font.pixelSize: 13
                }
            }

            Item { Layout.fillWidth: true }

            // Issue Book button
            Rectangle {
                width: 140; height: 42; radius: 10
                color: issueMA.containsPress ? "#1a56db" : issueMA.containsMouse ? "#1d64f0" : "#2563eb"
                Behavior on color { ColorAnimation { duration: 100 } }

                RowLayout {
                    anchors.centerIn: parent; spacing: 8
                    Text { text: "📋"; font.pixelSize: 15 }
                    Text { text: "Issue Book"; color: "#ffffff"; font.pixelSize: 13; font.bold: true }
                }

                MouseArea {
                    id: issueMA
                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.issueStudent = ""; root.issueStudentId = ""
                        root.selectBook = ""; root.issueIsbn = ""; root.issueMsg = ""
                        root.showIssueDialog = true
                    }
                }
            }

            Item { width: 10 }

            // Return Book button
            Rectangle {
                width: 148; height: 42; radius: 10
                color: returnMA.containsPress ? "#059669" : returnMA.containsMouse ? "#10a374" : "#10b981"
                Behavior on color { ColorAnimation { duration: 100 } }

                RowLayout {
                    anchors.centerIn: parent; spacing: 8
                    Text { text: "↩"; font.pixelSize: 16; color: "#ffffff"; font.bold: true }
                    Text { text: "Return Book"; color: "#ffffff"; font.pixelSize: 13; font.bold: true }
                }

                MouseArea {
                    id: returnMA
                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: { root.returnTxnId = ""; root.returnMsg = ""; root.showReturnDialog = true }
                }
            }
        }

        // ── Search + filter ────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true; height: 42; radius: 10
                color: "#1b2338"
                border.color: searchInput.activeFocus ? "#3b82f6" : root.borderColor; border.width: 1
                Behavior on border.color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 8
                    Text { text: "🔍"; font.pixelSize: 14; opacity: 0.5 }
                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true; color: root.textPrimary; font.pixelSize: 13
                        clip: true; selectByMouse: true; verticalAlignment: TextInput.AlignVCenter
                        onTextChanged: root.searchText = text
                        Text { visible: !parent.text; text: "Search by transaction ID, student, or book..."; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }

            Rectangle {
                width: 140; height: 42; radius: 10
                color: "#1b2338"; border.color: root.borderColor; border.width: 1

                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                    Text { Layout.fillWidth: true; text: root.statusFilter; color: root.textPrimary; font.pixelSize: 13 }
                    Text { text: "▼"; color: root.textMuted; font.pixelSize: 9 }
                }
                MouseArea { anchors.fill: parent; onClicked: sfMenu.open() }
                Menu {
                    id: sfMenu
                    MenuItem { text: "All Status"; onTriggered: root.statusFilter = text }
                    MenuItem { text: "active";     onTriggered: root.statusFilter = text }
                    MenuItem { text: "returned";   onTriggered: root.statusFilter = text }
                    MenuItem { text: "overdue";    onTriggered: root.statusFilter = text }
                }
            }
        }

        // ── Table card ─────────────────────────────────────────────────────
        Rectangle {
            width: parent.width
            // height = available space minus header(~56) minus search(42) minus stats(90) minus spacings
            height: parent.height - 56 - 42 - 90 - 16*4
            color: root.cardBg; radius: 16
            border.color: root.borderColor; border.width: 1

            Column {
                anchors.fill: parent
                spacing: 0

                // ── Column header row ──────────────────────────────────────
                // Total usable width ≈ card width − 32px side margins
                // Columns designed to sum to 100% of that space
                Rectangle {
                    width: parent.width; height: 46
                    color: root.headerBg
                    radius: 0

                    // top corners only
                    Rectangle { width: parent.width; height: parent.radius; anchors.bottom: parent.top; color: parent.color }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 16; anchors.rightMargin: 16

                        // widths tuned to sum to ~100% of (cardWidth - 32)
                        Repeater {
                            model: [
                                { label: "Txn ID",     flex: 0.13 },
                                { label: "Student",    flex: 0.18 },
                                { label: "Book",       flex: 0.25 },
                                { label: "Issued",     flex: 0.12 },
                                { label: "Due",        flex: 0.12 },
                                { label: "Fine",       flex: 0.08 },
                                { label: "Status",     flex: 0.12 }
                            ]
                            delegate: Text {
                                width: (parent.width) * modelData.flex
                                text: modelData.label
                                color: "#9fb0d9"; font.pixelSize: 12; font.bold: true
                                verticalAlignment: Text.AlignVCenter; height: 46
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: root.borderColor }

                // ── Flickable rows ─────────────────────────────────────────
                Item {
                    width: parent.width
                    height: parent.height - 47

                    Flickable {
                        id: rowFlick
                        anchors.fill: parent
                        anchors.rightMargin: 16
                        contentWidth: width
                        contentHeight: rowCol.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        Column {
                            id: rowCol
                            width: rowFlick.width
                            spacing: 0

                            Repeater {
                                model: txModel
                                delegate: Column {
                                    width: rowCol.width
                                    spacing: 0
                                    visible: root.rowVisible(txModel.get(index))
                                    height: visible ? implicitHeight : 0

                                    Rectangle {
                                        width: parent.width; height: 64
                                        color: rowMA.containsMouse
                                            ? (status === "overdue" ? "#341520" : "#1a2238")
                                            : (status === "overdue" ? "#2a1520" : "transparent")
                                        Behavior on color { ColorAnimation { duration: 100 } }

                                        Row {
                                            anchors.fill: parent
                                            anchors.leftMargin: 16; anchors.rightMargin: 16

                                            // Txn ID
                                            Column {
                                                width: parent.width * 0.13
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 0
                                                Text { text: txnId;  color: root.textPrimary; font.pixelSize: 13; font.bold: true; elide: Text.ElideRight; width: parent.width }
                                            }

                                            // Student
                                            Column {
                                                width: parent.width * 0.18
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 2
                                                Text { text: student; color: root.textPrimary; font.pixelSize: 13; font.bold: true; elide: Text.ElideRight; width: parent.width }
                                                Text { text: sId;     color: root.textMuted;   font.pixelSize: 11; elide: Text.ElideRight; width: parent.width }
                                            }

                                            // Book
                                            Column {
                                                width: parent.width * 0.25
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 2
                                                Text { text: bookName; color: root.textPrimary; font.pixelSize: 13; font.bold: true; elide: Text.ElideRight; width: parent.width - 8 }
                                                Text { text: isbn; color: root.textMuted;   font.pixelSize: 11; elide: Text.ElideRight; width: parent.width - 8 }
                                            }

                                            // Issued
                                            Text {
                                                width: parent.width * 0.12
                                                text: issueDate; color: root.textMuted; font.pixelSize: 12
                                                verticalAlignment: Text.AlignVCenter; height: parent.height
                                                elide: Text.ElideRight
                                            }

                                            // Due
                                            Text {
                                                width: parent.width * 0.12
                                                text: dueDate
                                                color: status === "overdue" ? "#ef4444" : root.textMuted
                                                font.pixelSize: 12; font.bold: status === "overdue"
                                                verticalAlignment: Text.AlignVCenter; height: parent.height
                                                elide: Text.ElideRight
                                            }

                                            // Fine
                                            Text {
                                                width: parent.width * 0.08
                                                text: fine
                                                color: fine !== "-" ? "#ef4444" : root.textMuted
                                                font.pixelSize: 13; font.bold: fine !== "-"
                                                verticalAlignment: Text.AlignVCenter; height: parent.height
                                            }

                                            // Status badge
                                            Item {
                                                width: parent.width * 0.12; height: parent.height
                                                Rectangle {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    width: 78; height: 26; radius: 13
                                                    color: root.sBg(status)
                                                    border.color: root.sBorder(status); border.width: 1
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: status; color: root.sFg(status)
                                                        font.pixelSize: 11; font.bold: true
                                                    }
                                                }
                                            }
                                        }

                                        MouseArea {
                                            id: rowMA
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            acceptedButtons: Qt.NoButton
                                        }
                                    }

                                    // Row divider
                                    Rectangle { width: parent.width; height: 1; color: root.borderColor; opacity: 0.5 }
                                }
                            }

                            // Empty state
                            Rectangle {
                                width: rowCol.width; height: 120; color: "transparent"
                                visible: {
                                    for (var i = 0; i < txModel.count; i++)
                                        if (root.rowVisible(txModel.get(i))) return false
                                    return true
                                }
                                Column {
                                    anchors.centerIn: parent; spacing: 10
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "🔍"; font.pixelSize: 36 }
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "No transactions found"; color: root.textMuted; font.pixelSize: 14; font.bold: true }
                                }
                            }
                        }
                    }

                    // Draggable scrollbar
                    Rectangle {
                        id: scrollTrack
                        anchors.right: parent.right; anchors.rightMargin: 3
                        anchors.top: parent.top; anchors.topMargin: 4
                        anchors.bottom: parent.bottom; anchors.bottomMargin: 4
                        width: 5; radius: 2.5
                        color: "#1e2535"
                        visible: rowFlick.contentHeight > rowFlick.height

                        Rectangle {
                            width: parent.width; radius: 2.5
                            color: tMA.pressed ? "#9ca3af" : tMA.containsMouse ? "#6b7280" : "#374151"
                            Behavior on color { ColorAnimation { duration: 100 } }
                            height: Math.max(32, scrollTrack.height * (rowFlick.height / rowFlick.contentHeight))
                            y: rowFlick.contentY / rowFlick.contentHeight * scrollTrack.height

                            MouseArea {
                                id: tMA; anchors.fill: parent; hoverEnabled: true
                                cursorShape: Qt.SizeVerCursor; preventStealing: true
                                property real pressY: 0; property real pressContentY: 0
                                onPressed:  { pressY = mouseY; pressContentY = rowFlick.contentY }
                                onPositionChanged: {
                                    if (pressed) {
                                        var newY = pressContentY + (mouseY - pressY) / scrollTrack.height * rowFlick.contentHeight
                                        rowFlick.contentY = Math.max(0, Math.min(newY, rowFlick.contentHeight - rowFlick.height))
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                rowFlick.contentY = Math.max(0, Math.min(
                                    mouseY / scrollTrack.height * rowFlick.contentHeight,
                                    rowFlick.contentHeight - rowFlick.height
                                ))
                            }
                        }
                    }
                }
            }
        }
        // ── Stat cards ─────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true; spacing: 14

            Repeater {
                model: [
                    { label: "Total Active", value: root.countByStatus("active"),   color: "#7ea2ff" },
                    { label: "Overdue",      value: root.countByStatus("overdue"),  color: "#ff6773" },
                    { label: "Returned",     value: root.countByStatus("returned"), color: "#4fe0a5" }
                ]
                delegate: Rectangle {
                    Layout.fillWidth: true; height: 80
                    color: root.cardBg; radius: 14
                    border.color: root.borderColor; border.width: 1

                    Column {
                        anchors { fill: parent; margins: 18 } spacing: 6
                        Text { text: modelData.value; color: modelData.color; font.pixelSize: 22; font.bold: true }
                        Text { text: modelData.label; color: root.textMuted;  font.pixelSize: 13 }
                    }
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // ISSUE BOOK DIALOG
    // ══════════════════════════════════════════════════════════════════════
    Rectangle {
        visible: root.showIssueDialog
        anchors.fill: parent; color: "#000000"; opacity: 0.65
        MouseArea { anchors.fill: parent; onClicked: root.showIssueDialog = false }
    }

    Rectangle {
        visible: root.showIssueDialog
        anchors.centerIn: parent
        width: 480
        implicitHeight: issueDialogCol.implicitHeight + 48
        radius: 14; color: "#171e2f"
        border.color: root.borderColor; border.width: 1

        Column {
            id: issueDialogCol
            anchors { fill: parent; margins: 28 }
            spacing: 20

            // Title
            RowLayout {
                width: parent.width
                Text { text: "Issue Book"; color: root.textPrimary; font.pixelSize: 18; font.bold: true }
                Item { Layout.fillWidth: true }
                Text {
                    text: "✕"; color: root.textMuted; font.pixelSize: 16
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.showIssueDialog = false }
                }
            }

            // Select Student
            // Column { width: parent.width; spacing: 8
            //     Text { text: "Student"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
            //     Rectangle {
            //         width: parent.width; height: 44; radius: 8
            //         color: "#0f1117"; border.color: "#2d3748"; border.width: 1
            //         RowLayout { anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
            //             Text { Layout.fillWidth: true; text: root.issueStudent !== "" ? root.issueStudent + " (" + root.issueStudentId + ")" : "Select a student"; color: root.issueStudent !== "" ? root.textPrimary : "#6b7280"; font.pixelSize: 13 }
            //             Text { text: "▼"; color: root.textMuted; font.pixelSize: 9 }
            //         }
            //         MouseArea { anchors.fill: parent; onClicked: studentMenu.open() }
            //         Menu {
            //             id: studentMenu
            //             Repeater {
            //                 model: students
            //                 delegate: MenuItem {
            //                     text: name + " (" + userId + ")"
            //                     onTriggered: { root.issueStudent = name; root.issueStudentId = userId }
            //                 }
            //             }
            //         }
            //     }
            // }
            // Select Student
            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: "Student"
                    color: "#e5e7eb"
                    font.pixelSize: 12
                    font.bold: true
                }

                Rectangle {
                    width: parent.width
                    height: 44
                    radius: 8

                    color: "#0f1117"
                    border.color: "#2d3748"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12

                        Text {
                            Layout.fillWidth: true

                            text: root.issueStudent !== ""
                                  ? root.issueStudent + " (" + root.issueStudentId + ")"
                                  : "Select a student"

                            color: root.issueStudent !== ""
                                   ? root.textPrimary
                                   : "#6b7280"

                            font.pixelSize: 13
                            elide: Text.ElideRight
                        }

                        Text {
                            text: root.showStudentDropdown ? "▲" : "▼"
                            color: root.textMuted
                            font.pixelSize: 9
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            root.showStudentDropdown = !root.showStudentDropdown
                            root.showBookDropdown = false
                        }
                    }
                }

                // DROPDOWN
                Rectangle {
                    visible: root.showStudentDropdown

                    width: parent.width
                    height: 220
                    radius: 8

                    color: "#111827"

                    border.color: "#2d3748"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        Rectangle {
                            width: parent.width
                            height: 38
                            radius: 6

                            color: "#0f1117"
                            border.color: "#2d3748"

                            TextInput {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12

                                color: "#ffffff"
                                font.pixelSize: 13

                                verticalAlignment: Text.AlignVCenter

                                onTextChanged: root.studentSearchText = text

                                Text {
                                    visible: parent.text === ""
                                    text: "Search student..."
                                    color: "#6b7280"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        Flickable {
                            width: parent.width
                            height: 150

                            clip: true
                            contentHeight: studentList.height

                            Column {
                                id: studentList
                                width: parent.width
                                spacing: 4

                                Repeater {
                                    model: students

                                    delegate: Rectangle {
                                        width: parent.width
                                        height: visible ? 40 : 0

                                        visible:
                                            name.toLowerCase().includes(root.studentSearchText.toLowerCase())
                                            || userId.toLowerCase().includes(root.studentSearchText.toLowerCase())

                                        radius: 6

                                        color: studentHover.containsMouse
                                               ? "#1e293b"
                                               : "transparent"

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            anchors.leftMargin: 12

                                            width: parent.width - 24

                                            text: name + " (" + userId + ")"

                                            color: "#e5e7eb"
                                            font.pixelSize: 12

                                            elide: Text.ElideRight
                                        }

                                        MouseArea {
                                            id: studentHover

                                            anchors.fill: parent
                                            hoverEnabled: true

                                            cursorShape: Qt.PointingHandCursor

                                            onClicked: {
                                                root.issueStudent = name
                                                root.issueStudentId = userId
                                                root.showStudentDropdown = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Select Book
            // Column { width: parent.width; spacing: 8
            //     Text { text: "Book"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
            //     Rectangle {
            //         width: parent.width; height: 44; radius: 8
            //         color: "#0f1117"; border.color: "#2d3748"; border.width: 1
            //         RowLayout { anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
            //             Text { Layout.fillWidth: true; text: root.selectBook !== "" ? root.seleectBook : "Select a book"; color: root.selectBook !== "" ? root.textPrimary : "#6b7280"; font.pixelSize: 13; elide: Text.ElideRight }
            //             Text { text: "▼"; color: root.textMuted; font.pixelSize: 9 }
            //         }
            //         MouseArea { anchors.fill: parent; onClicked: bookMenu.open() }
            //         Menu {
            //             id: bookMenu
            //             Repeater {
            //                 model: booksModel
            //                 delegate: MenuItem {
            //                     text: title
            //                     onTriggered: { root.selectBook = title; root.issueIsbn = isbn }
            //                 }
            //             }
            //         }
            //     }
            // }
            // Select Book
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
                    width: parent.width
                    height: 44
                    radius: 8

                    color: "#0f1117"
                    border.color: "#2d3748"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12

                        Text {
                            Layout.fillWidth: true

                            text: root.selectBook !== ""
                                  ? root.selectBook
                                  : "Select a book"

                            color: root.selectBook !== ""
                                   ? root.textPrimary
                                   : "#6b7280"

                            font.pixelSize: 13
                            elide: Text.ElideRight
                        }

                        Text {
                            text: root.showBookDropdown ? "▲" : "▼"
                            color: root.textMuted
                            font.pixelSize: 9
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            root.showBookDropdown = !root.showBookDropdown
                            root.showStudentDropdown = false
                        }
                    }
                }

                Rectangle {
                    visible: root.showBookDropdown

                    width: parent.width
                    height: 240
                    radius: 8

                    color: "#111827"

                    border.color: "#2d3748"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        Rectangle {
                            width: parent.width
                            height: 38
                            radius: 6

                            color: "#0f1117"
                            border.color: "#2d3748"

                            TextInput {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12

                                color: "#ffffff"
                                font.pixelSize: 13

                                verticalAlignment: Text.AlignVCenter

                                onTextChanged: root.bookSearchText = text

                                Text {
                                    visible: parent.text === ""
                                    text: "Search book..."
                                    color: "#6b7280"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        Flickable {
                            width: parent.width
                            height: 170

                            clip: true
                            contentHeight: booksList.height

                            Column {
                                id: booksList
                                width: parent.width
                                spacing: 4

                                Repeater {
                                    model: booksModel

                                    delegate: Rectangle {
                                        width: parent.width
                                        height: visible ? 46 : 0

                                        visible:
                                            title.toLowerCase().includes(root.bookSearchText.toLowerCase())
                                            || isbn.toLowerCase().includes(root.bookSearchText.toLowerCase())

                                        radius: 6

                                        color: bookHover.containsMouse
                                               ? "#1e293b"
                                               : "transparent"

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            anchors.leftMargin: 12

                                            width: parent.width - 24
                                            spacing: 2

                                            Text {
                                                width: parent.width
                                                text: title
                                                color: "#ffffff"
                                                font.pixelSize: 12
                                                font.bold: true
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                width: parent.width
                                                text: isbn
                                                color: "#9ca3af"
                                                font.pixelSize: 11
                                                elide: Text.ElideRight
                                            }
                                        }

                                        MouseArea {
                                            id: bookHover

                                            anchors.fill: parent
                                            hoverEnabled: true

                                            cursorShape: Qt.PointingHandCursor

                                            onClicked: {
                                                root.selectBook = title
                                                root.issueIsbn = isbn
                                                root.showBookDropdown = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Auto-filled info
            Rectangle {
                width: parent.width; height: 52; radius: 8; color: "#0f1117"
                border.color: "#2d3748"; border.width: 1
                visible: root.issueStudent !== "" && root.selectBook !== ""
                Column {
                    anchors { fill: parent; margins: 12 } spacing: 4
                    Text { text: "Issue Date: " + root.todayStr();    color: root.textMuted;   font.pixelSize: 12 }
                    Text { text: "Due Date:   " + root.dueDateStr(14); color: "#f59e0b"; font.pixelSize: 12; font.bold: true }
                }
            }

            // Feedback
            Rectangle {
                width: parent.width; height: 36; radius: 8; visible: root.issueMsg !== ""
                color: root.issueSuccess ? "#052e16" : "#3b0f0f"
                border.color: root.issueSuccess ? "#10b981" : "#ef4444"; border.width: 1
                Text { anchors.centerIn: parent; text: root.issueMsg; color: root.issueSuccess ? "#10b981" : "#ef4444"; font.pixelSize: 12; font.bold: true }
            }

            // Buttons
            RowLayout { width: parent.width; spacing: 12
                Rectangle {
                    width: 100; height: 42; radius: 8; color: "transparent"
                    border.color: "#6b7280"; border.width: 1
                    Text { anchors.centerIn: parent; text: "Cancel"; color: "#e5e7eb"; font.pixelSize: 13; font.bold: true }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.showIssueDialog = false }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 42; radius: 8
                    color: (root.issueStudent && root.selectBook) ? "#2563eb" : "#374151"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text { anchors.centerIn: parent; text: "Confirm Issue"; color: "#ffffff"; font.pixelSize: 13; font.bold: true }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        enabled: root.issueStudent !== "" && root.selectBook !== ""
                        onClicked: root.issueBook()
                    }
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // RETURN BOOK DIALOG
    // ══════════════════════════════════════════════════════════════════════
    Rectangle {
        visible: root.showReturnDialog
        anchors.fill: parent; color: "#000000"; opacity: 0.65
        MouseArea { anchors.fill: parent; onClicked: root.showReturnDialog = false }
    }

    Rectangle {
        visible: root.showReturnDialog
        anchors.centerIn: parent
        width: 440
        implicitHeight: returnDialogCol.implicitHeight + 48
        radius: 14; color: "#171e2f"
        border.color: root.borderColor; border.width: 1

        Column {
            id: returnDialogCol
            anchors { fill: parent; margins: 28 }
            spacing: 20

            // Title
            RowLayout {
                width: parent.width
                Text { text: "Return Book"; color: root.textPrimary; font.pixelSize: 18; font.bold: true }
                Item { Layout.fillWidth: true }
                Text {
                    text: "✕"; color: root.textMuted; font.pixelSize: 16
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.showReturnDialog = false }
                }
            }

            Text { text: "Enter the Transaction ID to process the return. Fines are calculated at $10/day overdue."; color: root.textMuted; font.pixelSize: 12; wrapMode: Text.WordWrap; width: parent.width }

            // TXN ID input
            Column { width: parent.width; spacing: 8
                Text { text: "Transaction ID"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                Rectangle {
                    width: parent.width; height: 44; radius: 8
                    color: "#0f1117"
                    border.color: txInput.activeFocus ? "#10b981" : "#2d3748"; border.width: 1
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    RowLayout {
                        anchors { fill: parent; leftMargin: 12; rightMargin: 12 } spacing: 10
                        Text { text: "🔖"; font.pixelSize: 15; opacity: 0.6 }
                        TextInput {
                            id: txInput
                            Layout.fillWidth: true; color: root.textPrimary; font.pixelSize: 13
                            clip: true; selectByMouse: true; verticalAlignment: TextInput.AlignVCenter
                            text: root.returnTxnId
                            onTextChanged: root.returnTxnId = text.toUpperCase()
                            Keys.onReturnPressed: root.returnBook()
                            Text { visible: !parent.text; text: "e.g. TXN-1243"; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }
                }
            }

            // Quick-pick active/overdue transactions
            Column { width: parent.width; spacing: 8
                Text { text: "Quick pick — active / overdue:"; color: root.textMuted; font.pixelSize: 11 }
                Flow {
                    width: parent.width; spacing: 8
                    Repeater {
                        model: txModel
                        delegate: Rectangle {
                            visible: status === "active" || status === "overdue"
                            width: visible ? chipLabel.implicitWidth + 24 : 0
                            height: 28; radius: 14
                            color: root.sBg(status)
                            border.color: root.sBorder(status); border.width: 1
                            Text {
                                id: chipLabel
                                anchors.centerIn: parent; text: txnId
                                color: root.sFg(status); font.pixelSize: 11; font.bold: true
                            }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { root.returnTxnId = txnId; txInput.text = txnId }
                            }
                        }
                    }
                }
            }

            // Feedback
            Rectangle {
                width: parent.width; height: 36; radius: 8; visible: root.returnMsg !== ""
                color: root.returnSuccess ? "#052e16" : "#3b0f0f"
                border.color: root.returnSuccess ? "#10b981" : "#ef4444"; border.width: 1
                Text { anchors.centerIn: parent; text: root.returnMsg; color: root.returnSuccess ? "#10b981" : "#ef4444"; font.pixelSize: 12; font.bold: true }
            }

            // Buttons
            RowLayout { width: parent.width; spacing: 12
                Rectangle {
                    width: 100; height: 42; radius: 8; color: "transparent"
                    border.color: "#6b7280"; border.width: 1
                    Text { anchors.centerIn: parent; text: "Cancel"; color: "#e5e7eb"; font.pixelSize: 13; font.bold: true }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.showReturnDialog = false }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 42; radius: 8
                    color: root.returnTxnId !== "" ? "#10b981" : "#374151"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text { anchors.centerIn: parent; text: "Confirm Return"; color: "#ffffff"; font.pixelSize: 13; font.bold: true }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        enabled: root.returnTxnId !== ""
                        onClicked: root.returnBook()
                    }
                }
            }
        }
    }
}
