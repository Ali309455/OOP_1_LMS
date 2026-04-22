import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// ProfileSettings.qml
Rectangle {
    id: profileView
    color: "#0f1117"

    // ── Role ───────────────────────────────────────────────────────────────
    property string userRole: "user"   // "librarian" or "user"

    // ── Profile data ───────────────────────────────────────────────────────
    property string fullName:  "John Doe"
    property string userEmail: "user@example.com"
    property string role:      userRole === "librarian" ? "Librarian" : "Student"

    // ── Stats ──────────────────────────────────────────────────────────────
    property int booksBorrowed:  47
    property int reviewsWritten: 12
    property int memberSince:    2024

    // ── Feedback ───────────────────────────────────────────────────────────
    property string profileMsg:     ""
    property bool   profileSuccess: false
    property string passwordMsg:    ""
    property bool   passwordSuccess: false

    Timer { id: profileFeedbackTimer;  interval: 3000; onTriggered: profileMsg  = "" }
    Timer { id: passwordFeedbackTimer; interval: 3000; onTriggered: passwordMsg = "" }

    // ── Validation helpers ─────────────────────────────────────────────────
    function isValidEmail(e) { return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e) }

    function passwordStrength(p) {
        var s = 0
        if (p.length >= 8)            s++
        if (/[A-Z]/.test(p))          s++
        if (/[0-9]/.test(p))          s++
        if (/[^A-Za-z0-9]/.test(p))   s++
        return s
    }

    // ── Save profile ───────────────────────────────────────────────────────
    function saveProfile() {
        var n = nameInput.text.trim()
        var e = emailInput.text.trim()
        if (n === "")          { profileMsg = "Full name cannot be empty.";          profileSuccess = false; return }
        if (!isValidEmail(e))  { profileMsg = "Please enter a valid email address."; profileSuccess = false; return }
        profileView.fullName  = n
        profileView.userEmail = e
        profileMsg = "Profile updated successfully."
        profileSuccess = true
        profileFeedbackTimer.restart()
    }

    // ── Change password ────────────────────────────────────────────────────
    property string storedPassword: "password123"

    function changePassword() {
        var cur  = currentPwInput.text
        var nw   = newPwInput.text
        var conf = confirmPwInput.text
        if (cur === "")            { passwordMsg = "Current password is required.";                 passwordSuccess = false; return }
        if (cur !== storedPassword){ passwordMsg = "Current password is incorrect.";                passwordSuccess = false; return }
        if (nw.length < 8)         { passwordMsg = "New password must be at least 8 characters.";  passwordSuccess = false; return }
        if (nw === cur)            { passwordMsg = "New password must differ from current.";        passwordSuccess = false; return }
        if (nw !== conf)           { passwordMsg = "Passwords do not match.";                       passwordSuccess = false; return }
        storedPassword = nw
        currentPwInput.text = ""; newPwInput.text = ""; confirmPwInput.text = ""
        passwordMsg = "Password updated successfully."
        passwordSuccess = true
        passwordFeedbackTimer.restart()
    }

    // ══════════════════════════════════════════════════════════════════════
    // ── Page header  (same pattern as Reviews headerBar) ──────────────────
    // ══════════════════════════════════════════════════════════════════════
    Rectangle {
        id: headerBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        color: "#1a1f2e"
        border.color: "#2d3748"; border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 28; anchors.rightMargin: 28
            anchors.topMargin: 20; anchors.bottomMargin: 16
            spacing: 6
            Text { text: "Profile Settings";              color: "#ffffff";  font.pixelSize: 24; font.bold: true }
            Text { text: "Manage your account information"; color: "#9ca3af"; font.pixelSize: 13 }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // ── Flickable  (same pattern as Reviews reviewsFlick) ─────────────────
    // ══════════════════════════════════════════════════════════════════════
    Flickable {
        id: mainFlick
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 32          // room for draggable scrollbar
        contentWidth: width
        contentHeight: leftCol.y + Math.max(leftCol.implicitHeight, rightCol.implicitHeight) + 48
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        // ── RIGHT column  (declared first so leftCol can anchor to it) ────
        Column {
            id: rightCol
            anchors.top: parent.top;   anchors.topMargin: 28
            anchors.right: parent.right; anchors.rightMargin: 28
            width: 260
            spacing: 20

            // Profile Picture card
            Rectangle {
                width: parent.width
                height: profilePicCol.implicitHeight + 48
                radius: 12
                color: "#1a1f2e"; border.color: "#2d3748"; border.width: 1

                Column {
                    id: profilePicCol
                    anchors { fill: parent; margins: 24 }
                    spacing: 18

                    Text { text: "Profile Picture"; color: "#ffffff"; font.pixelSize: 15; font.bold: true }

                    // Avatar circle with initial
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 100; height: 100; radius: 50
                        color: "#3b82f6"
                        Text {
                            anchors.centerIn: parent
                            text: profileView.fullName.length > 0 ? profileView.fullName.charAt(0).toUpperCase() : "?"
                            color: "#ffffff"; font.pixelSize: 40; font.bold: true
                        }
                    }

                    // Change Picture button (no logic per requirements)
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 150; height: 38; radius: 8
                        color: picMA.containsMouse ? "#2d3748" : "#1e2535"
                        border.color: "#2d3748"; border.width: 1
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text { anchors.centerIn: parent; text: "Change Picture"; color: "#e5e7eb"; font.pixelSize: 13; font.bold: true }
                        MouseArea { id: picMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                    }
                }
            }

            // Account Stats card — USER ONLY
            Rectangle {
                width: parent.width
                visible: profileView.userRole === "user"
                height: visible ? statsInner.implicitHeight + 48 : 0
                radius: 12
                color: "#1a1f2e"; border.color: "#2d3748"; border.width: 1

                Column {
                    id: statsInner
                    anchors { fill: parent; margins: 24 }
                    spacing: 0

                    Text { text: "Account Stats"; color: "#ffffff"; font.pixelSize: 15; font.bold: true; bottomPadding: 16 }

                    Rectangle { width: parent.width; height: 1; color: "#2d3748" }

                    Repeater {
                        model: [
                            { label: "Books Borrowed",  value: profileView.booksBorrowed.toString()  },
                            { label: "Reviews Written", value: profileView.reviewsWritten.toString() },
                            { label: "Member Since",    value: profileView.memberSince.toString()    }
                        ]
                        delegate: Column {
                            width: parent.width
                            spacing: 0

                            Row {
                                width: parent.width; height: 48
                                Text { width: parent.width - valText.width; text: modelData.label; color: "#9ca3af"; font.pixelSize: 13; verticalAlignment: Text.AlignVCenter }
                                Text { id: valText; text: modelData.value; color: "#ffffff"; font.pixelSize: 16; font.bold: true; verticalAlignment: Text.AlignVCenter }
                            }

                            Rectangle { visible: index < 2; width: parent.width; height: 1; color: "#1e2535" }
                        }
                    }
                }
            }
        }

        // ── LEFT column ────────────────────────────────────────────────────
        Column {
            id: leftCol
            anchors.top: parent.top;   anchors.topMargin: 28
            anchors.left: parent.left; anchors.leftMargin: 28
            anchors.right: rightCol.left; anchors.rightMargin: 20
            spacing: 20

            // ── Personal Information card ──────────────────────────────────
            Rectangle {
                width: parent.width
                height: personalInner.implicitHeight + 48
                radius: 12
                color: "#1a1f2e"; border.color: "#2d3748"; border.width: 1

                Column {
                    id: personalInner
                    anchors { fill: parent; margins: 24 }
                    spacing: 18

                    Text { text: "Personal Information"; color: "#ffffff"; font.pixelSize: 16; font.bold: true }

                    // ── Full Name ──────────────────────────────────────────
                    Column { width: parent.width; spacing: 8
                        Text { text: "Full Name"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                        Rectangle {
                            width: parent.width; height: 44; radius: 8
                            color: "#0f1117"
                            border.color: nameInput.activeFocus ? "#3b82f6" : "#2d3748"; border.width: 1
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            Row {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14
                                spacing: 10
                                Text { text: "👤"; font.pixelSize: 15; opacity: 0.5; anchors.verticalCenter: parent.verticalCenter }
                                TextInput {
                                    id: nameInput
                                    width: parent.width - 34
                                    height: parent.height
                                    color: "#e5e7eb"; font.pixelSize: 13
                                    clip: true; selectByMouse: true
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: profileView.fullName
                                    Text { visible: !parent.text; text: "Enter full name"; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
                                }
                            }
                        }
                    }

                    // ── Email ──────────────────────────────────────────────
                    Column { width: parent.width; spacing: 8
                        Text { text: "Email"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                        Rectangle {
                            width: parent.width; height: 44; radius: 8
                            color: "#0f1117"
                            border.color: emailInput.activeFocus ? "#3b82f6" : "#2d3748"; border.width: 1
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            Row {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14
                                spacing: 10
                                Text { text: "✉"; font.pixelSize: 15; color: "#9ca3af"; anchors.verticalCenter: parent.verticalCenter }
                                TextInput {
                                    id: emailInput
                                    width: parent.width - 34
                                    height: parent.height
                                    color: "#e5e7eb"; font.pixelSize: 13
                                    clip: true; selectByMouse: true
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: profileView.userEmail
                                    inputMethodHints: Qt.ImhEmailCharactersOnly
                                    Text { visible: !parent.text; text: "Enter email"; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
                                }
                            }
                        }
                    }

                    // ── Role ───────────────────────────────────────────────
                    Column { width: parent.width; spacing: 8
                        Text { text: "Role"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                        Rectangle {
                            width: parent.width; height: 44; radius: 8
                            color: "#0f1117"
                            border.color: "#2d3748"; border.width: 1
                            opacity: profileView.userRole === "user" ? 0.55 : 1.0

                            Row {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14
                                spacing: 10
                                Text { text: "🛡"; font.pixelSize: 15; color: "#9ca3af"; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: profileView.role; color: "#e5e7eb"; font.pixelSize: 13; width: parent.width - 60; verticalAlignment: Text.AlignVCenter; height: parent.height }
                                Text { visible: profileView.userRole === "librarian"; text: "▼"; color: "#9ca3af"; font.pixelSize: 9; anchors.verticalCenter: parent.verticalCenter }
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: profileView.userRole === "librarian"
                                cursorShape: profileView.userRole === "librarian" ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: roleMenu.open()
                            }
                            Menu {
                                id: roleMenu
                                MenuItem { text: "Librarian"; onTriggered: profileView.role = text }
                                MenuItem { text: "Student";   onTriggered: profileView.role = text }
                            }
                        }
                        Text {
                            visible: profileView.userRole === "user"
                            text: "Role cannot be changed by users."
                            color: "#6b7280"; font.pixelSize: 11
                        }
                    }

                    // Profile feedback banner
                    Rectangle {
                        width: parent.width; height: 36; radius: 8
                        visible: profileView.profileMsg !== ""
                        color: profileView.profileSuccess ? "#052e16" : "#3b0f0f"
                        border.color: profileView.profileSuccess ? "#10b981" : "#ef4444"; border.width: 1
                        Text { anchors.centerIn: parent; text: profileView.profileMsg; color: profileView.profileSuccess ? "#10b981" : "#ef4444"; font.pixelSize: 12; font.bold: true }
                    }

                    // Save Changes
                    Rectangle {
                        width: 140; height: 42; radius: 8
                        color: saveMA.containsPress ? "#1d4ed8" : saveMA.containsMouse ? "#2563eb" : "#3b82f6"
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text { anchors.centerIn: parent; text: "Save Changes"; color: "#ffffff"; font.pixelSize: 13; font.bold: true }
                        MouseArea { id: saveMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: profileView.saveProfile() }
                    }
                }
            }

            // ── Change Password card ───────────────────────────────────────
            Rectangle {
                width: parent.width
                height: passwordInner.implicitHeight + 48
                radius: 12
                color: "#1a1f2e"; border.color: "#2d3748"; border.width: 1

                Column {
                    id: passwordInner
                    anchors { fill: parent; margins: 24 }
                    spacing: 18

                    Text { text: "Change Password"; color: "#ffffff"; font.pixelSize: 16; font.bold: true }

                    // ── Current Password ───────────────────────────────────
                    Column { width: parent.width; spacing: 8
                        Text { text: "Current Password"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                        Rectangle {
                            width: parent.width; height: 44; radius: 8
                            color: "#0f1117"
                            border.color: currentPwInput.activeFocus ? "#3b82f6" : "#2d3748"; border.width: 1
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            Row {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 10
                                Text { text: "🔒"; font.pixelSize: 14; opacity: 0.6; anchors.verticalCenter: parent.verticalCenter }
                                TextInput {
                                    id: currentPwInput
                                    width: parent.width - 34; height: parent.height
                                    color: "#e5e7eb"; font.pixelSize: 13
                                    echoMode: TextInput.Password
                                    clip: true; selectByMouse: true; verticalAlignment: TextInput.AlignVCenter
                                    Text { visible: !parent.text; text: "Enter current password"; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
                                }
                            }
                        }
                    }

                    // ── New Password ───────────────────────────────────────
                    Column { width: parent.width; spacing: 8
                        Text { text: "New Password"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                        Rectangle {
                            width: parent.width; height: 44; radius: 8
                            color: "#0f1117"
                            border.color: newPwInput.activeFocus ? "#3b82f6" : "#2d3748"; border.width: 1
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            Row {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 10
                                Text { text: "🔒"; font.pixelSize: 14; opacity: 0.6; anchors.verticalCenter: parent.verticalCenter }
                                TextInput {
                                    id: newPwInput
                                    width: parent.width - 34; height: parent.height
                                    color: "#e5e7eb"; font.pixelSize: 13
                                    echoMode: TextInput.Password
                                    clip: true; selectByMouse: true; verticalAlignment: TextInput.AlignVCenter
                                    Text { visible: !parent.text; text: "Min. 8 characters"; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
                                }
                            }
                        }

                        // Strength bar
                        Row {
                            spacing: 6
                            visible: newPwInput.text.length > 0

                            Repeater {
                                model: 4
                                delegate: Rectangle {
                                    width: 52; height: 4; radius: 2
                                    property int s: profileView.passwordStrength(newPwInput.text)
                                    color: index < s ? (s <= 1 ? "#ef4444" : s === 2 ? "#f59e0b" : s === 3 ? "#3b82f6" : "#10b981") : "#2d3748"
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                leftPadding: 6
                                property int s: profileView.passwordStrength(newPwInput.text)
                                text:  s <= 1 ? "Weak" : s === 2 ? "Fair" : s === 3 ? "Good" : "Strong"
                                color: s <= 1 ? "#ef4444" : s === 2 ? "#f59e0b" : s === 3 ? "#3b82f6" : "#10b981"
                                font.pixelSize: 11
                            }
                        }
                    }

                    // ── Confirm Password ───────────────────────────────────
                    Column { width: parent.width; spacing: 8
                        Text { text: "Confirm New Password"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true }
                        Rectangle {
                            width: parent.width; height: 44; radius: 8
                            color: "#0f1117"
                            border.color: confirmPwInput.activeFocus
                                ? (confirmPwInput.text.length > 0 && confirmPwInput.text !== newPwInput.text ? "#ef4444" : "#3b82f6")
                                : "#2d3748"
                            border.width: 1
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                            Row {
                                anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 10
                                Text { text: "🔒"; font.pixelSize: 14; opacity: 0.6; anchors.verticalCenter: parent.verticalCenter }
                                TextInput {
                                    id: confirmPwInput
                                    width: parent.width - 60; height: parent.height
                                    color: "#e5e7eb"; font.pixelSize: 13
                                    echoMode: TextInput.Password
                                    clip: true; selectByMouse: true; verticalAlignment: TextInput.AlignVCenter
                                    Text { visible: !parent.text; text: "Re-enter new password"; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
                                }
                                Text {
                                    visible: confirmPwInput.text.length > 0
                                    text: confirmPwInput.text === newPwInput.text ? "✓" : "✕"
                                    color: confirmPwInput.text === newPwInput.text ? "#10b981" : "#ef4444"
                                    font.pixelSize: 18; font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }

                    // Password feedback banner
                    Rectangle {
                        width: parent.width; height: 36; radius: 8
                        visible: profileView.passwordMsg !== ""
                        color: profileView.passwordSuccess ? "#052e16" : "#3b0f0f"
                        border.color: profileView.passwordSuccess ? "#10b981" : "#ef4444"; border.width: 1
                        Text { anchors.centerIn: parent; text: profileView.passwordMsg; color: profileView.passwordSuccess ? "#10b981" : "#ef4444"; font.pixelSize: 12; font.bold: true }
                    }

                    // Update Password
                    Rectangle {
                        width: 160; height: 42; radius: 8
                        color: updateMA.containsPress ? "#1d4ed8" : updateMA.containsMouse ? "#2563eb" : "#3b82f6"
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text { anchors.centerIn: parent; text: "Update Password"; color: "#ffffff"; font.pixelSize: 13; font.bold: true }
                        MouseArea { id: updateMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: profileView.changePassword() }
                    }
                }
            }

            Item { height: 16 }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // ── Draggable scrollbar  (identical to Reviews.qml pattern) ───────────
    // ══════════════════════════════════════════════════════════════════════
    Rectangle {
        id: scrollTrack
        anchors.right: parent.right; anchors.rightMargin: 6
        anchors.top: headerBar.bottom; anchors.topMargin: 8
        anchors.bottom: parent.bottom; anchors.bottomMargin: 8
        width: 6; radius: 3
        color: "#1e2535"
        visible: mainFlick.contentHeight > mainFlick.height

        Rectangle {
            id: scrollThumb
            width: parent.width; radius: 3
            color: thumbMA.pressed ? "#9ca3af" : thumbMA.containsMouse ? "#6b7280" : "#374151"
            Behavior on color { ColorAnimation { duration: 100 } }

            height: Math.max(40, scrollTrack.height * (mainFlick.height / mainFlick.contentHeight))
            y: mainFlick.contentY / mainFlick.contentHeight * scrollTrack.height

            MouseArea {
                id: thumbMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.SizeVerCursor
                preventStealing: true

                property real pressY: 0
                property real pressContentY: 0

                onPressed:  { pressY = mouseY; pressContentY = mainFlick.contentY }
                onPositionChanged: {
                    if (pressed) {
                        var delta = mouseY - pressY
                        var newY  = pressContentY + (delta / scrollTrack.height) * mainFlick.contentHeight
                        mainFlick.contentY = Math.max(0, Math.min(newY, mainFlick.contentHeight - mainFlick.height))
                    }
                }
            }
        }

        // Click track to jump
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var ratio = mouseY / scrollTrack.height
                mainFlick.contentY = Math.max(0, Math.min(
                    ratio * mainFlick.contentHeight,
                    mainFlick.contentHeight - mainFlick.height
                ))
            }
        }
    }
}
