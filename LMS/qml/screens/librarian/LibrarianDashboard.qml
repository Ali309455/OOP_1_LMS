import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import LMS
Rectangle {
    id: dashboard
    color: "#0f1117"
    anchors.fill: parent

    signal quickActionClicked(string action)
    property var txData: lms.getTransactions();

    // ───────────────── DATA ─────────────────
    property var colW: [140, 160, 190, 120, 120]
    // add balance parameters
    property bool showAddBalanceDialog: false
    property string selectedBalanceStudent: ""
    property string selectedBalanceStudentId: ""
    property string balanceStudentSearchText: ""
    property bool showBalanceStudentDropdown: false
    // generate pdf parameters
    property double librarybalance: lms.getlibraryBalance();
    property int totalbooks: lms.gettotalBooks();
    property int activetransactions: lms.getactiveTransations();
    property int pendingreviews: lms.getpendingReviews();
    property bool showReportDialog: false;
    property string reportPath: "";
    // stats data
    property var statsData: [
        { icon: "qrc:/assets/icons/book.png", value: totalbooks, label: "Total Books",         iconColor: '#FF5722' },
        { icon: "qrc:/assets/icons/transaction.png", value: activetransactions,   label: "Active Transactions", iconColor: "#FF5722" },
        { icon: "qrc:/assets/icons/addreview.png", value: librarybalance,    label: "Library Balance",       iconColor: "#091291" },
        { icon: "qrc:/assets/icons/addreview.png", value:pendingreviews ,     label: "Pending Reviews",     iconColor: "#091291" }
    ]
    // iteratable list models
    ListModel {
      id: students
    }
    ListModel{
        id:transactions
    }
    // quick action data
    property var quickActions: [
        { label: "Generate Report", color: "#3b82f6", action: "generateReport" },
        { label: "Add Balance", color: "#10b981", action: "addBalance" }
    ]
    // static graph data (future insight make it dynamic)
    property var chartData: [
        { month: "Jan", value: 180 },
        { month: "Feb", value: 210 },
        { month: "Mar", value: 260 },
        { month: "Apr", value: 320 },
        { month: "May", value: 370 },
        { month: "Jun", value: 340 }
    ]
    // recent transactions loading from backend
    function transactiondatafetching() {
        transactions.clear()

        let count = txData.length

        if (count > 10)
            count = 10

        for (let i = 0; i < count; i++) {
            transactions.append(txData[i])
        }
    }
    function refreshUsers() {
        students.clear()

        let data = lms.getUsers()

        for (let j = 0; j < data.length; j++) {
            let u = data[j]

            students.append({
                name: u.name,
                userId: u.userId,
                email: u.email,
                role: u.role,
                membership: u.membership,
                balance: Number(u.balance)
            })
        }
    }
    Component.onCompleted: {
        transactiondatafetching();
        refreshUsers();

    }
    property int chartMax: 600

    // ── Dashbaord with Vertical scrollbar  ─────────────────────────────────────────────────
    Flickable {
        id: flick
        anchors.fill: parent
        anchors.margins: 24
        anchors.rightMargin: 32
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: column
            width: flick.width
            spacing: 20

            // ── Header ─────────────────────────────────────────────────────
            Column {
                spacing: 6

                Text {
                    text: "Dashboard"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#ffffff"
                }
                Text {
                    text: "Library management overview"
                    font.pixelSize: 13
                    color: "#9ca3af"
                }
            }

            // ── Stat cards ─────────────────────────────────────────────────
            Row {
                width: parent.width
                spacing: 14

                Repeater {
                    model: dashboard.statsData
                    delegate: Rectangle {
                        width: (parent.width - 3 * 14) / 4
                        height: 120
                        radius: 12
                        color: "#1a1f2e"
                        border.color: "#2d3748"
                        border.width: 1

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 10

                            // Icon badge
                            Rectangle {
                                width: 44; height: 44
                                radius: 12
                                color: modelData.iconColor
                                Layout.alignment: Qt.AlignHCenter

                                Image{
                                    anchors.centerIn: parent
                                    height: 30
                                    width: 30
                                    source: modelData.icon
                                    fillMode: Image.PreserveAspectFit
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.value
                                font.pixelSize: 22
                                font.bold: true
                                color: "#ffffff"
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.label
                                font.pixelSize: 11
                                color: "#9ca3af"
                            }
                        }
                    }
                }
            }

            // ── Chart + Quick Actions ──────────────────────────────────────
            Row {
                width: parent.width
                spacing: 16

                // ── Bar Chart ──────────────────────────────────────────────
                Rectangle {
                    width: parent.width * 0.67 - 8
                    height: 270
                    radius: 12
                    color: "#1a1f2e"
                    border.color: "#2d3748"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12

                        Text {
                            text: "Books Issued (Last 6 Months)"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#ffffff"
                        }

                        Item {
                            id: chartCanvas
                            width: parent.width
                            height: 200

                            property real usableH: height - 20

                            // Grid lines
                            Repeater {
                                model: [600, 450, 300, 150]
                                delegate: Rectangle {
                                    x: 0
                                    y: chartCanvas.usableH * (1 - modelData / dashboard.chartMax)
                                    width: chartCanvas.width
                                    height: 1
                                    color: "#2d3748"
                                }
                            }

                            // Y-axis labels
                            Repeater {
                                model: [600, 450, 300, 150, 0]
                                delegate: Text {
                                    x: 0
                                    y: chartCanvas.usableH * (1 - modelData / dashboard.chartMax) - 7
                                    text: modelData
                                    font.pixelSize: 9
                                    color: "#6b7280"
                                }
                            }

                            // Bars
                            Row {
                                anchors {
                                    left: parent.left; leftMargin: 28
                                    right: parent.right
                                    bottom: parent.bottom
                                    bottomMargin: 18
                                }
                                spacing: 10

                                Repeater {
                                    model: dashboard.chartData
                                    delegate: Item {
                                        width: ((chartCanvas.width - 28) / dashboard.chartData.length) - 10
                                        height: chartCanvas.height - 18

                                        Rectangle {
                                            width: parent.width
                                            height: chartCanvas.usableH * modelData.value / dashboard.chartMax
                                            radius: 4
                                            color: "#3b82f6"
                                            anchors.bottom: parent.bottom

                                            Behavior on height {
                                                NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
                                            }
                                        }
                                    }
                                }
                            }

                            // Month labels
                            Row {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left; anchors.leftMargin: 28
                                anchors.right: parent.right
                                spacing: 10

                                Repeater {
                                    model: dashboard.chartData
                                    delegate: Text {
                                        width: ((chartCanvas.width - 28) / dashboard.chartData.length) - 10
                                        text: modelData.month
                                        font.pixelSize: 10
                                        color: "#9ca3af"
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Quick Actions ──────────────────────────────────────────
                Rectangle {
                    width: parent.width * 0.33 - 8
                    height: 270
                    radius: 12
                    color: "#1a1f2e"
                    border.color: "#2d3748"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 10

                        Text {
                            text: "Quick Actions"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#ffffff"
                        }

                        Repeater {
                            model: dashboard.quickActions
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: 42
                                radius: 8
                                color: btnMA.containsPress ? Qt.darker(modelData.color, 1.15)
                                     : btnMA.containsMouse ? Qt.lighter(modelData.color, 1.06)
                                     : modelData.color
                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    font.bold: true
                                }

                                MouseArea {
                                    id: btnMA
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: {
                                        if (modelData.action === "addBalance") {
                                            dashboard.showAddBalanceDialog = true
                                        }
                                        else if (modelData.action === "generateReport") {

                                            let path = "Report/report.pdf"

                                            let success = lms.exportDatabaseReportPdf(path)
                                            if (success) {
                                                dashboard.reportPath = path
                                                dashboard.showReportDialog = true
                                            }
                                        }
                                        else {
                                            dashboard.quickActionClicked(modelData.action)
                                        }
                                    }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }
                }
            }

            // ── Recent Transactions ────────────────────────────────────────
            Rectangle {
                width: parent.width
                radius: 12
                color: "#1a1f2e"
                border.color: "#2d3748"
                border.width: 1
                implicitHeight: tableColumn.implicitHeight + 48

                Item {
                    anchors.fill: parent
                    anchors.margins: 20

                    Column {
                        id: tableColumn
                        width: parent.width
                        spacing: 0

                        // Section title
                        Text {
                            text: "Recent Transactions"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#ffffff"
                            height: 40
                            verticalAlignment: Text.AlignVCenter
                        }

                        // Table header row
                        Row {
                            width: parent.width
                            height: 36

                            Repeater {
                                model: ["Transaction ID", "Student", "Book", "Date", "Status"]
                                delegate: Rectangle {
                                    width: dashboard.colW[index]
                                    height: parent.height
                                    color: "transparent"

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: 8
                                        text: modelData
                                        font.bold: true
                                        font.pixelSize: 11
                                        color: "#9ca3af"
                                    }
                                }
                            }
                        }

                        // Header divider
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: "#2d3748"
                        }

                        // Data rows
                        Repeater {
                            model: transactions
                            delegate: Column {
                                width: parent.width
                                spacing: 0

                                Row {
                                    width: parent.width
                                    height: 54

                                    // Transaction ID
                                    Text {
                                        width: dashboard.colW[0]
                                        height: parent.height
                                        text: txnId
                                        font.bold: true
                                        font.pixelSize: 13
                                        color: "#ffffff"
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 8
                                    }

                                    // Student
                                    Text {
                                        width: dashboard.colW[1]
                                        height: parent.height
                                        text: student
                                        font.pixelSize: 13
                                        color: "#e5e7eb"
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    // Book
                                    Text {
                                        width: dashboard.colW[2]
                                        height: parent.height
                                        text: bookName
                                        font.pixelSize: 13
                                        color: "#e5e7eb"
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    // Date
                                    Text {
                                        width: dashboard.colW[3]
                                        height: parent.height
                                        text: issueDate
                                        font.pixelSize: 12
                                        color: "#9ca3af"
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    // Status badge
                                    Rectangle {
                                        width: dashboard.colW[4]
                                        height: parent.height
                                        color: "transparent"

                                        Rectangle {
                                            width: 76; height: 26
                                            radius: 13
                                            anchors.verticalCenter: parent.verticalCenter

                                            color: status === "active"   ? "#052e16"
                                                 : status === "returned" ? "#1e3a5f"
                                                 : "#3b0f0f"

                                            border.color: status === "active"   ? "#10b981"
                                                        : status === "returned" ? "#3b82f6"
                                                        : "#ef4444"
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: status
                                                font.pixelSize: 11
                                                font.bold: true
                                                color: status === "active"   ? "#10b981"
                                                     : status === "returned" ? "#3b82f6"
                                                     : "#ef4444"
                                            }
                                        }
                                    }
                                }

                                // Row divider (hidden after last row)
                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    color: "#1e2535"
                                    visible: index <transactions.length - 1
                                }
                            }
                        }
                    }
                }
            }

            Item { height: 16 }
        }
    }

    // ── Scrollbar ──────────────────────────────────────────────────────────
    ScrollBar {
        id: vBar
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.top: parent.top; anchors.topMargin: 24
        anchors.bottom: parent.bottom; anchors.bottomMargin: 24
        orientation: Qt.Vertical
        size: flick.visibleArea.heightRatio
        position: flick.visibleArea.yPosition
        width: 6
        policy: ScrollBar.AsNeeded

        onPositionChanged: if (pressed) flick.contentY = position * flick.contentHeight

        contentItem: Rectangle { radius: 3; color: vBar.pressed ? "#9ca3af" : "#374151" }
        background: Rectangle { color: "transparent" }
    }

    Connections {
        target: flick
        function onContentYChanged() {
            if (!vBar.pressed) vBar.position = flick.contentY / flick.contentHeight
        }
    }





// ───────────────── ADD BALANCE OVERLAY ─────────────────
Rectangle {
    visible: dashboard.showAddBalanceDialog
    anchors.fill: parent
    color: "#000000"
    opacity: 0.65
    z: 100

    MouseArea {
        anchors.fill: parent
        onClicked: dashboard.showAddBalanceDialog= false
    }
}

// ───────────────── ADD BALANCE DIALOG ─────────────────
Rectangle {
    visible: dashboard.showAddBalanceDialog

    anchors.centerIn: parent

    width: 480
    implicitHeight: balanceDialogCol.implicitHeight + 48

    radius: 14
    color: "#171e2f"

    border.color: "#2d3748"
    border.width: 1

    z: 101

    Column {
        id: balanceDialogCol

        anchors.fill: parent
        anchors.margins: 28

        spacing: 20

        // ───── Header ─────
        RowLayout {
            width: parent.width

            Text {
                text: "Add Balance"
                color: "#ffffff"
                font.pixelSize: 18
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "✕"
                color: "#9ca3af"
                font.pixelSize: 16

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        dashboard.showAddBalanceDialog= false
                    }
                }
            }
        }

        // ───────────────── STUDENT SELECT ─────────────────
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

                        text: dashboard.selectedBalanceStudent !== ""
                              ? dashboard.selectedBalanceStudent + " (" + dashboard.selectedBalanceStudentId + ")"
                              : "Select a student"

                        color: dashboard.selectedBalanceStudent !== ""
                               ? "#ffffff"
                               : "#6b7280"

                        font.pixelSize: 13
                        elide: Text.ElideRight
                    }

                    Text {
                        text: dashboard.showselectedBalanceStudentDropdown ? "▲" : "▼"
                        color: "#9ca3af"
                        font.pixelSize: 9
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        dashboard.showBalanceStudentDropdown =
                                !dashboard.showBalanceStudentDropdown
                    }
                }
            }

            // ───── Dropdown ─────
            Rectangle {
                visible: dashboard.showBalanceStudentDropdown

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

                    // Search
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

                            onTextChanged:
                                dashboard.balanceStudentSearchText = text

                            Text {
                                visible: parent.text === ""

                                text: "Search student..."

                                color: "#6b7280"

                                anchors.verticalCenter:
                                         parent.verticalCenter
                            }
                        }
                    }

                    // Student List
                    Flickable {
                        width: parent.width
                        height: 150

                        clip: true

                        contentHeight: balanceStudentList.height

                        Column {
                            id: balanceStudentList

                            width: parent.width
                            spacing: 4

                            Repeater {
                                model: students

                                delegate: Rectangle {
                                    width: parent.width

                                    height: visible ? 40 : 0

                                    visible:
                                        name.toLowerCase().includes(
                                            dashboard.balanceStudentSearchText.toLowerCase()
                                        )
                                        ||
                                        userId.toLowerCase().includes(
                                            dashboard.balanceStudentSearchText.toLowerCase()
                                        )

                                    radius: 6

                                    color:
                                        balanceHover.containsMouse
                                        ? "#1e293b"
                                        : "transparent"

                                    Text {
                                        anchors.verticalCenter:
                                                 parent.verticalCenter

                                        anchors.left: parent.left
                                        anchors.leftMargin: 12

                                        width: parent.width - 24

                                        text:
                                         name + " (" + userId + ")  Balance: " + balance

                                        color: "#e5e7eb"

                                        font.pixelSize: 12

                                        elide: Text.ElideRight
                                    }

                                    MouseArea {
                                        id: balanceHover

                                        anchors.fill: parent

                                        hoverEnabled: true

                                        cursorShape:
                                            Qt.PointingHandCursor

                                        onClicked: {
                                            dashboard.selectedBalanceStudent = name
                                            dashboard.selectedBalanceStudentId = userId

                                            dashboard.showBalanceStudentDropdown = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ───────────────── BALANCE INPUT ─────────────────
        Column {
            width: parent.width
            spacing: 8

            Text {
                text: "Balance Amount"
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

                TextInput {
                    id: balanceInput

                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12

                    color: "#ffffff"

                    font.pixelSize: 13

                    verticalAlignment: Text.AlignVCenter

                    validator: DoubleValidator {
                        bottom: 0
                    }

                    Text {
                        visible: balanceInput.text === ""

                        text: balance

                        color: "#6b7280"

                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // ───────────────── ACTION BUTTONS ─────────────────
        Row {
            width: parent.width
            spacing: 12

            Rectangle {
                width: (parent.width - 12) / 2
                height: 44

                radius: 8

                color: "#374151"

                Text {
                    anchors.centerIn: parent

                    text: "Cancel"

                    color: "#ffffff"

                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        dashboard.showAddBalanceDialog = false

                    }
                }
            }

            Rectangle {
                width: (parent.width - 12) / 2
                height: 44

                radius: 8

                color: "#10b981"

                Text {
                    anchors.centerIn: parent

                    text: "Add Balance"

                    color: "#ffffff"

                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {

                        if (dashboard.selectedBalanceStudentId === ""
                                || balanceInput.text === "")
                            return
                        let success = lms.addBalance(
                                    dashboard.selectedBalanceStudentId,
                                    parseFloat(balanceInput.text)
                                    )

                        if (success) {

                            dashboard.showAddBalanceDialog = false

                            balanceInput.text = ""

                            dashboard.balanceStudent = ""
                            dashboard.balanceStudentId = ""
                            refreshUsers()
                        }
                        else console.log(success);
                    }
                }
            }
        }
    }
}
// ───────────────── REPORT SUCCESS OVERLAY ─────────────────
Rectangle {
    visible: dashboard.showReportDialog
    anchors.fill: parent
    color: "#000000"
    opacity: 0.6
    z: 200

    MouseArea {
        anchors.fill: parent
        onClicked: dashboard.showReportDialog = false
    }
}

// ───────────────── REPORT SUCCESS DIALOG ─────────────────
Rectangle {
    visible: dashboard.showReportDialog

    anchors.centerIn: parent

    width: 460
    height: 220

    radius: 14

    color: "#171e2f"

    border.color: "#2d3748"
    border.width: 1

    z: 201

    Column {
        anchors.fill: parent
        anchors.margins: 28

        spacing: 20

        RowLayout {
            width: parent.width

            Text {
                text: "Report Generated"
                color: "#ffffff"
                font.pixelSize: 18
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: "✕"
                color: "#9ca3af"
                font.pixelSize: 16

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: dashboard.showReportDialog = false
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 70

            radius: 10

            color: "#0f1117"

            border.color: "#2d3748"
            border.width: 1

            Text {
                anchors.fill: parent
                anchors.margins: 14

                text: dashboard.reportPath

                color: "#10b981"

                font.pixelSize: 13

                wrapMode: Text.WrapAnywhere

                verticalAlignment: Text.AlignVCenter
            }
        }

        Text {
            text: "PDF report exported successfully."
            color: "#9ca3af"
            font.pixelSize: 12
        }

        Rectangle {
            width: parent.width
            height: 42

            radius: 8

            color: "#3b82f6"

            Text {
                anchors.centerIn: parent

                text: "OK"

                color: "#ffffff"

                font.bold: true
            }

            MouseArea {
                anchors.fill: parent

                cursorShape: Qt.PointingHandCursor

                onClicked: dashboard.showReportDialog = false
            }
        }
    }
}
}
