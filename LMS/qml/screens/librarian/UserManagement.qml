import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// Users.qml
Rectangle {
    id: usersView
    anchors.fill: parent
    color: "#0f1117"

    // ── User data model ────────────────────────────────────────────────────
    ListModel {
        id: usersModel

        ListElement { userId: "S001"; name: "John Doe";    email: "john@example.com";  role: "Student";   membership: "Gold";     status: "active"   }
        ListElement { userId: "S002"; name: "Jane Smith";  email: "jane@example.com";  role: "Student";   membership: "Platinum"; status: "active"   }
        ListElement { userId: "S003"; name: "Bob Johnson"; email: "bob@example.com";   role: "Student";   membership: "Gold";     status: "active"   }
        ListElement { userId: "S004"; name: "Alice Brown"; email: "alice@example.com"; role: "Student";   membership: "Silver";   status: "active"   }
        ListElement { userId: "L001"; name: "Admin User";  email: "admin@lib.com";     role: "Librarian"; membership: "-";        status: "active"   }
    }

    // ── Counters (computed from model) ─────────────────────────────────────
    function totalUsers()    { return usersModel.count }
    function totalStudents() {
        var c = 0; for (var i = 0; i < usersModel.count; i++) if (usersModel.get(i).role === "Student") c++; return c
    }
    function totalLibrarians() {
        var c = 0; for (var i = 0; i < usersModel.count; i++) if (usersModel.get(i).role === "Librarian") c++; return c
    }
    function activeThisMonth() {
        var c = 0; for (var i = 0; i < usersModel.count; i++) if (usersModel.get(i).status === "active") c++; return c
    }

    // ── Next ID generator ──────────────────────────────────────────────────
    property int nextStudentId: 5
    property int nextLibrarianId: 2

    function generateId(role) {
        if (role === "Student") {
            var id = "S" + String(nextStudentId).padStart(3, "0")
            nextStudentId++
            return id
        } else {
            var id = "L" + String(nextLibrarianId).padStart(3, "0")
            nextLibrarianId++
            return id
        }
    }

    // ── Filter state ───────────────────────────────────────────────────────
    property string searchText: ""
    property string filterRole: "All Roles"
    property string filterStatus: "All Status"

    // ── Dialog states ──────────────────────────────────────────────────────
    property bool showAddDialog: false
    property bool showEditDialog: false
    property bool showDeleteDialog: false
    property int editingIndex: -1
    property int deletingIndex: -1

    // ── Add form state ─────────────────────────────────────────────────────
    property string formName: ""
    property string formEmail: ""
    property string formRole: "Student"
    property string formMembership: "Silver"
    property string formStatus: "active"

    // ── Edit form state ────────────────────────────────────────────────────
    property string editName: ""
    property string editEmail: ""
    property string editRole: ""
    property string editMembership: ""
    property string editStatus: ""

    // ── Check if row is visible under current filters ──────────────────────
    function rowVisible(user) {
        var search = searchText.toLowerCase()
        if (search.length > 0) {
            if (!user.name.toLowerCase().includes(search) &&
                !user.email.toLowerCase().includes(search) &&
                !user.userId.toLowerCase().includes(search)) return false
        }
        if (filterRole !== "All Roles" && user.role !== filterRole) return false
        if (filterStatus !== "All Status" && user.status !== filterStatus) return false
        return true
    }

    // ── Visible count ──────────────────────────────────────────────────────
    function visibleCount() {
        var c = 0
        for (var i = 0; i < usersModel.count; i++) if (rowVisible(usersModel.get(i))) c++
        return c
    }

    // ── Add user ───────────────────────────────────────────────────────────
    function addUser() {
        if (!formName || !formEmail) return
        usersModel.append({
            userId: generateId(formRole),
            name: formName,
            email: formEmail,
            role: formRole,
            membership: formRole === "Librarian" ? "-" : formMembership,
            status: formStatus
        })
        resetForm()
        showAddDialog = false
        statsRefresh.restart()
    }

    // ── Save edit ──────────────────────────────────────────────────────────
    function saveEdit() {
        if (editingIndex < 0 || !editName || !editEmail) return
        usersModel.setProperty(editingIndex, "name", editName)
        usersModel.setProperty(editingIndex, "email", editEmail)
        usersModel.setProperty(editingIndex, "role", editRole)
        usersModel.setProperty(editingIndex, "membership", editRole === "Librarian" ? "-" : editMembership)
        usersModel.setProperty(editingIndex, "status", editStatus)
        showEditDialog = false
        statsRefresh.restart()
    }

    // ── Delete user ────────────────────────────────────────────────────────
    function deleteUser() {
        if (deletingIndex < 0) return
        usersModel.remove(deletingIndex, 1)
        showDeleteDialog = false
        statsRefresh.restart()
    }

    function resetForm() {
        formName = ""; formEmail = ""; formRole = "Student"
        formMembership = "Silver"; formStatus = "active"
    }

    function openEdit(idx) {
        var u = usersModel.get(idx)
        editingIndex = idx
        editName = u.name
        editEmail = u.email
        editRole = u.role
        editMembership = u.membership
        editStatus = u.status
        showEditDialog = true
    }

    // Timer to poke stats bindings after model changes
    Timer { id: statsRefresh; interval: 10; onTriggered: statsArea.rebind() }

    // ── Membership badge color ─────────────────────────────────────────────
    function membershipBg(m)   { return m === "Gold" ? "#78350f" : m === "Platinum" ? "#1e1b4b" : m === "Silver" ? "#1f2937" : "#1a1f2e" }
    function membershipFg(m)   { return m === "Gold" ? "#fbbf24" : m === "Platinum" ? "#a78bfa" : m === "Silver" ? "#9ca3af" : "#6b7280" }

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
            border.color: "#2d3748"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 28
                anchors.rightMargin: 28
                spacing: 16

                ColumnLayout {
                    spacing: 6
                    Text {
                        text: "User Management"
                        color: "#ffffff"
                        font.pixelSize: 22
                        font.bold: true
                    }
                    Text {
                        id: subtitleText
                        text: "Manage students and librarians (" + usersView.totalUsers() + " users)"
                        color: "#9ca3af"
                        font.pixelSize: 13
                    }
                }

                Item { Layout.fillWidth: true }

                // Add User button
                Rectangle {
                    width: 130; height: 40
                    radius: 8
                    color: addBtnMA.containsPress ? "#1d4ed8"
                         : addBtnMA.containsMouse ? "#2563eb"
                         : "#3b82f6"
                    Behavior on color { ColorAnimation { duration: 100 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Image {
                            anchors.left: parent.left
                            source: "qrc:/assets/icons/adduser.png"
                            width: 5
                            height: 5
                        }
                        Text { text: "Add User"; color: "#ffffff"; font.pixelSize: 13; font.bold: true }
                    }

                    MouseArea {
                        id: addBtnMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { usersView.resetForm(); usersView.showAddDialog = true }
                    }
                }
            }
        }

        // ── Filter bar ─────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 64
            color: "#1a1f2e"
            border.color: "#2d3748"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 28
                anchors.rightMargin: 28
                spacing: 12

                // Search
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 8
                    color: "#0f1117"
                    border.color: searchInput.activeFocus ? "#3b82f6" : "#2d3748"
                    border.width: 1
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Text { text: "🔍"; font.pixelSize: 14; opacity: 0.5 }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            color: "#e5e7eb"
                            font.pixelSize: 13
                            clip: true
                            selectByMouse: true
                            verticalAlignment: TextInput.AlignVCenter
                            onTextChanged: usersView.searchText = text

                            Text {
                                visible: !parent.text
                                text: "Search by name, email, or ID..."
                                color: "#6b7280"
                                font: parent.font
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                // Role filter
                Rectangle {
                    width: 130; height: 40
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
                            text: usersView.filterRole
                            color: "#e5e7eb"
                            font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter
                        }
                        Text { text: "▼"; color: "#9ca3af"; font.pixelSize: 9 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: roleMenu.open()
                    }

                    Menu {
                        id: roleMenu
                        MenuItem { text: "All Roles";  onTriggered: usersView.filterRole = text }
                        MenuItem { text: "Student";    onTriggered: usersView.filterRole = text }
                        MenuItem { text: "Librarian";  onTriggered: usersView.filterRole = text }
                    }
                }

                // Status filter
                Rectangle {
                    width: 130; height: 40
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
                            text: usersView.filterStatus
                            color: "#e5e7eb"
                            font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter
                        }
                        Text { text: "▼"; color: "#9ca3af"; font.pixelSize: 9 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: statusMenu.open()
                    }

                    Menu {
                        id: statusMenu
                        MenuItem { text: "All Status"; onTriggered: usersView.filterStatus = text }
                        MenuItem { text: "active";     onTriggered: usersView.filterStatus = text }
                        MenuItem { text: "inactive";   onTriggered: usersView.filterStatus = text }
                    }
                }
            }
        }

        // ── Table header row ───────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 44
            color: "#1a1f2e"
            border.color: "#2d3748"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 28
                anchors.rightMargin: 28
                spacing: 0

                Text { Layout.preferredWidth: 70;  text: "User ID";    color: "#9ca3af"; font.pixelSize: 12; font.bold: true }
                Text { Layout.preferredWidth: 130; text: "Name";       color: "#9ca3af"; font.pixelSize: 12; font.bold: true }
                Text { Layout.fillWidth: true;     text: "Email";      color: "#9ca3af"; font.pixelSize: 12; font.bold: true }
                Text { Layout.preferredWidth: 90;  text: "Role";       color: "#9ca3af"; font.pixelSize: 12; font.bold: true }
                Text { Layout.preferredWidth: 95;  text: "Membership"; color: "#9ca3af"; font.pixelSize: 12; font.bold: true }
                Text { Layout.preferredWidth: 75;  text: "Status";     color: "#9ca3af"; font.pixelSize: 12; font.bold: true }
                Text { Layout.preferredWidth: 70;  text: "Actions";    color: "#9ca3af"; font.pixelSize: 12; font.bold: true; horizontalAlignment: Text.AlignHCenter }
            }
        }

        // ── Table body ─────────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Flickable {
                id: tableFlick
                anchors.fill: parent
                anchors.rightMargin: 7
                contentWidth: width
                contentHeight: tableCol.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: tableCol
                    width: tableFlick.width
                    spacing: 0

                    Repeater {
                        id: usersRepeater
                        model: usersModel

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 56
                            visible: usersView.rowVisible(usersModel.get(index))
                            color: rowMA.containsMouse ? "#1e2535" : "#0f1117"
                            border.color: "#1e2535"
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 100 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 28
                                anchors.rightMargin: 28
                                spacing: 0

                                // User ID
                                Text {
                                    Layout.preferredWidth: 70
                                    text: model.userId
                                    color: "#9ca3af"
                                    font.pixelSize: 12
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                }

                                // Name
                                Text {
                                    Layout.preferredWidth: 130
                                    text: model.name
                                    color: "#ffffff"
                                    font.pixelSize: 13
                                    font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                // Email
                                Text {
                                    Layout.fillWidth: true
                                    text: model.email
                                    color: "#9ca3af"
                                    font.pixelSize: 12
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                // Role
                                Text {
                                    Layout.preferredWidth: 90
                                    text: model.role
                                    color: model.role === "Librarian" ? "#60a5fa" : "#e5e7eb"
                                    font.pixelSize: 12
                                    verticalAlignment: Text.AlignVCenter
                                }

                                // Membership badge
                                Item {
                                    Layout.preferredWidth: 95
                                    height: parent.height

                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: model.membership === "-" ? 24 : 74
                                        height: 26
                                        radius: 13
                                        color: model.membership === "-" ? "transparent" : usersView.membershipBg(model.membership)

                                        Text {
                                            anchors.centerIn: parent
                                            text: model.membership
                                            color: usersView.membershipFg(model.membership)
                                            font.pixelSize: 11
                                            font.bold: model.membership !== "-"
                                        }
                                    }
                                }

                                // Status badge
                                Item {
                                    Layout.preferredWidth: 85
                                    height: parent.height

                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 66; height: 24
                                        radius: 12
                                        color: model.status === "active" ? "#052e16" : "#1f2937"
                                        border.color: model.status === "active" ? "#10b981" : "#6b7280"
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: model.status
                                            color: model.status === "active" ? "#10b981" : "#6b7280"
                                            font.pixelSize: 11
                                            font.bold: true
                                        }
                                    }
                                }

                                // Actions
                                RowLayout {
                                    Layout.preferredWidth: 70
                                    spacing: 8

                                    // Edit

                                    Rectangle {
                                        width: 30; height: 30
                                        radius: 6
                                        color: editMA.containsMouse ? "#1e3a5f" : "transparent"
                                        Behavior on color { ColorAnimation { duration: 100 } }

                                        Image {
                                            anchors.centerIn: parent
                                            source: "qrc:/assets/icons/edit.png"
                                            width: 16
                                            height: 16
                                        }

                                        MouseArea {
                                            id: editMA
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: usersView.openEdit(index)
                                        }
                                    }

                                    // Delete (not for librarian role)
                                    Rectangle {
                                        width: 30; height: 30
                                        radius: 6
                                        visible: model.role !== "Librarian"
                                        color: delMA.containsMouse ? "#3b1212" : "transparent"
                                        Behavior on color { ColorAnimation { duration: 100 } }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "🗑"
                                            font.pixelSize: 14
                                        }

                                        MouseArea {
                                            id: delMA
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: { usersView.deletingIndex = index; usersView.showDeleteDialog = true }
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
                    }

                    // Empty state
                    Rectangle {
                        Layout.fillWidth: true
                        height: 120
                        color: "transparent"
                        visible: usersView.visibleCount() === 0

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text { Layout.alignment: Qt.AlignHCenter; text: "👥"; font.pixelSize: 36 }
                            Text { Layout.alignment: Qt.AlignHCenter; text: "No users found"; color: "#6b7280"; font.pixelSize: 14; font.bold: true }
                            Text { Layout.alignment: Qt.AlignHCenter; text: "Try adjusting your filters"; color: "#4b5563"; font.pixelSize: 12 }
                        }
                    }
                }
            }

            // Scrollbar
            ScrollBar {
                id: vBar
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.rightMargin: 1
                orientation: Qt.Vertical
                size: tableFlick.visibleArea.heightRatio
                position: tableFlick.visibleArea.yPosition
                width: 6
                policy: ScrollBar.AsNeeded
                onPositionChanged: if (pressed) tableFlick.contentY = position * tableFlick.contentHeight
                contentItem: Rectangle { radius: 3; color: vBar.pressed ? "#9ca3af" : "#374151" }
            }

            Connections {
                target: tableFlick
                function onContentYChanged() {
                    if (!vBar.pressed) vBar.position = tableFlick.contentY / tableFlick.contentHeight
                }
            }
        }

        // ── Stats bar ──────────────────────────────────────────────────────
        Rectangle {
            id: statsArea
            Layout.fillWidth: true
            height: 80
            color: "#1a1f2e"
            border.color: "#2d3748"
            border.width: 1

            property int s_total:    usersView.totalUsers()
            property int s_students: usersView.totalStudents()
            property int s_libs:     usersView.totalLibrarians()
            property int s_active:   usersView.activeThisMonth()

            function rebind() {
                s_total    = usersView.totalUsers()
                s_students = usersView.totalStudents()
                s_libs     = usersView.totalLibrarians()
                s_active   = usersView.activeThisMonth()
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 28
                anchors.rightMargin: 28
                spacing: 0

                Repeater {
                    model: [
                        { label: "Total Users",       value: statsArea.s_total,    accent: "#ffffff" },
                        { label: "Students",          value: statsArea.s_students, accent: "#ffffff" },
                        { label: "Librarians",        value: statsArea.s_libs,     accent: "#ffffff" },
                        { label: "Active This Month", value: statsArea.s_active,   accent: "#10b981" }
                    ]

                    delegate: Item {
                        Layout.fillWidth: true
                        height: statsArea.height

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: modelData.value
                                color: modelData.accent
                                font.pixelSize: 24
                                font.bold: true
                            }

                            Text {
                                text: modelData.label
                                color: "#9ca3af"
                                font.pixelSize: 12
                            }
                        }

                        // Divider (skip last)
                        Rectangle {
                            visible: index < 3
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 1; height: 36
                            color: "#2d3748"
                        }
                    }
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // ADD USER DIALOG
    // ══════════════════════════════════════════════════════════════════════

    Rectangle {
        visible: usersView.showAddDialog || usersView.showEditDialog
        anchors.fill: parent
        color: "#000000"
        opacity: 0.6
        MouseArea {
            anchors.fill: parent
            onClicked: { usersView.showAddDialog = false; usersView.showEditDialog = false }
        }
    }

    Rectangle {
        visible: usersView.showAddDialog
        anchors.centerIn: parent
        width: 480
        implicitHeight: addDialogCol.implicitHeight + 48
        radius: 12
        color: "#1a1f2e"
        border.color: "#2d3748"
        border.width: 1

        ColumnLayout {
            id: addDialogCol
            anchors.fill: parent
            anchors.margins: 28
            spacing: 20

            // Title + close
            RowLayout {
                Layout.fillWidth: true
                Text { text: "Add New User"; color: "#ffffff"; font.pixelSize: 18; font.bold: true }
                Item { Layout.fillWidth: true }
                Text {
                    text: "✕"; color: "#9ca3af"; font.pixelSize: 16
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: usersView.showAddDialog = false }
                }
            }

            // Name + Email row
            RowLayout { spacing: 14; Layout.fillWidth: true
                ColumnLayout { spacing: 8; Layout.fillWidth: true
                    Text { text: "Full Name"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true; height: 40; radius: 8
                        color: "#0f1117"; border.color: addNameInput.activeFocus ? "#3b82f6" : "#2d3748"; border.width: 1
                        TextInput {
                            id: addNameInput
                            anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                            color: "#e5e7eb"; font.pixelSize: 13; clip: true; selectByMouse: true
                            verticalAlignment: TextInput.AlignVCenter
                            onTextChanged: usersView.formName = text
                            Text { visible: !parent.text; text: "Enter full name"; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }
                }
                ColumnLayout { spacing: 8; Layout.fillWidth: true
                    Text { text: "Email"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true; height: 40; radius: 8
                        color: "#0f1117"; border.color: addEmailInput.activeFocus ? "#3b82f6" : "#2d3748"; border.width: 1
                        TextInput {
                            id: addEmailInput
                            anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                            color: "#e5e7eb"; font.pixelSize: 13; clip: true; selectByMouse: true
                            verticalAlignment: TextInput.AlignVCenter
                            onTextChanged: usersView.formEmail = text
                            Text { visible: !parent.text; text: "Enter email"; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }
                }
            }

            // Role + Membership row
            RowLayout { spacing: 14; Layout.fillWidth: true
                ColumnLayout { spacing: 8; Layout.fillWidth: true
                    Text { text: "Role"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true; height: 40; radius: 8
                        color: "#0f1117"; border.color: "#2d3748"; border.width: 1
                        RowLayout { anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                            Text { Layout.fillWidth: true; text: usersView.formRole; color: "#e5e7eb"; font.pixelSize: 13 }
                            Text { text: "▼"; color: "#9ca3af"; font.pixelSize: 9 }
                        }
                        MouseArea { anchors.fill: parent; onClicked: addRoleMenu.open() }
                        Menu {
                            id: addRoleMenu
                            MenuItem { text: "Student";   onTriggered: { usersView.formRole = text; if (text === "Librarian") usersView.formMembership = "-" } }
                            MenuItem { text: "Librarian"; onTriggered: { usersView.formRole = text; usersView.formMembership = "-" } }
                        }
                    }
                }

                ColumnLayout { spacing: 8; Layout.fillWidth: true
                    Text { text: "Membership"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true; height: 40; radius: 8
                        enabled: usersView.formRole === "Student"
                        opacity: usersView.formRole === "Student" ? 1.0 : 0.4
                        color: "#0f1117"; border.color: "#2d3748"; border.width: 1
                        RowLayout { anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                            Text { Layout.fillWidth: true; text: usersView.formRole === "Librarian" ? "-" : usersView.formMembership; color: "#e5e7eb"; font.pixelSize: 13 }
                            Text { text: "▼"; color: "#9ca3af"; font.pixelSize: 9 }
                        }
                        MouseArea { anchors.fill: parent; onClicked: if (usersView.formRole === "Student") addMshipMenu.open() }
                        Menu {
                            id: addMshipMenu
                            MenuItem { text: "Silver";   onTriggered: usersView.formMembership = text }
                            MenuItem { text: "Gold";     onTriggered: usersView.formMembership = text }
                            MenuItem { text: "Platinum"; onTriggered: usersView.formMembership = text }
                        }
                    }
                }
            }

            // Status
            ColumnLayout { spacing: 8
                Text { text: "Status"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                RowLayout { spacing: 12
                    Repeater {
                        model: ["active", "inactive"]
                        delegate: Rectangle {
                            width: 120; height: 38; radius: 8
                            color: usersView.formStatus === modelData ? "#1d4ed8" : "#0f1117"
                            border.color: usersView.formStatus === modelData ? "#3b82f6" : "#2d3748"; border.width: 1
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Text { anchors.centerIn: parent; text: modelData; color: "#ffffff"; font.pixelSize: 13; font.bold: usersView.formStatus === modelData }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: usersView.formStatus = modelData }
                        }
                    }
                }
            }

            // Buttons
            RowLayout { Layout.fillWidth: true; spacing: 12
                Rectangle {
                    width: 110; height: 40; radius: 6; color: "transparent"; border.color: "#6b7280"; border.width: 1
                    Text { anchors.centerIn: parent; text: "Cancel"; color: "#e5e7eb"; font.pixelSize: 13; font.bold: true }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: usersView.showAddDialog = false }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 40; radius: 6
                    color: (usersView.formName && usersView.formEmail) ? "#3b82f6" : "#374151"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text { anchors.centerIn: parent; text: "Add User"; color: "#ffffff"; font.pixelSize: 13; font.bold: true }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        enabled: usersView.formName && usersView.formEmail
                        onClicked: {
                            usersView.addUser()
                            addNameInput.text = ""
                            addEmailInput.text = ""
                        }
                    }
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // EDIT USER DIALOG
    // ══════════════════════════════════════════════════════════════════════

    Rectangle {
        visible: usersView.showEditDialog
        anchors.centerIn: parent
        width: 480
        implicitHeight: editDialogCol.implicitHeight + 48
        radius: 12
        color: "#1a1f2e"
        border.color: "#2d3748"
        border.width: 1

        ColumnLayout {
            id: editDialogCol
            anchors.fill: parent
            anchors.margins: 28
            spacing: 20

            RowLayout {
                Layout.fillWidth: true
                Text { text: "Edit User"; color: "#ffffff"; font.pixelSize: 18; font.bold: true }
                Item { Layout.fillWidth: true }
                Text {
                    text: "✕"; color: "#9ca3af"; font.pixelSize: 16
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: usersView.showEditDialog = false }
                }
            }

            RowLayout { spacing: 14; Layout.fillWidth: true
                ColumnLayout { spacing: 8; Layout.fillWidth: true
                    Text { text: "Full Name"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true; height: 40; radius: 8
                        color: "#0f1117"; border.color: editNameInput.activeFocus ? "#3b82f6" : "#2d3748"; border.width: 1
                        TextInput {
                            id: editNameInput
                            anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                            color: "#e5e7eb"; font.pixelSize: 13; clip: true; selectByMouse: true
                            verticalAlignment: TextInput.AlignVCenter
                            text: usersView.editName
                            onTextChanged: usersView.editName = text
                        }
                    }
                }
                ColumnLayout { spacing: 8; Layout.fillWidth: true
                    Text { text: "Email"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true; height: 40; radius: 8
                        color: "#0f1117"; border.color: editEmailInput.activeFocus ? "#3b82f6" : "#2d3748"; border.width: 1
                        TextInput {
                            id: editEmailInput
                            anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                            color: "#e5e7eb"; font.pixelSize: 13; clip: true; selectByMouse: true
                            verticalAlignment: TextInput.AlignVCenter
                            text: usersView.editEmail
                            onTextChanged: usersView.editEmail = text
                        }
                    }
                }
            }

            RowLayout { spacing: 14; Layout.fillWidth: true
                ColumnLayout { spacing: 8; Layout.fillWidth: true
                    Text { text: "Role"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true; height: 40; radius: 8
                        color: "#0f1117"; border.color: "#2d3748"; border.width: 1
                        RowLayout { anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                            Text { Layout.fillWidth: true; text: usersView.editRole; color: "#e5e7eb"; font.pixelSize: 13 }
                            Text { text: "▼"; color: "#9ca3af"; font.pixelSize: 9 }
                        }
                        MouseArea { anchors.fill: parent; onClicked: editRoleMenu.open() }
                        Menu {
                            id: editRoleMenu
                            MenuItem { text: "Student";   onTriggered: { usersView.editRole = text } }
                            MenuItem { text: "Librarian"; onTriggered: { usersView.editRole = text; usersView.editMembership = "-" } }
                        }
                    }
                }
                ColumnLayout { spacing: 8; Layout.fillWidth: true
                    Text { text: "Membership"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true; height: 40; radius: 8
                        enabled: usersView.editRole === "Student"; opacity: usersView.editRole === "Student" ? 1 : 0.4
                        color: "#0f1117"; border.color: "#2d3748"; border.width: 1
                        RowLayout { anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                            Text { Layout.fillWidth: true; text: usersView.editRole === "Librarian" ? "-" : usersView.editMembership; color: "#e5e7eb"; font.pixelSize: 13 }
                            Text { text: "▼"; color: "#9ca3af"; font.pixelSize: 9 }
                        }
                        MouseArea { anchors.fill: parent; onClicked: if (usersView.editRole === "Student") editMshipMenu.open() }
                        Menu {
                            id: editMshipMenu
                            MenuItem { text: "Silver";   onTriggered: usersView.editMembership = text }
                            MenuItem { text: "Gold";     onTriggered: usersView.editMembership = text }
                            MenuItem { text: "Platinum"; onTriggered: usersView.editMembership = text }
                        }
                    }
                }
            }

            ColumnLayout { spacing: 8
                Text { text: "Status"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                RowLayout { spacing: 12
                    Repeater {
                        model: ["active", "inactive"]
                        delegate: Rectangle {
                            width: 120; height: 38; radius: 8
                            color: usersView.editStatus === modelData ? "#1d4ed8" : "#0f1117"
                            border.color: usersView.editStatus === modelData ? "#3b82f6" : "#2d3748"; border.width: 1
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Text { anchors.centerIn: parent; text: modelData; color: "#ffffff"; font.pixelSize: 13; font.bold: usersView.editStatus === modelData }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: usersView.editStatus = modelData }
                        }
                    }
                }
            }

            RowLayout { Layout.fillWidth: true; spacing: 12
                Rectangle {
                    width: 110; height: 40; radius: 6; color: "transparent"; border.color: "#6b7280"; border.width: 1
                    Text { anchors.centerIn: parent; text: "Cancel"; color: "#e5e7eb"; font.pixelSize: 13; font.bold: true }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: usersView.showEditDialog = false }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 40; radius: 6
                    color: (usersView.editName && usersView.editEmail) ? "#3b82f6" : "#374151"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text { anchors.centerIn: parent; text: "Save Changes"; color: "#ffffff"; font.pixelSize: 13; font.bold: true }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; enabled: usersView.editName && usersView.editEmail; onClicked: usersView.saveEdit() }
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // DELETE CONFIRMATION DIALOG
    // ══════════════════════════════════════════════════════════════════════

    Rectangle {
        visible: usersView.showDeleteDialog
        anchors.fill: parent; color: "#000000"; opacity: 0.6
        MouseArea { anchors.fill: parent; onClicked: usersView.showDeleteDialog = false }
    }

    Rectangle {
        visible: usersView.showDeleteDialog
        anchors.centerIn: parent
        width: 380; height: 200; radius: 12
        color: "#1a1f2e"; border.color: "#2d3748"; border.width: 1

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 28; spacing: 20

            Text { text: "🗑  Delete User"; color: "#ffffff"; font.pixelSize: 16; font.bold: true }

            Text {
                text: usersView.deletingIndex >= 0 && usersView.deletingIndex < usersModel.count
                      ? "Are you sure you want to delete " + usersModel.get(usersView.deletingIndex).name + "? This cannot be undone."
                      : ""
                color: "#9ca3af"; font.pixelSize: 13; wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            RowLayout { Layout.fillWidth: true; spacing: 12
                Rectangle {
                    Layout.fillWidth: true; height: 40; radius: 6; color: "transparent"; border.color: "#6b7280"; border.width: 1
                    Text { anchors.centerIn: parent; text: "Cancel"; color: "#e5e7eb"; font.pixelSize: 13; font.bold: true }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: usersView.showDeleteDialog = false }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 40; radius: 6; color: "#dc2626"
                    Text { anchors.centerIn: parent; text: "Delete"; color: "#ffffff"; font.pixelSize: 13; font.bold: true }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: usersView.deleteUser() }
                }
            }
        }
    }
}
