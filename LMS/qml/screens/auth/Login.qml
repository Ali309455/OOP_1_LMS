import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    Rectangle {
        anchors.fill: parent
        color: "#f5f6fa"

        Column {
            anchors.centerIn: parent
            spacing: 10

            Text { text: "LOGIN"; font.pixelSize: 24 }

            TextField { placeholderText: "Email" }
            TextField { placeholderText: "Password"; echoMode: TextInput.Password }

            Button { text: "Login" }
        }
    }
}
