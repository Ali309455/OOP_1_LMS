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
        radius: 23
        color: "#0f1117"
        clip: true

        // optional shadow effect
        border.color: "#696969"
        property string currentRoute: "dashboard"   // default screen

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Custom Title Bar ──
            Rectangle {
                id: titleBar
                Layout.fillWidth: true
                height: 40
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing : 10

                    Text {
                        text: "Library System"
                        color: "#ffffff"
                        font.bold: true
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true }

                    // Minimize Button
                    Text {
                        text: "—"
                        color: "#ffffff"
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
                        color: "#ffffff"
                        font.pixelSize: 20
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

                    onPressed: root.startSystemMove()
                }
            }



            // ── Content Area ──
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Sidebar {
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 710
                    onNavigationRequested: function(page) {
                           container.currentRoute = page
                       }
                }
                Centralbox{
                    Layout.fillHeight:true
                    anchors.leftMargin: 230
                    Layout.margins: 10
                    Layout.fillWidth: true
                    route: container.currentRoute
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
