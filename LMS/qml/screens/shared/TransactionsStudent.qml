import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// Transactions.qml
// Window: 1024×800 | Sidebar: 200px | TitleBar+Navbar: ~94px
// Available content width: ~824px — all columns sized to fit without horizontal scroll

Rectangle {
    id: txView
    color: "#0b1220"

    // ── Theme tokens ───────────────────────────────────────────────────────
    readonly property color cardBg:       "#171e2f"
    readonly property color borderColor:  "#2a3350"
    readonly property color textPrimary:  "#ffffff"
    readonly property color textMuted:    "#9aa4bf"
    readonly property color headerBg:     "#111827"

    // ── Filters ────────────────────────────────────────────────────────────
    property string searchText:   ""
    property string statusFilter: "All"

    // ── Data ──────────────────────────────────────────────────────────────
    ListModel {
        id: txModel
        ListElement { txnId: "TXN-1245"; student: "John Doe";    sId: "S001"; book: "Clean Code";                 isbn: "978-0132350884"; issueDate: "2026-04-01"; dueDate: "2026-04-15"; fine: "-";   status: "active"   }
        ListElement { txnId: "TXN-1244"; student: "Jane Smith";  sId: "S002"; book: "Design Patterns";           isbn: "978-0201633612"; issueDate: "2026-03-28"; dueDate: "2026-04-11"; fine: "-";   status: "returned" }
        ListElement { txnId: "TXN-1243"; student: "Bob Johnson"; sId: "S003"; book: "Effective Java";            isbn: "978-0134685991"; issueDate: "2026-03-25"; dueDate: "2026-04-08"; fine: "$15"; status: "overdue"  }
        ListElement { txnId: "TXN-1242"; student: "John Doe";    sId: "S001"; book: "The Pragmatic Programmer";  isbn: "978-0137081073"; issueDate: "2026-04-05"; dueDate: "2026-04-19"; fine: "-";   status: "active"   }
        ListElement { txnId: "TXN-1241"; student: "Alice Brown"; sId: "S004"; book: "Intro to Algorithms";       isbn: "978-0262033848"; issueDate: "2026-03-20"; dueDate: "2026-04-03"; fine: "$30"; status: "overdue"  }
    }

    // ── Row filter ─────────────────────────────────────────────────────────
    function rowVisible(item) {
        if (statusFilter !== "All" && item.status !== statusFilter) return false
        if (searchText.length > 0) {
            var s = searchText.toLowerCase()
            if (!item.txnId.toLowerCase().includes(s) &&
                !item.student.toLowerCase().includes(s) &&
                !item.book.toLowerCase().includes(s)) return false
        }
        return true
    }

    function countByStatus(st) {
        var c = 0
        for (var i = 0; i < txModel.count; i++)
            if (txModel.get(i).status === st) c++
        return c
    }

    // ── Status helpers ─────────────────────────────────────────────────────
    function sBg(s)     { return s==="active"?"#1c2d78": s==="returned"?"#123b32": "#4a1f2a" }
    function sFg(s)     { return s==="active"?"#7ea2ff": s==="returned"?"#4fe0a5": "#ff6773" }
    function sBorder(s) { return s==="active"?"#3b82f6": s==="returned"?"#22c55e": "#ef4444" }

    // ══════════════════════════════════════════════════════════════════════
    // LAYOUT — Column fills parent, no horizontal scrolling
    // ══════════════════════════════════════════════════════════════════════
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // ── Page header ────────────────────────────────────────────────────
        Column {
            width: parent.width
            spacing: 4
            Text { text: "Transactions"; color: txView.textPrimary; font.pixelSize: 24; font.bold: true }
            Text {
                text: "Manage book borrowing and returns (" + txModel.count + " transactions)"
                color: txView.textMuted; font.pixelSize: 13
            }
        }

        // ── Search + filter bar ────────────────────────────────────────────
        Row {
            width: parent.width
            spacing: 12

            // Search box
            Rectangle {
                width: parent.width - 160 - 12
                height: 42; radius: 10
                color: "#1b2338"
                border.color: searchInput.activeFocus ? "#3b82f6" : txView.borderColor; border.width: 1
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Row {
                    anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 8
                    Text { text: "🔍"; font.pixelSize: 14; opacity: 0.5; anchors.verticalCenter: parent.verticalCenter }
                    TextInput {
                        id: searchInput
                        width: parent.width - 36; height: parent.height
                        color: txView.textPrimary; font.pixelSize: 13
                        clip: true; selectByMouse: true; verticalAlignment: TextInput.AlignVCenter
                        onTextChanged: txView.searchText = text
                        Text { visible: !parent.text; text: "Search by ID, student, or book..."; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }

            // Status filter
            Rectangle {
                width: 148; height: 42; radius: 10
                color: "#1b2338"
                border.color: txView.borderColor; border.width: 1

                Row {
                    anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                    Text { Layout.fillWidth: true; text: txView.statusFilter === "All" ? "All Status" : txView.statusFilter; color: txView.textPrimary; font.pixelSize: 13; width: parent.width - 20; verticalAlignment: Text.AlignVCenter; height: parent.height }
                    Text { text: "▼"; color: txView.textMuted; font.pixelSize: 9; anchors.verticalCenter: parent.verticalCenter }
                }

                MouseArea { anchors.fill: parent; onClicked: statusMenu.open() }
                Menu {
                    id: statusMenu
                    MenuItem { text: "All";      onTriggered: txView.statusFilter = "All"      }
                    MenuItem { text: "active";   onTriggered: txView.statusFilter = "active"   }
                    MenuItem { text: "returned"; onTriggered: txView.statusFilter = "returned" }
                    MenuItem { text: "overdue";  onTriggered: txView.statusFilter = "overdue"  }
                }
            }
        }

        // ── Table card ─────────────────────────────────────────────────────
        Rectangle {
            width: parent.width
            // height = available space minus header(~56) minus search(42) minus stats(90) minus spacings
            height: parent.height - 56 - 42 - 90 - 16*4
            color: txView.cardBg; radius: 16
            border.color: txView.borderColor; border.width: 1

            Column {
                anchors.fill: parent
                spacing: 0

                // ── Column header row ──────────────────────────────────────
                // Total usable width ≈ card width − 32px side margins
                // Columns designed to sum to 100% of that space
                Rectangle {
                    width: parent.width; height: 46
                    color: txView.headerBg
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

                Rectangle { width: parent.width; height: 1; color: txView.borderColor }

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
                                    visible: txView.rowVisible(txModel.get(index))
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
                                                Text { text: txnId;  color: txView.textPrimary; font.pixelSize: 13; font.bold: true; elide: Text.ElideRight; width: parent.width }
                                            }

                                            // Student
                                            Column {
                                                width: parent.width * 0.18
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 2
                                                Text { text: student; color: txView.textPrimary; font.pixelSize: 13; font.bold: true; elide: Text.ElideRight; width: parent.width }
                                                Text { text: sId;     color: txView.textMuted;   font.pixelSize: 11; elide: Text.ElideRight; width: parent.width }
                                            }

                                            // Book
                                            Column {
                                                width: parent.width * 0.25
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 2
                                                Text { text: book; color: txView.textPrimary; font.pixelSize: 13; font.bold: true; elide: Text.ElideRight; width: parent.width - 8 }
                                                Text { text: isbn; color: txView.textMuted;   font.pixelSize: 11; elide: Text.ElideRight; width: parent.width - 8 }
                                            }

                                            // Issued
                                            Text {
                                                width: parent.width * 0.12
                                                text: issueDate; color: txView.textMuted; font.pixelSize: 12
                                                verticalAlignment: Text.AlignVCenter; height: parent.height
                                                elide: Text.ElideRight
                                            }

                                            // Due
                                            Text {
                                                width: parent.width * 0.12
                                                text: dueDate
                                                color: status === "overdue" ? "#ef4444" : txView.textMuted
                                                font.pixelSize: 12; font.bold: status === "overdue"
                                                verticalAlignment: Text.AlignVCenter; height: parent.height
                                                elide: Text.ElideRight
                                            }

                                            // Fine
                                            Text {
                                                width: parent.width * 0.08
                                                text: fine
                                                color: fine !== "-" ? "#ef4444" : txView.textMuted
                                                font.pixelSize: 13; font.bold: fine !== "-"
                                                verticalAlignment: Text.AlignVCenter; height: parent.height
                                            }

                                            // Status badge
                                            Item {
                                                width: parent.width * 0.12; height: parent.height
                                                Rectangle {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    width: 78; height: 26; radius: 13
                                                    color: txView.sBg(status)
                                                    border.color: txView.sBorder(status); border.width: 1
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: status; color: txView.sFg(status)
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
                                    Rectangle { width: parent.width; height: 1; color: txView.borderColor; opacity: 0.5 }
                                }
                            }

                            // Empty state
                            Rectangle {
                                width: rowCol.width; height: 120; color: "transparent"
                                visible: {
                                    for (var i = 0; i < txModel.count; i++)
                                        if (txView.rowVisible(txModel.get(i))) return false
                                    return true
                                }
                                Column {
                                    anchors.centerIn: parent; spacing: 10
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "🔍"; font.pixelSize: 36 }
                                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "No transactions found"; color: txView.textMuted; font.pixelSize: 14; font.bold: true }
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

        // ── Summary stat cards ─────────────────────────────────────────────
        Row {
            width: parent.width
            spacing: 14

            Repeater {
                model: [
                    { label: "Total Active",     value: txView.countByStatus("active"),   color: "#7ea2ff" },
                    { label: "Overdue",          value: txView.countByStatus("overdue"),  color: "#ff6773" },
                    { label: "Completed",        value: txView.countByStatus("returned"), color: "#4fe0a5" }
                ]
                delegate: Rectangle {
                    width: (parent.width - 28) / 3; height: 80
                    color: txView.cardBg; radius: 14
                    border.color: txView.borderColor; border.width: 1

                    Row {
                        anchors { fill: parent; margins: 18 }
                        spacing: 14

                        Text {
                            text: modelData.value
                            color: modelData.color
                            font.pixelSize: 26; font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter; spacing: 2
                            Text { text: modelData.label; color: txView.textPrimary; font.pixelSize: 13 }
                            Text { text: "transactions";  color: txView.textMuted; font.pixelSize: 11 }
                        }
                    }
                }
            }
        }
    }
}
