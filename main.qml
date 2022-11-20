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
    property int numInt: parseInt(number) //количество вкладок
    property var componentTransformApp
    property var componentCardsApp: []
    property var arrFullPower: [] //массив для сохранения отдельных наибольших мощностей по участкам
    property var transformerRatings: [ //массив номинальных значений трансформаторов
        0.1,
        0.16,
        0.25,
        0.4,
        0.63,
        1,
        1.6,
        2.5,
        4,
        6.3,
        10,
        16,
        25,
        40,
        63,
        100,
        160,
        250,
        400,
        630,
        1000,
        1600,
        2500,
        4000,
        6300
    ]

    function onAcceptedDialog() {

        dynamicTabBar.addItem(componentTabButton.createObject(dynamicTabBar, {"text": "Параметры трансформатора"}))

        componentTransformApp = componentTransform.createObject(stackTab)

        for (var i = 0; i < numInt; ++i) {

            var string = ' Линия ' + (i + 1) + ' '
            dynamicTabBar.addItem(componentTabButton.createObject(dynamicTabBar, {"text": string}))

            let compCardsApp = componentCards.createObject(stackTab, {"componentNumber": i})

            componentCardsApp.push(compCardsApp)
            arrFullPower.push(0)
        }

        modalDialog.accept()
    }

    //Слот для вычисления требуемой полной мощности трансформатора
    function slotCalculateFullPowerOfTransformer(transPow, compNum) {
        root.arrFullPower[compNum] = transPow

        let flag = true
        for(let t = 0; t < numInt; ++t) {
            if(root.arrFullPower[t] === 0) {
                flag = false
            }
        }

        if(flag) {
            let sumFullPower = root.arrFullPower.reduce((sum, current) => sum + current, 0)

            for(let y = 0; y < root.transformerRatings.length - 1; ++y) {
                if(sumFullPower > root.transformerRatings[y] && sumFullPower < root.transformerRatings[y + 1]) {
                    root.componentTransformApp.textTransPower = root.transformerRatings[y + 1]
                } else if(sumFullPower < root.transformerRatings[0]) {
                    dialogWarningRoot.title = "Мощность ниже 0.1 кВА"
                    dialogWarningRoot.visible = true
                } else if (sumFullPower > root.transformerRatings[root.transformerRatings.length - 1]){
                    dialogWarningRoot.title = "Мощность выше 6300 кВА"
                    dialogWarningRoot.visible = true
                }
            }
        }
    }
    /*******************************************************************************************************/

    //Диалог с сообщениями пользователю
    /**********************************************************************************************************/
    Dialog {
        id: dialogWarningRoot
        modal: true
        closePolicy: Popup.CloseOnEscape
        palette.button: "#26972D"
        palette.window: "#67E46F"
        DialogButtonBox {
            anchors.centerIn: parent
            Layout.alignment: Qt.AlignHCenter
            standardButtons: DialogButtonBox.Ok
            onAccepted: {
                dialogWarningRoot.visible = false
            }
        }

        x: root.width / 2 - dialogWarningRoot.width / 2
        y: root.height / 2 - dialogWarningRoot.height / 2
    }
    /**********************************************************************************************************/

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
            property var componentInput: inpData
            property var componentOutput: outData
            property var componentChart: chartComp
            property var componentCanv: canvCard
            property alias componentNumber: inpData.componentNumber

            InputData {
                property var dialogWarning: dialogWarning
                property int componentNumber

                id: inpData
                x: 0
                y: 0

                Component.onCompleted: {
                    inpData.signalCalculateTransformerPower.connect(slotCalculateFullPowerOfTransformer)
                }
            }

            ChartCard {
                id: chartComp
                x: 0
                y: Screen.desktopAvailableHeight / 2 //360
            }

            OutputData {
                id: outData
                x: backgroundRectangle.width - Screen.desktopAvailableWidth / 2.015 //677
                y: 0
            }

            CanvasCard {
                id: canvCard
                x: backgroundRectangle.width - inpData.width
                y: Screen.desktopAvailableHeight / 2 //360
            }

            //Диалог с сообщениями пользователю
            /**********************************************************************************************************/
            Dialog {
                id: dialogWarning
                modal: true
                title: qsTr("Заполнены не все поля!")
                closePolicy: Popup.CloseOnEscape
                palette.button: "#26972D"
                palette.window: "#67E46F"
                DialogButtonBox {
                    anchors.centerIn: parent
                    Layout.alignment: Qt.AlignHCenter
                    standardButtons: DialogButtonBox.Ok
                    onAccepted: {
                        dialogWarning.visible = false
                    }
                }

                x: root.width / 2 - dialogWarning.width / 2
                y: root.height / 2 - dialogWarning.height / 2
            }
            /**********************************************************************************************************/
        }
    }

    //Стартовый диалог программы
    /*****************************************************************************************************************/
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
                validator: RegularExpressionValidator {
                    regularExpression: /[1-9]{1,2}[0]{0,1}/
                }

                Keys.onReturnPressed: onAcceptedDialog()
                Keys.onEnterPressed: onAcceptedDialog()

                //Установка фокуса на текстовое поле
                Component.onCompleted: {
                    modalTextInput.forceActiveFocus()
                }
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
