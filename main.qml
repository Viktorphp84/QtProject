import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

ApplicationWindow {
    id: root
    width: 640
    height: 480
    visible: true
    title: qsTr("Секционирующие пункты")

    property string number: modalTextInput.displayText
    property int numInt: parseInt(number)
    property alias visibleDialogOver_240: dialogSectionOver_240.visible
    property var componentTransformApp

    function onAcceptedDialog() {

        dynamicTabBar.addItem(componentTabButton.createObject(dynamicTabBar, {
                                                                  "text": "Параметры трансформатора"
                                                              }))
        componentTransformApp = componentTransform.createObject(stackTab)

        for (var i = 0; i < numInt; ++i) {
            var string = ' Линия ' + (i + 1) + ' '
            dynamicTabBar.addItem(componentTabButton.createObject(
                                      dynamicTabBar, {
                                          "text": string
                                      }))
            componentCards.createObject(stackTab)
        }

        modalDialog.accept()
    }

    //Сообщение о том, что сечение провода больше 240 мм.кв.
    /*******************************************************************************************************/
    Dialog {
        id: dialogSectionOver_240
        anchors.centerIn: parent
        modal: true
        contentItem: Text {
            text: qsTr("Сечение провода превышает 240 мм<sup>2</sup>!")
            textFormat: Text.RichText
        }
        width: 220
        height: 80

        closePolicy: Popup.CloseOnEscape
        palette.button: "#26972D"
        palette.window: "#67E46F"

        DialogButtonBox {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 40
            Layout.alignment: Qt.AlignHCenter
            standardButtons: DialogButtonBox.Ok
            onAccepted: {
                dialogSectionOver_240.visible = false
            }
        }
    }

    /*******************************************************************************************************/
    Rectangle {
        id: backgroundRectangle
        width: root.width - 10
        height: root.height - dynamicTabBar.height - 10
        anchors.centerIn: parent
        anchors.verticalCenterOffset: dynamicTabBar.height / 2
        color: "#67E667"
        radius: 5
        clip: true

        ScrollView {
            id: scrollView
            width: parent.width
            height: parent.height
            anchors.centerIn: parent
            clip: true
            contentHeight: 400
            contentWidth: 300
        }

        StackLayout {
            id: stackTab
            anchors.top: parent.top
            anchors.left: parent.left
            currentIndex: dynamicTabBar.currentIndex
        }
    }

    TabBar {
        id: dynamicTabBar
        width: parent.width
    }

    Component {
        id: componentTabButton
        TabButton {
            font.pointSize: 12
            width: implicitWidth
        }
    }

    Component {
        id: componentTransform
        Transform {
            id: transData
        }
    }

    Component {
        id: componentCards

        Item {

            InputData {
                id: inpData
                x: 0
                y: 0
            }

            ChartCard {
                id: chartComp
                x: 0
                y: inpData.height
            }

            OutputData {
                id: outData
                x: backgroundRectangle.width - inpData.width
                y: 0
            }

            CanvasCard {
                id: canvCard
                x: backgroundRectangle.width - inpData.width
                y: inpData.height
            }
        }
    }

    Dialog {
        id: modalDialog
        modal: true
        visible: true
        anchors.centerIn: parent
        closePolicy: Popup.CloseOnEscape
        palette.button: "#26972D"
        palette.window: "#67E46F"
        width: textDialog.width + 10
        height: textDialog.height * 6

        Overlay.modal: Rectangle {
            Rectangle {
                anchors.fill: parent
                color: "gray"
                opacity: 0.5
            }
        }

        ColumnLayout {
            spacing: 15
            anchors.centerIn: parent

            Text {
                id: textDialog
                text: "Введите количество линий"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
            }

            TextField {
                id: modalTextInput
                placeholderText: "0"
                Layout.alignment: Qt.AlignHCenter
                maximumLength: 2

                Keys.onReturnPressed: onAcceptedDialog()
                Keys.onEnterPressed: onAcceptedDialog()
            }

            DialogButtonBox {
                id: dialogButton
                Layout.alignment: Qt.AlignHCenter
                standardButtons: DialogButtonBox.Ok

                onAccepted: {
                    onAcceptedDialog()
                }
            }
        }
    }
}
