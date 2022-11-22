import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.qmlmodels
import CppModel

Item {
    id: transCard
    width: root.width
    height: root.height

    property double transformerResistance: 0
    property alias textTransPower: textFieldTransPower.text

    //Расчет однофазного КЗ
    function calcSinglePhaseShortCircuit() {

        for (var i = 0; i < root.componentCardsApp.length; ++i) {
            let input = root.componentCardsApp[i].componentInput.parameterCalculation
            let output = root.componentCardsApp[i].componentOutput
            if (input.checkResistanceVectorPhaseZero()) {
                input.calculationSinglePhaseShortCircuit(
                            root.componentTransformApp.transformerResistance) //расчет однофазного КЗ
                let vecSinglePhaseShortCircuit = input.getVecSinglePhaseShortCircuit() //запись в вектор

                for (var u = 0; u < input.numberOfConsumers; ++u) {
                    output.columnScrollOutput_9.children[u].textField = String(
                                vecSinglePhaseShortCircuit[u]) //заполнение строк
                }
            }
        }
    }

    DropShadow {
        id: dropShadowTransPower
        anchors.fill: rectTransformerPower
        source: rectTransformerPower
        transparentBorder: true
        horizontalOffset: 3
        verticalOffset: 3
        radius: 5
        color: "#80000000"
    }

    Rectangle {
        id: rectTransformerPower
        x: transCard.width - rectTransformerPower.width
        y: 0

        width: 300
        height: 120
        radius: 5
        border.color: "#e4e4e4"
        border.width: 1

        Text {
            id: text1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            text: "Рекомендуемая мощность"

            font.bold: true
            font.pointSize: 15
        }

        Text {
            id: text2
            anchors.top: text1.bottom
            anchors.topMargin: -5
            anchors.horizontalCenter: parent.horizontalCenter
            text: "трансформатора"

            font.bold: true
            font.pointSize: 15
        }

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true

            onClicked: {
                rectTransformerPower.z = 10
                transRect.z = 0
            }

            onPressed: {
                rectTransformerPower.z = 10
                transRect.z = 0
            }
        }

        RowLayout {
            anchors.top: text2.bottom
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter

            TextField {
                id: textFieldTransPower

                readOnly: true
            }

            Label {
                text: "кВА"
            }
        }

        DragHandler {
            target: rectTransformerPower

            xAxis.enabled: true
            xAxis.minimum: 0
            xAxis.maximum: backgroundRectangle.width - rectTransformerPower.width
            yAxis.enabled: true
            yAxis.minimum: 0
            yAxis.maximum: backgroundRectangle.height - rectTransformerPower.height
        }
    }

    DropShadow {
        id: dropShadow
        anchors.fill: transRect
        source: transRect
        transparentBorder: true
        horizontalOffset: 3
        verticalOffset: 3
        radius: 5
        color: "#80000000"
    }

    Rectangle {
        id: transRect
        x: 0
        y: 0

        property int widthFrame: tableView.contentWidth + leftTopRect.width + 23

        width: widthFrame
        height: 340
        radius: 5

        MouseArea {
            anchors.fill: parent

            onClicked: {
                rectTransformerPower.z = 0
                transRect.z = 10
            }

            onPressed: {
                rectTransformerPower.z = 0
                transRect.z = 10
            }
        }

        Label {
            id: grandLabelTrans

            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            height: str1.height + str2.height

            Text {
                id: str1

                font.bold: true
                font.pointSize: 15
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                text: "Полные сопротивления трансформаторов 10/0.4 кВ"
            }
            Text {
                id: str2

                font.bold: true
                font.pointSize: 15
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: str1.bottom
                text: "при замыкании на корпус, Ом "
            }
        }

        Rectangle {
            id: leftTopRect

            anchors.top: grandLabelTrans.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 10
            color: "#efefef"
            width: textLab.contentWidth + 10
            height: (tableView.contentHeight / tableView.rows) * 2

            Text {
                id: textLab

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: headerRect.height / 2 - textLab.height / 2
                anchors.leftMargin: 5
                text: "Схема соединения обмоток"
            }
        }

        TableView {
            id: tableViewLeft

            anchors.left: parent.left
            anchors.top: leftTopRect.bottom
            anchors.right: leftTopRect.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
            leftMargin: 10
            topMargin: 2
            columnSpacing: 2
            rowSpacing: 2

            model: TableModel {
                TableModelColumn {
                    display: "name"
                }

                rows: [{
                        "name": "Y/Y<sub>0</sub>"
                    }, {
                        "name": "Y/Z<sub>0</sub>"
                    }, {
                        "name": "&Delta;/Y<sub>0</sub>"
                    }]
            }

            delegate: Label {

                Text {
                    anchors.top: parent.top
                    anchors.topMargin: 12.5
                    anchors.left: parent.left
                    anchors.leftMargin: 25
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    text: display
                    textFormat: Text.RichText
                }

                padding: 12

                Rectangle {
                    id: rectDelegate

                    color: "#efefef"
                    z: -1
                    width: leftTopRect.width
                    height: leftTopRect.height / 2 - 1
                }
            }
        }

        Rectangle {
            id: headerRect
            anchors.top: grandLabelTrans.bottom
            anchors.topMargin: 10
            anchors.left: leftTopRect.right
            anchors.leftMargin: 2
            color: "#efefef"
            width: tableView.contentWidth
            height: tableView.contentHeight / tableView.rows
            Text {
                anchors.centerIn: parent
                text: "Мощность, кВА"
            }
        }

        Rectangle {
            id: rectCell
            color: "#efefef"
        }

        TableView {
            id: tableView
            anchors.top: headerRect.bottom
            anchors.left: leftTopRect.right
            anchors.bottomMargin: 50
            topMargin: 2
            leftMargin: 2
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            columnSpacing: 2
            rowSpacing: 2

            model: CppTableModel {

            }

            property var object: rectCell

            property int columnTable: (tableView.columns * tableView.rows - 1)
            property int indexCell: 0
            property string textCell: ""

            delegate: Rectangle {
                id: rectDelTableView
                implicitWidth: 50
                implicitHeight: 40
                color: "#efefef"

                TextInput {
                    id: textEdited
                    text: display
                    anchors.centerIn: parent

                    validator: RegularExpressionValidator {
                        regularExpression: /(\d{1,4})([.]\d{1,3})?$/
                    }

                    onEditingFinished: {
                        tableView.indexCell = index
                        tableView.textCell = displayText
                        tableView.model.writeData(tableView.indexCell,
                                                  tableView.textCell)
                    }

                    onAccepted: {
                        transCard.transformerResistance = parseFloat(display)
                        //root.componentCardsApp.componentOutput.resistanceTransformer = display
                        for (var i = 0; i < root.componentCardsApp.length; ++i) {
                            root.componentCardsApp[i].componentOutput.resistanceTransformer
                                    = display
                        }

                        calcSinglePhaseShortCircuit()
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: true

                    onClicked: {

                        if (tableView.object === rectDelTableView) {
                            if (rectDelTableView.color == "#efefef") {
                                rectDelTableView.color = "gray"
                            } else {
                                rectDelTableView.color = "#efefef"
                            }
                            tableView.object = rectDelTableView
                        } else {
                            tableView.object.color = "#efefef"
                            tableView.object = rectDelTableView
                            rectDelTableView.color = "gray"
                        }
                        textEdited.forceActiveFocus()

                        if(index > 31) {
                            tableView.columnTable = index
                        }

                        if (index % 4) {
                            transCard.transformerResistance = parseFloat(display)

                            for (var i = 0; i < root.componentCardsApp.length; ++i) {

                                root.componentCardsApp[i].componentInput.transformerResistance = display
                                if((index + 1) % 2 == 0 && (index + 1) % 4 != 0 ) {
                                    root.componentCardsApp[i].componentInput.connectionDiagram = "Y/Y0"
                                } else if(index % 2 == 0 && index % 4 != 0) {
                                    root.componentCardsApp[i].componentInput.connectionDiagram = "Y/Z0"
                                } else if ((index + 1) % 4 == 0 && (index + 1) % 2 == 0) {
                                    root.componentCardsApp[i].componentInput.connectionDiagram = "\u0394/Y0"
                                }
                                root.componentCardsApp[i].componentInput.transformerPower = String(c_model.getTransformerPower(index))
                                root.componentCardsApp[i].componentCanv.transformerPower = c_model.getTransformerPower(index) //передача номинала мощности
                                                                                               //для отображения на графике
                            }

                            calcSinglePhaseShortCircuit()
                        } else {
                            //вывод сообщения о выборе правильной ячейки
                            dialogCell.visible = true
                        }
                    }
                }
            }
        }

        Dialog {
            id: dialogCell
            anchors.centerIn: parent
            width: 220
            height: 85
            Text {
                id: textDialogCell
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("   Для расчетов выберите\nячейку с сопротивлением!")
            }
            visible: false

            Button {
                id: buttonDialogCell
                anchors.top: textDialogCell.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: parent.horizontalCenter
                width: 70
                height: 30
                text: "Ok"

                onClicked: dialogCell.accept()
            }
        }

        Button {
            id: buttonAdd
            anchors.top: tableView.bottom
            anchors.topMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 50
            text: "Добавить колонку"
            width: 120
            height: 35

            onClicked: {
                if(transRect.width < transCard.width - 60) {
                    tableView.object.color = "#efefef"
                    c_model.addColumn()
                    transRect.widthFrame = leftTopRect.width + tableView.contentWidth + 75
                }
            }
        }

        Button {
            id: buttonDel

            anchors.verticalCenter: buttonAdd.verticalCenter
            anchors.left: buttonAdd.right
            anchors.leftMargin: 10
            text: "Удалить колонку"
            width: 120
            height: 35

            onClicked: {
                if(tableView.columns > 8) {
                    tableView.object.color = "#efefef"
                    c_model.deleteColumn(tableView.columnTable)
                    transRect.widthFrame = leftTopRect.width + tableView.contentWidth - 28
                }
            }
        }

        Button {
            id: buttonSave

            anchors.left: buttonDel.right
            anchors.leftMargin: 10
            anchors.verticalCenter: buttonDel.verticalCenter
            text: "Сохранить"
            width: 120
            height: 35

            onClicked: {
                tableView.model.writeData(tableView.indexCell,
                                          tableView.textCell)
            }
        }

        Button {
            id: buttonReset

            anchors.left: buttonSave.right
            anchors.leftMargin: 10
            anchors.verticalCenter: buttonSave.verticalCenter
            text: "Сбросить"
            width: 120
            height: 35

            onClicked: {
                c_model.setDefaultModel()
                tableView.object = rectCell
                transRect.widthFrame = leftTopRect.width + 414 + 23
            }
        }

        DragHandler {
            target: transRect
            xAxis.enabled: true
            xAxis.minimum: 0
            xAxis.maximum: backgroundRectangle.width - transRect.width
            yAxis.enabled: true
            yAxis.minimum: 0
            yAxis.maximum: backgroundRectangle.height - transRect.height
        }
    }
}
