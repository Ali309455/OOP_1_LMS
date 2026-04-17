import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import LMS

Window {
    id: root
    width: 1024
    height: 800
    visible: true
    color: "transparent"   // important for rounded corners
    flags: Qt.FramelessWindowHint

    // ── Rounded Main Container ──
    Rectangle {
        id: container
        anchors.fill: parent
        anchors.margins: 10   // gives floating effect
        radius: 14
        color: "#0f172a"

        // optional shadow effect
        border.color: "#e5e7eb"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Custom Title Bar ──
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "white"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing : 10

                    Text {
                        text: "Library System"
                        font.bold: true
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    // Minimize Button
                    Text {
                        text: "—"

                        font.pixelSize: 13

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.showMinimized()
                        }
                    }

                    // Close Button
                    Text {
                        text: "✕"
                        font.pixelSize: 16
                        anchors.margins: 10


                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Qt.quit()
                        }
                    }
                }

                // Drag window
                MouseArea {
                    anchors.fill: parent
                    drag.target: root
                    onPressed: root.startSystemMove()
                }
            }

            // ── Content Area ──
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true


                Sidebar {
                    Layout.preferredWidth: 200
                    Layout.fillHeight: true
                }
                Centralbox{
                    Layout.fillHeight:true
                    anchors.leftMargin: 230
                    Layout.fillWidth: true
                }
            }
        }
    }
}
