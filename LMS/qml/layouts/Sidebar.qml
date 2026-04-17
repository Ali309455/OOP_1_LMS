import QtQuick
import QtQuick.Layouts

Rectangle {
    id: sidebar
    width: 200
    height: 800
    color: "#ffffff"
    border.color: "#e5e7eb"
    border.width: 1

    signal navigationRequested(string page)
    property string activePage: "Dashboard"

    property var navItems: [
        { label: "Dashboard",    icon: "🏠" },
        { label: "Books",        icon: "📖" },
        { label: "Transactions", icon: "🧾" },
        { label: "Reviews",      icon: "💬" },
        { label: "Reports",      icon: "📊" },
        { label: "Users",        icon: "👥" },
        { label: "Settings",     icon: "⚙️"  }
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Header ──
        Rectangle {
            Layout.fillWidth: true
            height: 56
            color: "#ffffff"

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#e5e7eb"
            }

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 16
                spacing: 8

                Rectangle {
                    width: 28; height: 28
                    radius: 6
                    color: "#2563eb"

                    Text {
                        anchors.centerIn: parent
                        text: "📖"
                    }
                }

                Text {
                    text: "Library System"
                    font.bold: true
                }
            }
                Rectangle {
                    anchors.top : parent.top
                    anchors.right: parent.right
                    height: parent.height
                    width:  1
                    color: "#e5e7eb"
                }
        }

        // ── Nav Items ──
        Repeater {
            model: sidebar.navItems

            delegate: Rectangle {
                Layout.fillWidth: true
                height: 44
                radius: 8

                Layout.leftMargin: 8
                Layout.rightMargin: 8
                Layout.topMargin: index === 0 ? 8 : 2

                // ✅ FIXED COLOR LOGIC
                color: sidebar.activePage === modelData.label
                       ? "#3B82F6"
                       : (mouseArea.containsMouse ? "#DBEAFE" : "transparent")

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                RowLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    spacing: 10

                    Text {
                        text: modelData.icon
                        opacity: sidebar.activePage === modelData.label ? 1 : 0.7
                    }

                    Text {
                        text: modelData.label
                        color: sidebar.activePage === modelData.label ? "#ffffff" : "#374151"
                        font.bold: sidebar.activePage === modelData.label
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        sidebar.activePage = modelData.label
                        sidebar.navigationRequested(modelData.label)
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#e5e7eb"
        }

        // ── Logout ──
        Rectangle {
            Layout.fillWidth: true
            height: 52

            color: mouseAreaLogout.containsMouse ? "#fef2f2" : "transparent"

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20
                spacing: 10

                Text { text: "↪" }
                Text { text: "Logout" }
            }

            MouseArea {
                id: mouseAreaLogout
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: sidebar.navigationRequested("logout")
            }
        }
    }
}
