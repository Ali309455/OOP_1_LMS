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
    property string userId: ""

    function refreshMembership() {
        var data = lms.getMembership()

        if (data.tier !== undefined) {
            isMembershipActive = true
            activeTier = data.tier.toUpperCase()
            borrowLimit = data.borrowLimit
            fineDiscount = data.fineDiscount

            // SILVER special validity
            if (activeTier === "SILVER")
                expiryDate = "Student Life"
            else
                expiryDate = data.expiry
        }
    }

    Component.onCompleted: {
        refreshMembership()
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentCol.implicitHeight + 40
        clip: true

        ColumnLayout {
            id: contentCol
            width: flick.width - 60
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 30
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
                            color: {
                                if (!isMembershipActive) return "#475569"
                                if (activeTier === "SILVER") return "#94a3b8"
                                if (activeTier === "GOLD") return "#f59e0b"
                                if (activeTier === "PLATINUM") return "#8b5cf6"
                                return "#475569"
                            }
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
                                color: {
                                    if (!isMembershipActive) return "white"
                                    if (activeTier === "SILVER") return "#cbd5e1"
                                    if (activeTier === "GOLD") return "#fbbf24"
                                    if (activeTier === "PLATINUM") return "#a78bfa"
                                    return "white"
                                }
                                font.pixelSize: 20; font.bold: true
                            }
                        }
                        Item { Layout.fillWidth: true }
                        Button {
                            text: isMembershipActive ? "Renew" : "Upgrade"

                            onClicked: {

                                if (!isMembershipActive)
                                    return

                                var fee = 0

                                if (activeTier === "GOLD")
                                    fee = 29
                                else if (activeTier === "PLATINUM")
                                    fee = 59

                                confirmDialog.actionType = "renew"
                                confirmDialog.selectedTier = activeTier

                                confirmDialog.dialogMessage =
                                        fee + "$ will be deducted from your wallet.\n\n" +
                                        "Are you sure to renew your " +
                                        activeTier +
                                        " membership with us?"

                                confirmDialog.open()
                            }
                            background: Rectangle { implicitWidth: 100; implicitHeight: 38; color: "#3b82f6"; radius: 8 }
                            contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
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
    Rectangle {
        id: scrollTrack
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.top: flick.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 8; anchors.bottomMargin: 8
        width: 6
        radius: 3
        color: "#1e2535"
        visible: flick.contentHeight > flick.height

        // Thumb
        Rectangle {
            id: scrollThumb
            width: parent.width
            radius: 3
            color: thumbMA.pressed ? "#9ca3af" : thumbMA.containsMouse ? "#6b7280" : "#374151"
            Behavior on color { ColorAnimation { duration: 100 } }

            // height and y are two-way bound to the Flickable
            height: Math.max(32, scrollTrack.height * (flick.height / flick.contentHeight))
            y: flick.contentY / flick.contentHeight * scrollTrack.height

            MouseArea {
                id: thumbMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.SizeVerCursor
                preventStealing: true

                property real pressY: 0
                property real pressContentY: 0

                onPressed: {
                    pressY = mouseY
                    pressContentY = flick.contentY
                }

                onPositionChanged: {
                    if (pressed) {
                        var delta = mouseY - pressY
                        var ratio = delta / scrollTrack.height
                        var newY = pressContentY + ratio * flick.contentHeight
                        flick.contentY = Math.max(0, Math.min(newY, flick.contentHeight - flick.height))
                    }
                }
            }
        }

        // Click on track (jump to position)
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var ratio = mouseY / scrollTrack.height
                flick.contentY = Math.max(0, Math.min(ratio * flick.contentHeight, flick.contentHeight - flick.height))
            }
        }
    }

    //confirmation Dialog
    Dialog {
        id: confirmDialog

        property string selectedTier: ""
        property string actionType: ""
        property string dialogMessage: ""

        modal: true
        anchors.centerIn: parent
        width: 420
        padding: 20

        background: Rectangle {
            color: "#1e293b"
            radius: 14
            border.color: "#334155"
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 20

            Text {
                text: "Confirmation!"
                color: "white"
                font.pixelSize: 22
                font.bold: true
            }

            Text {
                text: confirmDialog.dialogMessage
                color: "#cbd5e1"
                wrapMode: Text.WordWrap
                font.pixelSize: 14
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 12

                Button {
                    text: "Cancel"

                    onClicked: confirmDialog.close()

                    background: Rectangle {
                        color: "#475569"
                        radius: 8
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Button {
                    text: "Confirm"

                    onClicked: {

                        if (confirmDialog.actionType === "renew") {

                            lms.renewMembership(membershipRoot.userId)

                        } else {

                            lms.upgradeMembership(
                                        membershipRoot.userId,
                                        confirmDialog.selectedTier
                                        )
                        }

                        refreshMembership()

                        confirmDialog.close()
                        successDialog.open()
                    }

                    background: Rectangle {
                        color: "#3b82f6"
                        radius: 8
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }

    // Update dialog box
    Dialog {
        id: successDialog

        modal: true
        anchors.centerIn: parent
        width: 360
        padding: 20

        background: Rectangle {
            color: "#1e293b"
            radius: 14
            border.color: "#334155"
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 18

            Text {
                text: "Updated!"
                color: "white"
                font.pixelSize: 22
                font.bold: true
            }

            Text {
                text: "Your membership has been updated successfully!"
                color: "#cbd5e1"
                wrapMode: Text.WordWrap
            }

            Button {
                Layout.alignment: Qt.AlignRight
                text: "OK"

                onClicked: successDialog.close()

                background: Rectangle {
                    color: "#10b981"
                    radius: 8
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }
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
                Layout.fillWidth: true; text: {
                    if (!membershipRoot.isMembershipActive) return "Select Plan"
                    if (membershipRoot.activeTier === tier) return "Current Plan"

                    if (tier === "SILVER" && membershipRoot.activeTier !== "SILVER") return "Downgrade"
                    if (tier === "PLATINUM" && membershipRoot.activeTier !== "PLATINUM") return "Upgrade"
                    if (tier === "GOLD") {
                        if (membershipRoot.activeTier === "PLATINUM") return "Downgrade"
                        if (membershipRoot.activeTier === "SILVER") return "Upgrade"
                    }
                }
                onClicked: {

                    if (tier === membershipRoot.activeTier)
                        return

                    var fee = 0

                    if (tier === "GOLD")
                        fee = 29
                    else if (tier === "PLATINUM")
                        fee = 59

                    var actionWord = "upgrade"

                    if (
                            (membershipRoot.activeTier === "PLATINUM" && tier === "GOLD") ||
                            (membershipRoot.activeTier !== "SILVER" && tier === "SILVER")
                            )
                    {
                        actionWord = "downgrade"
                    }

                    confirmDialog.actionType = "upgrade"
                    confirmDialog.selectedTier = tier

                    confirmDialog.dialogMessage =
                            fee + "$ will be deducted from your wallet.\n\n" +
                            "Are you sure to " +
                            actionWord +
                            " your membership to " +
                            tier +
                            " tier?"

                    confirmDialog.open()
                }
                background: Rectangle { implicitHeight: 40; color: "#3b82f6"; radius: 8 }
                contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight}
            }
        }
    }
}
