import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

// LoginPage.qml — Full 1024x800 screen
Rectangle {
    id: loginPage
    width: 1024
    height: 800
    color: "#0b1016" // Matched dark background

    signal loginRequested(string email, string password)
    signal signupRequested()

    // ── Validation / feedback ──────────────────────────────────────────────
    property string errorMsg: ""
    signal islibrarian(bool a)

    function attemptLogin() {
        var email = emailInput.text.trim()
        var pass  = passwordInput.text

        // if (email === "") { errorMsg = "Please enter your email or User ID."; return }
        if (email ) { loginPage.islibrarian(false); return }
        if (pass  === "") { errorMsg = "Please enter your password.";          return }
        if (email === "admin@lib.com") { loginPage.islibrarian(true); return }
        errorMsg = ""
        loginPage.loginRequested(email, pass)
    }

    // ── Centered form column ───────────────────────────────────────────────
    Column {
        anchors.centerIn: parent
        width: 340 // Adjusted width to match the image proportions
        spacing: 0

        // Book icon badge
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 56; height: 56; radius: 14
            color: "#0078d4" // Windows blue to match image

            // Minimalist book representation
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
            text: "Library Management System"
            color: "#ffffff"
            font.pixelSize: 22
            font.bold: true
        }

        Item { width: 1; height: 8 }

        // Subtitle
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Sign in to your account"
            color: "#9ca3af"
            font.pixelSize: 14
        }

        Item { width: 1; height: 32 }

        // ── Email label ────────────────────────────────────────────────────
        Text {
            text: "Email / User ID"
            color: "#e5e7eb"
            font.pixelSize: 12
            font.bold: true
            leftPadding: 2
        }

        Item { width: 1; height: 8 }

        // ── Email field ────────────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: 44; radius: 6
            color: "#161b22" // Darker input field color
            border.color: emailInput.activeFocus ? "#0078d4" : "transparent"
            border.width: emailInput.activeFocus ? 2 : 0
            Behavior on border.color { ColorAnimation { duration: 150 } }

            TextInput {
                id: emailInput
                anchors.fill: parent
                anchors.leftMargin: 12; anchors.rightMargin: 12
                color: "#ffffff"
                font.pixelSize: 14
                clip: true
                selectByMouse: true
                verticalAlignment: TextInput.AlignVCenter
                KeyNavigation.tab: passwordInput
                Keys.onReturnPressed: passwordInput.forceActiveFocus()

                Text {
                    visible: !parent.text
                    text: "Enter your email"
                    color: "#6b7280"
                    font: parent.font
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Item { width: 1; height: 16 }

        // ── Password label ─────────────────────────────────────────────────
        Text {
            text: "Password"
            color: "#e5e7eb"
            font.pixelSize: 12
            font.bold: true
            leftPadding: 2
        }

        Item { width: 1; height: 8 }

        // ── Password field ─────────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: 44; radius: 6
            color: "#161b22"
            border.color: passwordInput.activeFocus ? "#0078d4" : "transparent"
            border.width: passwordInput.activeFocus ? 2 : 0
            Behavior on border.color { ColorAnimation { duration: 150 } }

            TextInput {
                id: passwordInput
                anchors.fill: parent
                anchors.leftMargin: 12; anchors.rightMargin: 12
                color: "#ffffff"
                font.pixelSize: 14
                echoMode: TextInput.Password
                clip: true
                selectByMouse: true
                verticalAlignment: TextInput.AlignVCenter
                Keys.onReturnPressed: loginPage.attemptLogin()

                Text {
                    visible: !parent.text
                    text: "Enter your password"
                    color: "#6b7280"
                    font: parent.font
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Item { width: 1; height: 8 }

        // ── Error message ──────────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: 36; radius: 6
            visible: loginPage.errorMsg !== ""
            color: "#3b0f0f"
            border.color: "#ef4444"; border.width: 1
            Text { anchors.centerIn: parent; text: loginPage.errorMsg; color: "#ef4444"; font.pixelSize: 12; font.bold: true }
        }

        Item { width: 1; height: loginPage.errorMsg !== "" ? 8 : 16 }

        // ── Sign In button ─────────────────────────────────────────────────
        Rectangle {
            width: parent.width; height: 44; radius: 6
            color: signInMA.containsPress ? "#005a9e" : signInMA.containsMouse ? "#006cbd" : "#0078d4"
            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                anchors.centerIn: parent
                text: "Sign In"
                color: "#ffffff"
                font.pixelSize: 14
                font.bold: true
            }

            MouseArea {
                id: signInMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: loginPage.attemptLogin()
            }
        }

        Item { width: 1; height: 20 }

        // ── Sign up link ───────────────────────────────────────────────────
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Don't have an account? <font color='#0078d4'>Sign up</font>"
            color: "#9ca3af"
            font.pixelSize: 13
            textFormat: Text.RichText

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: loginPage.signupRequested()
            }
        }

        Item { width: 1; height: 32 }

        // ── Demo credentials ───────────────────────────────────────────────
        Rectangle {
            width: parent.width
            height: demoCol.implicitHeight + 24
            radius: 8
            color: "#161b22"

            Column {
                id: demoCol
                anchors { fill: parent; margins: 12 }
                spacing: 8

                Text { text: "Demo credentials:"; color: "#8b949e"; font.pixelSize: 11 }
                Text { text: "Librarian: admin@lib.com"; color: "#c9d1d9"; font.pixelSize: 12 }
                Text { text: "Student: any other email"; color: "#c9d1d9"; font.pixelSize: 12 }
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
            // onClicked: console.log("Help requested")
        }
    }
}
