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
        border.color: "#334155"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Custom Title Bar ──
            Rectangle {
                id: titleBar
                Layout.fillWidth: true
                height: 40
                color: "#0f172a"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing : 10

                    Text {
                        text: "LIBRARY PORTAL"
                        font.bold: true
                        color: "white"
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    // Minimize Button
                    Text {
                        text: "—"
                        color: "white"
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
                        color: "white"
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
                spacing: 0

                Sidebar {
                    Layout.preferredWidth: 200
                    Layout.fillHeight: true
                }
                Centralbox{
                    Layout.fillHeight:true
                    Layout.fillWidth: true
                }
            }
        }
    }

    MouseArea {
        width: 20
        height: 20
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        cursorShape: Qt.SizeFDiagCursor
        onPressed: root.startSystemResize(Qt.RightEdge | Qt.BottomEdge)
    }
}
