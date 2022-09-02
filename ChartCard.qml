import QtQuick
import QtCharts
import Qt5Compat.GraphicalEffects

Item {
    property var lineSeries: lineSeriesChart
    property alias maxAxisX: valueAxisX.max
    property alias tickCountX: valueAxisX.tickCount

    //Переменные для сохранения позиции и размера окна при развертываниии на весь экран
    property int chartX: 0
    property int chartY: 0
    property int chartWidth: 0
    property int chartHeight: 0

    DropShadow {
        anchors.fill: rectChart
        source: rectChart
        transparentBorder: true
        horizontalOffset: 4
        verticalOffset: 4
        radius: 5
        color: "#80000000"
    }

    Rectangle {
        id: rectChart
        width: 677
        height: 300
        radius: 5
        border.color: "#d1d1d1"

        ChartView {
            id: chartCard
            anchors.centerIn: parent
            ValuesAxis {
                id: valueAxisX
                min: 0
                max: 10
                tickCount: 11
            }

            ValuesAxis {
                id: valueAxisY
                min: 0
                max: 9
                tickCount: 10
            }

            width: parent.width
            height: parent.height

            LineSeries {
                id: lineSeriesChart
                axisX: valueAxisX
                axisY: valueAxisY
                name: "График отклонения напряжения"
            }
        }

        Drag.active: mouseRectChart.drag.active

        //Нижняя область для изменения размера
        /*****************************************************************/
        Rectangle {
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 7
            anchors.rightMargin: 7
            height: 5

            MouseArea {
                id: bottomMouseScope
                anchors.fill: parent
                cursorShape: Qt.SizeVerCursor
                acceptedButtons: Qt.LeftButton
                property double clickPosBottom

                onPressed: {
                    clickPosBottom = bottomMouseScope.mouseY
                }

                onPositionChanged: {
                    let delta = bottomMouseScope.mouseY - clickPosBottom
                    rectChart.height += delta
                }
            }
        }
        /*****************************************************************/

        //Верхняя область для изменения размера
        /*****************************************************************/
        Rectangle {
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 7
            anchors.rightMargin: 7
            height: 5

            MouseArea {
                id: topMouseScope
                anchors.fill: parent
                cursorShape: Qt.SizeVerCursor
                acceptedButtons: Qt.LeftButton
                property double clickPosTop

                onPressed: {
                    clickPosTop = topMouseScope.mouseY
                }

                onPositionChanged: {
                    let delta = topMouseScope.mouseY - clickPosTop
                    rectChart.height -= delta
                    rectChart.y += delta
                }
            }
        }
        /*****************************************************************/

        //Левая область для изменения размера
        /*****************************************************************/
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 7
            anchors.bottomMargin: 7
            width: 5

            MouseArea {
                id: leftMouseScope
                anchors.fill: parent
                cursorShape: Qt.SizeHorCursor
                acceptedButtons: Qt.LeftButton
                pressAndHoldInterval: 50

                property double clickPosLeft

                onPressed: {
                    clickPosLeft = leftMouseScope.mouseX
                }

                onPositionChanged: {
                    let delta = leftMouseScope.mouseX - clickPosLeft
                    rectChart.width -= delta
                    rectChart.x += delta
                }
            }
        }
        /*****************************************************************/

        //Правая область для изменения размера
        /*****************************************************************/
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 7
            anchors.bottomMargin: 7
            width: 5

            MouseArea {
                id: rightMouseScope
                anchors.fill: parent
                cursorShape: Qt.SizeHorCursor
                acceptedButtons: Qt.LeftButton
                property double clickPosRight

                onPressed: {
                    clickPosRight = rightMouseScope.mouseX
                }

                onPositionChanged: {
                    let delta = rightMouseScope.mouseX - clickPosRight
                    rectChart.width += delta
                }
            }
        }
        /*****************************************************************/

        //Вехний левый угол для изменения размера
        /*****************************************************************/
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 2
            anchors.topMargin: 2
            width: 7
            height: 7

            MouseArea {
                id: topLeftMouseScope
                anchors.fill: parent
                cursorShape: Qt.SizeFDiagCursor
                acceptedButtons: Qt.LeftButton

                property double clickPosTop
                property double clickPosLeft

                onPressed: {
                    clickPosTop = topLeftMouseScope.mouseY
                    clickPosLeft = topLeftMouseScope.mouseX
                }

                onPositionChanged: {
                    let deltaY = topLeftMouseScope.mouseY - clickPosTop
                    let deltaX = topLeftMouseScope.mouseX - clickPosLeft
                    rectChart.height -= deltaY
                    rectChart.width -= deltaX
                    rectChart.y += deltaY
                    rectChart.x += deltaX
                }
            }
        }
        /*****************************************************************/

        //Вехний правый угол для изменения размера
        /*****************************************************************/
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 2
            anchors.topMargin: 2
            width: 7
            height: 7

            MouseArea {
                id: topRightMouseScope
                anchors.fill: parent
                cursorShape: Qt.SizeBDiagCursor
                acceptedButtons: Qt.LeftButton

                property double clickPosTop
                property double clickPosRight

                onPressed: {
                    clickPosTop = topRightMouseScope.mouseY
                    clickPosRight = topRightMouseScope.mouseX
                }

                onPositionChanged: {
                    let deltaY = topRightMouseScope.mouseY - clickPosTop
                    let deltaX = topRightMouseScope.mouseX - clickPosRight
                    rectChart.height -= deltaY
                    rectChart.width += deltaX
                    rectChart.y += deltaY
                }
            }
        }
        /*****************************************************************/

        //Нижний правый угол для изменения размера
        /*****************************************************************/
        Rectangle {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 2
            anchors.bottomMargin: 2
            width: 7
            height: 7

            MouseArea {
                id: bottomRightMouseScope
                anchors.fill: parent
                cursorShape: Qt.SizeFDiagCursor
                acceptedButtons: Qt.LeftButton

                property double clickPosBottom
                property double clickPosRight

                onPressed: {
                    clickPosBottom = bottomRightMouseScope.mouseY
                    clickPosRight = bottomRightMouseScope.mouseX
                }

                onPositionChanged: {
                    let deltaY = bottomRightMouseScope.mouseY - clickPosBottom
                    let deltaX = bottomRightMouseScope.mouseX - clickPosRight
                    rectChart.height += deltaY
                    rectChart.width += deltaX
                }
            }
        }
        /*****************************************************************/

        //Нижний левый угол для изменения размера
        /*****************************************************************/
        Rectangle {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 2
            anchors.bottomMargin: 2
            width: 7
            height: 7

            MouseArea {
                id: bottomLeftMouseScope
                anchors.fill: parent
                cursorShape: Qt.SizeBDiagCursor
                acceptedButtons: Qt.LeftButton

                property double clickPosLeft
                property double clickPosBottom

                onPressed: {
                    clickPosLeft = bottomLeftMouseScope.mouseX
                    clickPosBottom = bottomLeftMouseScope.mouseY
                }

                onPositionChanged: {
                    let deltaX = bottomLeftMouseScope.mouseX - clickPosLeft
                    let deltaY = bottomLeftMouseScope.mouseY - clickPosBottom
                    rectChart.width -= deltaX
                    rectChart.x += deltaX
                    rectChart.height += deltaY
                }
            }
        }
        /*****************************************************************/
    }

    MouseArea {
        id: mouseRectChart
        width: rectChart.width - 10
        height: rectChart.height - 10
        anchors.centerIn: rectChart
        drag {
            target: rectChart
            minimumX: 0
            minimumY: -inpData.height
            maximumX: backgroundRectangle.width - rectChart.width
            maximumY: backgroundRectangle.height - rectChart.height - inpData.height
        }

        onDoubleClicked: {

            if (rectChart.width == backgroundRectangle.width
                    && rectChart.height == backgroundRectangle.height) {
                rectChart.width = chartWidth
                rectChart.height = chartHeight
                rectChart.x = chartX
                rectChart.y = chartY
            } else {
                chartX = rectChart.x
                chartY = rectChart.y
                chartWidth = rectChart.width
                chartHeight = rectChart.height
                rectChart.width = backgroundRectangle.width
                rectChart.height = backgroundRectangle.height
                rectChart.x = 0
                rectChart.y = -inpData.height
            }
        }

        onContainsMouseChanged: {
            chartComp.z = outData.z + inpData.z + canvCard.z + 1
        }
    }
}
