import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: membershipRoot
    anchors.fill: parent
    color: "#0f172a"

    // --- DYNAMIC DATA PROPERTIES ---
    property bool isMembershipActive: false
    property string activeTier: ""
    property string borrowLimit: "—"
    property string fineDiscount: "—"
    property string expiryDate: "—"

    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        clip: true

        ColumnLayout {
            width: parent.width - 60
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 20
            spacing: 25

            // --- HEADER ---
            ColumnLayout {
                spacing: 2
                Text { text: "Membership"; color: "white"; font.pixelSize: 28; font.bold: true }
                Text { text: "Manage your Library Membership"; color: "#94a3b8"; font.pixelSize: 14 }
            }

            // --- CURRENT STATUS CARD ---
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                color: "#1e293b"
                radius: 15
                border.color: "#334155"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    RowLayout {
                        Layout.fillWidth: true

                        // --- MAIN ICON ---
                        Rectangle {
                            width: 44; height: 44; radius: 8
                            color: isMembershipActive ? "#8b5cf6" : "#475569"
                            border.color: Qt.rgba(color.r, color.g, color.b, 0.4)
                            border.width: 1
                            Image {
                                anchors.centerIn: parent
                                width: 24; height: 24
                                source: "qrc:/assets/icons/shield-user-fill.svg"
                                fillMode: Image.PreserveAspectFit
                            }
                            // ColorOverlay {
                            //     anchors.fill: mainIconRaw
                            //     source: mainIconRaw
                            //     color: "#fbbf24"
                            // }
                        }

                        ColumnLayout {
                            Layout.leftMargin: 8
                            Text { text: "CURRENT"; color: "#64748b"; font.pixelSize: 10; font.bold: true; font.letterSpacing: 0.5 }
                            Text {
                                text: isMembershipActive ? activeTier : "No Active Membership"
                                color: isMembershipActive ? "#fbbf24" : "white"
                                font.pixelSize: 20; font.bold: true
                            }
                        }
                        Item { Layout.fillWidth: true }
                        Button {
                            text: "Upgrade"
                            background: Rectangle { implicitWidth: 100; implicitHeight: 38; color: "#3b82f6"; radius: 8 }
                            contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                        }
                    }

                    // Stat Boxes Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        StatTile { iconImg: "book-fill.svg"; label: "BORROW LIMIT"; value: borrowLimit; iconCol: "#3b82f6" }
                        StatTile { iconImg: "discount-percent-fill.svg"; label: "FINE DISCOUNT"; value: fineDiscount; iconCol: "#06b6d4" }
                        StatTile { iconImg: "calendar-event-fill.svg"; label: "VALIDITY"; value: expiryDate; iconCol: "#f97316" }
                    }
                }
            }

            Text { text: "Available Plans"; color: "white"; font.pixelSize: 20; font.bold: true }

            // --- PLANS GRID ---
            Flow {
                Layout.fillWidth: true
                spacing: 15

                PlanCard { tier: "SILVER"; price: "Free"; iconBg: "#64748b"; planIcon: "vip-crown-2-fill.svg"; features: ["Borrow up to 3 Books", "Standard loan period (14 Days)", "No Fine Discount"] }
                PlanCard { tier: "GOLD"; price: "$29/yr"; iconBg: "#f59e0b"; planIcon: "vip-crown-fill.svg"; features: ["Borrow up to 5 Books", "Extended loan period (21 Days)", "20% Fine Discount"] }
                PlanCard { tier: "PLATINUM"; price: "$59/yr"; iconBg: "#8b5cf6"; planIcon: "vip-diamond-fill.svg"; features: ["Borrow up to 7 Books", "Maximum loan period (30 Days)", "50% Fine Discount", "Priority reservations"] }
            }
        }
    }

    // --- REUSABLE COMPONENTS ---

    component StatTile : Rectangle {
        property string iconImg: ""; property string label: ""; property string value: ""; property color iconCol: "white"
        Layout.fillWidth: true; height: 60; color: "#0f172a"; radius: 10; border.color: "#334155"
        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 12; spacing: 10

            // --- STAT ICON ---
            Rectangle {
                width: 32; height: 32; color: iconCol; radius: 8; opacity: 1.0
                Image {
                    anchors.centerIn: parent
                    width: 18; height: 18
                    source: "qrc:/assets/icons/" + iconImg
                    fillMode: Image.PreserveAspectFit
                }
                // ColorOverlay {
                //     anchors.fill: tileIcon
                //     source: tileIcon
                //     color: iconCol
                // }
            }

            ColumnLayout {
                spacing: 0
                Text { text: label; color: "#64748b"; font.pixelSize: 9; font.bold: true }
                Text { text: value; color: "white"; font.pixelSize: 14; font.bold: true }
            }
            Item { Layout.fillWidth: true}
        }
    }

    component PlanCard : Rectangle {
        property string tier: ""; property string price: ""; property string planIcon: ""; property string iconBg: "white"; property var features: []
        width: (parent.width / 3) - 10; height: 380; color: "#1e293b"; radius: 16
        border.color: (isMembershipActive && activeTier === tier) ? "#3b82f6" : "#334155"
        border.width: (isMembershipActive && activeTier === tier) ? 2 : 1

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 20; spacing: 12
            Rectangle {
                Layout.alignment: Qt.AlignHCenter; width: 50; height: 50; radius: 12; color: iconBg

                // --- PLAN ICON ---
                Image {
                    anchors.centerIn: parent
                    width: 28; height: 28
                    source: "qrc:/assets/icons/" + planIcon
                    fillMode: Image.PreserveAspectFit
                }
                // ColorOverlay {
                //     anchors.fill: pIcon
                //     source: pIcon
                //     color: "white"
                // }
            }
            Text { Layout.alignment: Qt.AlignHCenter; text: tier; color: iconBg; font.pixelSize: 18; font.bold: true }
            Text { Layout.alignment: Qt.AlignHCenter; text: price; color: "white"; font.pixelSize: 28; font.bold: true }

            ColumnLayout {
                Layout.fillWidth: true; spacing: 8
                Repeater {
                    model: features
                    RowLayout {
                        Text { text: "✓"; color: "#10b981"; font.bold: true }
                        Text { text: modelData; color: "#cbd5e1"; font.pixelSize: 12 }
                    }
                }
            }
            Item { Layout.fillHeight: true }
            Button {
                Layout.fillWidth: true; text: "Select Plan"
                background: Rectangle { implicitHeight: 40; color: "#3b82f6"; radius: 8 }
                contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
            }
        }
    }
}