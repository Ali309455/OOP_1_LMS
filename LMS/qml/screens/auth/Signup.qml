import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// SignupPage.qml — Full 1024x800 screen
Rectangle {
    id: signupPage
    width: 1024
    height: 800
    color: "#0b1016" // Matched dark background

    signal signupCompleted(string name, string email, string role)
    signal backToLogin()

    // ── Form state ─────────────────────────────────────────────────────────
    property string selectedRole: "Student"
    property string errorMsg:  ""
    property string successMsg: ""

    function isValidEmail(e) { return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e) }

    function attemptSignup() {
        var name    = nameInput.text.trim()
        var email   = emailInput.text.trim()
        var pass    = passInput.text
        var confirm = confirmInput.text

        if (name === "")         { errorMsg = "Full name is required.";                  return }
        if (!isValidEmail(email)){ errorMsg = "Please enter a valid email address.";     return }
        if (pass.length < 8)     { errorMsg = "Password must be at least 8 characters."; return }
        if (pass !== confirm)    { errorMsg = "Passwords do not match.";                 return }

        errorMsg  = ""
        successMsg = "Account created! Redirecting to login..."
        successTimer.start()
        signupPage.signupCompleted(name, email, selectedRole)
    }

    Timer {
        id: successTimer
        interval: 1800
        onTriggered: {
            successMsg = ""
            signupPage.backToLogin()
        }
    }

    // ── Centered form column ───────────────────────────────────────────
    Column {
        id: formCol
        anchors.centerIn: parent
        width: 340 // Adjusted width to match the login page
        spacing: 0

        // Book icon badge
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 56; height: 56; radius: 14
            color: "#0078d4" // Match Windows blue accent
            Text {
                anchors.centerIn: parent
                text: "📖"
                color: "white"
                font.pixelSize: 28
            }
        }

        Item { width: 1; height: 20 }

        // Title
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Create Account"
            color: "#ffffff"
            font.pixelSize: 22
            font.bold: true
        }

        Item { width: 1; height: 8 }

        // Subtitle
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Join the Library Management System"
            color: "#9ca3af"
            font.pixelSize: 14
        }

        Item { width: 1; height: 32 }

        // ── Full Name ──────────────────────────────────────────────────
        Text { text: "Full Name"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true; leftPadding: 2 }
        Item { width: 1; height: 8 }
        Rectangle {
            width: parent.width; height: 44; radius: 6; color: "#161b22"
            border.color: nameInput.activeFocus ? "#0078d4" : "transparent"; border.width: nameInput.activeFocus ? 2 : 0
            Behavior on border.color { ColorAnimation { duration: 150 } }

            TextInput {
                id: nameInput
                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                color: "#ffffff"; font.pixelSize: 14; clip: true; selectByMouse: true
                verticalAlignment: TextInput.AlignVCenter
                Keys.onReturnPressed: emailInput.forceActiveFocus()
                Text { visible: !parent.text; text: "Enter your full name"; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        Item { width: 1; height: 16 }

        // ── Email ──────────────────────────────────────────────────────
        Text { text: "Email"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true; leftPadding: 2 }
        Item { width: 1; height: 8 }
        Rectangle {
            width: parent.width; height: 44; radius: 6; color: "#161b22"
            border.color: emailInput.activeFocus ? "#0078d4" : "transparent"; border.width: emailInput.activeFocus ? 2 : 0
            Behavior on border.color { ColorAnimation { duration: 150 } }

            TextInput {
                id: emailInput
                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                color: "#ffffff"; font.pixelSize: 14; clip: true; selectByMouse: true
                verticalAlignment: TextInput.AlignVCenter
                inputMethodHints: Qt.ImhEmailCharactersOnly
                Keys.onReturnPressed: passInput.forceActiveFocus()
                Text { visible: !parent.text; text: "Enter your email"; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        Item { width: 1; height: 16 }

        // ── Role selector ──────────────────────────────────────────────
        Text { text: "Role"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true; leftPadding: 2 }
        Item { width: 1; height: 8 }
        Row {
            width: parent.width; spacing: 8

            Repeater {
                model: ["Student", "Librarian"]
                delegate: Rectangle {
                    width: (parent.width - 8) / 2; height: 44; radius: 6
                    color: signupPage.selectedRole === modelData ? "#0078d4" : "#161b22"

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: signupPage.selectedRole === modelData ? "#ffffff" : "#9ca3af"
                        font.pixelSize: 13; font.bold: signupPage.selectedRole === modelData
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: signupPage.selectedRole = modelData
                    }
                }
            }
        }

        Item { width: 1; height: 16 }

        // ── Password ───────────────────────────────────────────────────
        Text { text: "Password"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true; leftPadding: 2 }
        Item { width: 1; height: 8 }
        Rectangle {
            width: parent.width; height: 44; radius: 6; color: "#161b22"
            border.color: passInput.activeFocus ? "#0078d4" : "transparent"; border.width: passInput.activeFocus ? 2 : 0
            Behavior on border.color { ColorAnimation { duration: 150 } }

            TextInput {
                id: passInput
                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                color: "#ffffff"; font.pixelSize: 14; echoMode: TextInput.Password
                clip: true; selectByMouse: true; verticalAlignment: TextInput.AlignVCenter
                Keys.onReturnPressed: confirmInput.forceActiveFocus()
                Text { visible: !parent.text; text: "Min. 8 characters"; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        Item { width: 1; height: 8 }

        // Password strength bar
        Row {
            width: parent.width; spacing: 4; visible: passInput.text.length > 0
            property int s: {
                var p = passInput.text, n = 0
                if (p.length >= 8) n++
                if (/[A-Z]/.test(p)) n++
                if (/[0-9]/.test(p)) n++
                if (/[^A-Za-z0-9]/.test(p)) n++
                return n
            }
            Repeater {
                model: 4
                delegate: Rectangle {
                    width: (parent.width - 12) / 4; height: 4; radius: 2
                    property int s: parent.s
                    color: index < s ? (s <= 1 ? "#ef4444" : s === 2 ? "#f59e0b" : s === 3 ? "#0078d4" : "#10b981") : "#30363d"
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
            }
        }

        Item { width: 1; height: 16 }

        // ── Confirm Password ───────────────────────────────────────────
        Text { text: "Confirm Password"; color: "#e5e7eb"; font.pixelSize: 12; font.bold: true; leftPadding: 2 }
        Item { width: 1; height: 8 }
        Rectangle {
            width: parent.width; height: 44; radius: 6; color: "#161b22"
            border.color: confirmInput.activeFocus
                ? (confirmInput.text.length > 0 && confirmInput.text !== passInput.text ? "#ef4444" : "#0078d4")
                : "transparent"
            border.width: confirmInput.activeFocus ? 2 : 0
            Behavior on border.color { ColorAnimation { duration: 150 } }

            TextInput {
                id: confirmInput
                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                color: "#ffffff"; font.pixelSize: 14; echoMode: TextInput.Password
                clip: true; selectByMouse: true; verticalAlignment: TextInput.AlignVCenter
                Keys.onReturnPressed: signupPage.attemptSignup()
                Text { visible: !parent.text; text: "Re-enter password"; color: "#6b7280"; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        Item { width: 1; height: 16 }

        // ── Error / Success banner ─────────────────────────────────────
        Rectangle {
            width: parent.width; height: 36; radius: 6
            visible: signupPage.errorMsg !== "" || signupPage.successMsg !== ""
            color: signupPage.successMsg !== "" ? "#052e16" : "#3b0f0f"
            border.color: signupPage.successMsg !== "" ? "#10b981" : "#ef4444"; border.width: 1
            Text {
                anchors.centerIn: parent
                text: signupPage.successMsg !== "" ? signupPage.successMsg : signupPage.errorMsg
                color: signupPage.successMsg !== "" ? "#10b981" : "#ef4444"
                font.pixelSize: 12; font.bold: true
            }
        }

        Item { width: 1; height: signupPage.errorMsg !== "" || signupPage.successMsg !== "" ? 12 : 0 }

        // ── Create Account button ──────────────────────────────────────
        Rectangle {
            width: parent.width; height: 44; radius: 6
            color: createMA.containsPress ? "#005a9e" : createMA.containsMouse ? "#006cbd" : "#0078d4"
            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                anchors.centerIn: parent
                text: "Create Account"
                color: "#ffffff"
                font.pixelSize: 14
                font.bold: true
            }

            MouseArea {
                id: createMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: signupPage.attemptSignup()
            }
        }

        Item { width: 1; height: 24 }

        // ── Back to login link ─────────────────────────────────────────
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Already have an account? <font color='#0078d4'>Sign in</font>"
            color: "#9ca3af"
            font.pixelSize: 13
            textFormat: Text.RichText

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: signupPage.backToLogin()
            }
        }
    }

    // ── Floating Help Button (Bottom Right) ───────────────────────────────
    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        width: 32; height: 32; radius: 16
        color: "#161b22"
        border.color: "#30363d"
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: "?"
            color: "#8b949e"
            font.pixelSize: 14
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
        }
    }
}
