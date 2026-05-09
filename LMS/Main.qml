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
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowMinimizeButtonHint

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
        property string currentRoute: "dashboard" // default screen
        property string authPage: "login"   // "login" or "signup"
        property bool islibrarian:true
        property bool isLoggedIn: false
        property var currentUser;
        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Custom Title Bar ──
            Rectangle {
                id: titleBar
                Layout.fillWidth: true
                height: 40
                color: "transparent"


                // Drag window
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton

                    // ❗ prevent stealing clicks from buttons
                    propagateComposedEvents: true

                    onPressed: {
                            root.startSystemMove()
                    }
                }

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
                    Rectangle {
                        width: 30
                        height: 30
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "—"
                            color: "white"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.showMinimized()
                        }
                    }

                    // Close Button
                    Rectangle {
                        width: 30
                        height: 30
                        color:"transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: "white"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Qt.quit()
                        }
                    }
                }

            } // login pages
            Login{
                Layout.fillHeight: true
                Layout.fillWidth: true
                visible: !container.isLoggedIn && container.authPage === "login"
                onIslibrarian:  function(access) {
                        container.islibrarian = access
                        console.log(access)
                        container.isLoggedIn = true
                         }
                onSignupRequested: {
                       container.authPage = "signup"
                   }
                onUserLoggedIn: function(userdetails){
                    container.currentUser = userdetails;
                    console.log(container.currentUser.name);
                }
            }
            // ── Content Area Main section ──
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: container.isLoggedIn
                Sidebar {
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 710
                    islibrarian: container.islibrarian
                    onNavigationRequested: function(page) {
                           container.currentRoute = page
                            if(page === "logout") container.isLoggedIn = false;
                       }
                }
                Centralbox{
                    Layout.fillHeight:true
                    anchors.leftMargin: 230
                    Layout.margins: 10
                    Layout.fillWidth: true
                    islibrarian: container.islibrarian
                    currentUser: container.currentUser
                    route: container.currentRoute
                    onRouteChangeRequested: function(newRoute) {
                                            container.currentRoute = newRoute
                                        }

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

