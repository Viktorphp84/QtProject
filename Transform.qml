import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.qmlmodels
import C_Model 1.0

Item {
    id: transCard
    width: root.width
    height: root.height

    property double transformerResistance: 0

    //Расчет однофазного КЗ
    function calcSinglePhaseShortCircuit() {

        for (var i = 0; i < root.componentCardsApp.length; ++i) {
            let input = root.componentCardsApp[i].componentInput.parameterCalculation
            let output = root.componentCardsApp[i].componentOutput
            if (input.checkResistanceVectorPhaseZero()) {
                input.calculationSinglePhaseShortCircuit(
                            root.componentTransformApp.transformerResistance) //расчет однофазного КЗ
                let vecSinglePhaseShortCircuit = input.getVecSinglePhaseShortCircuit(
                        ) //запись в вектор

                for (var u = 0; u < input.numberOfConsumers; ++u) {
                    output.columnScrollOutput_9.children[u].textField = String(
                                vecSinglePhaseShortCircuit[u]) //заполнение строк
                }
            } else {

                //выводим сообщение, что для расчета однофазных КЗ нужно ввести все значения экономической плотности
            }
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
        height: 320
        radius: 5

        Label {
            id: grandLabelTrans
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Параметры трансформатора"
            font.bold: true
            font.pointSize: 20
        }

        Rectangle {
            id: leftTopRect
            anchors.top: grandLabelTrans.bottom
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
                        "name": "&Delta;/Y<sub>0</sub"
                    }]
            }

            delegate: Label {
                text: display
                padding: 12

                Rectangle {
                    id: rectDelegate
                    //anchors.fill: parent
                    color: "#efefef"
                    z: -1
                    width: leftTopRect.width
                    height: leftTopRect.height / 2 - 1
                }
            }
        }

        Model {
            id: c_model
        }

        Rectangle {
            id: headerRect
            anchors.top: grandLabelTrans.bottom
            anchors.left: leftTopRect.right
            anchors.leftMargin: 2
            //anchors.leftMargin: 52
            color: "#efefef"
            width: tableView.contentWidth
            height: tableView.contentHeight / tableView.rows
            Text {
                anchors.centerIn: parent
                text: "Мощность, кВа"
            }
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

            model: c_model


            /*selectionModel: ItemSelectionModel {
                model: tableView.model
            }*/
            property var object: Rectangle {}
            property int columnTable: 0
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
                        tableView.columnTable = index
                        if (index % 4) {
                            transCard.transformerResistance = parseFloat(
                                        display)
                            //root.componentCardsApp.componentOutput.resistanceTransformer = display
                            for (var i = 0; i < root.componentCardsApp.length; ++i) {
                                root.componentCardsApp[i].componentOutput.resistanceTransformer
                                        = display
                                root.componentCardsApp[i].componentInput.transformerResistance = display
                                if((index + 1) % 2 == 0 && (index + 1) % 4 != 0 ) {
                                    root.componentCardsApp[i].componentInput.connectionDiagram = "Y/Y0"
                                } else if(index % 2 == 0 && index % 4 != 0) {
                                    root.componentCardsApp[i].componentInput.connectionDiagram = "Y/Z0"
                                } else if ((index + 1) % 4 == 0 && (index + 1) % 2 == 0) {
                                    root.componentCardsApp[i].componentInput.connectionDiagram = "\u0394/Y0"
                                }
                                root.componentCardsApp[i].componentInput.transformerPower = String(c_model.getTransformerPower(index))
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
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 50
            anchors.bottomMargin: 15
            width: 120
            text: "Добавить колонку"
            onClicked: {
                //c_model.index()
                tableView.object.color = "#efefef"
                c_model.addColumn()
                transRect.widthFrame = leftTopRect.width + tableView.contentWidth + 75
            }
        }

        Button {
            id: buttonDel
            anchors.top: tableView.bottom
            anchors.left: buttonAdd.right
            width: 120
            anchors.leftMargin: 10
            anchors.bottomMargin: 15
            anchors.bottom: parent.bottom
            anchors.margins: 2
            text: "Удалить колонку"
            onClicked: {
                tableView.object.color = "#efefef"
                c_model.deleteColumn(tableView.columnTable)
                transRect.widthFrame = leftTopRect.width + tableView.contentWidth - 28
            }
        }

        Button {
            id: buttonSave
            anchors.left: buttonDel.right
            width: 120
            anchors.leftMargin: 10
            anchors.bottomMargin: 15
            anchors.top: tableView.bottom
            anchors.bottom: parent.bottom
            anchors.margins: 2
            text: "Сохранить"

            onClicked: {
                tableView.model.writeData(tableView.indexCell,
                                          tableView.textCell)
            }
        }

        Button {
            id: buttonReset
            anchors.top: tableView.bottom
            anchors.bottom: parent.bottom
            anchors.left: buttonSave.right
            width: 120
            anchors.leftMargin: 10
            anchors.bottomMargin: 15
            anchors.margins: 2
            text: "Сбросить"
            onClicked: {
                c_model.setDefaultModel()
            }
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
