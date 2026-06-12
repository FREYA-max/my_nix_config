import QtQuick
import QtQuick.Layouts
import Quickshell
import "../" 

Rectangle {
    id: sidePanelRoot
    anchors.fill: parent
    
    MatugenColors { id: mocha }
    
    // Exact opacity match for the opened TopBar state
    color: Qt.rgba(mocha.base.r, mocha.base.g, mocha.base.b, 0.95) 
    radius: 14 
    
    border.width: 1
    border.color: Qt.rgba(mocha.text.r, mocha.text.g, mocha.text.b, 0.08)

    // Square top corners to connect seamlessly with the morphing TopBar pill
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 1
        anchors.right: parent.right
        anchors.rightMargin: 1
        height: 14
        color: parent.color
    }

    // Omit the top border line entirely to melt into the TopBar
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 1
        anchors.right: parent.right
        anchors.rightMargin: 1
        height: 1
        color: parent.color 
    }

    // Content area
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        
        Text {
            Layout.topMargin: 10
            text: "System Controls"
            color: mocha.text
            font.pixelSize: 18
            font.bold: true
            font.family: "JetBrains Mono"
            Layout.alignment: Qt.AlignHCenter
        }
        
        Item { Layout.fillHeight: true } 
    }
}
