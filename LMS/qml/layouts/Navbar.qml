import QtQuick
import QtQuick.Layouts

Rectangle {
    id: navbar
    width: parent ? parent.width : 824
    height: 56
    color: "#ffffff"   // ✅ fixed

    signal searchTextChanged(string text)
    signal notificationsClicked()
    signal profileClicked()

    property string userName: "Admin User"
    property string userRole: "Librarian"
    property int notificationCount: 3

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12

        // ── Search bar ──
        Rectangle {
            Layout.fillWidth: true
            height: 36
            radius: 8
            color: "#f3f4f6"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text { text: "🔍" }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    color: "#111827"

                    onTextChanged: navbar.searchTextChanged(text)

                    Text {
                        visible: !parent.text
                        text: "Search books..."
                        color: "#9ca3af"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // ── Notification Bell ──
        Rectangle {
            width: 36
            height: 36
            radius: 8
            color: bellMA.containsMouse ? "#f3f4f6" : "transparent"

            Text {
                anchors.centerIn: parent
                text: "🔔"
                font.pixelSize: 16
            }

            // Badge
            Rectangle {
                visible: navbar.notificationCount > 0
                width: 16; height: 16
                radius: 8
                color: "#ef4444"
                anchors.top: parent.top
                anchors.right: parent.right

                Text {
                    anchors.centerIn: parent
                    text: navbar.notificationCount
                    color: "white"
                    font.pixelSize: 9
                }
            }

            MouseArea {
                id: bellMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: navbar.notificationsClicked()
            }
        }

        // ── Divider ──
        Rectangle {
            width: 1
            height: 28
            color: "#e5e7eb"
        }

        // ── Profile ──
        RowLayout {
            spacing: 10

            Rectangle {
                width: 34; height: 34
                radius: 17
                color: "#3b82f6"

                Text {
                    anchors.centerIn: parent
                    text: navbar.userName.charAt(0).toUpperCase()
                    color: "white"
                }
            }

            ColumnLayout {
                spacing: 1

                Text {
                    text: navbar.userName
                    color: "#111827"
                    font.bold: true
                }

                Text {
                    text: navbar.userRole
                    color: "#6b7280"
                    font.pixelSize: 11
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: navbar.profileClicked()
            }
        }
    }
}
