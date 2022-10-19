import QtQuick
import QtCharts
import Qt5Compat.GraphicalEffects
//import QtQml 2.0

Item {
    id: chartItem
    property var lineSeries: lineSeriesChart
    property alias maxAxisX: valueAxisX.max
    property alias maxAxisY: valueAxisY.max
    property alias tickCountY: valueAxisY.tickCount
    property alias categoryAxis: valueAxisX
    property bool activeFocusOnWindow: {chartItem.z > inpData.z &&
                                        chartItem.z > outData.z &&
                                        chartItem.z > canvCard.z}

    //Переменные для сохранения позиции и размера окна при развертываниии на весь экран
    property int chartX: 0
    property int chartY: 0
    property int chartWidth: 0
    property int chartHeight: 0

    function chartLocale() {
        let locale = Qt.locale("en")
        locale.numberOptions = "DefaultNumberOptions"
        console.log(locale.numberOptions)
        return locale
    }

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
            localizeNumbers: true
            locale: Qt.locale("en")
            antialiasing: true

//            ValuesAxis {
//                id: valueAxisX
//                min: 0
//                max: 10
//                tickCount: 11
//                titleText: "Участки"
//                labelFormat: "%.0f"
//            }

            ValuesAxis {
                id: valueAxisY
                min: 0
                max: 9
                tickCount: 10
                titleText: "Потеря напряжения, В"
                labelFormat: "%.0f"
            }

            CategoryAxis {
                id: valueAxisX
                min: 0
                max: 10

                CategoryRange {
                    label: "1"
                    endValue: 1
                }
                CategoryRange {
                    label: "2"
                    endValue: 2
                }
                CategoryRange {
                    label: "3"
                    endValue: 3
                }
                CategoryRange {
                    label: "4"
                    endValue: 4
                }
                CategoryRange {
                    label: "5"
                    endValue: 5
                }
                CategoryRange {
                    label: "6"
                    endValue: 6
                }
                CategoryRange {
                    label: "7"
                    endValue: 7
                }
                CategoryRange {
                    label: "8"
                    endValue: 8
                }
                CategoryRange {
                    label: "9"
                    endValue: 9
                }
                CategoryRange {
                    label: "10"
                    endValue: 10
                }
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
                cursorShape: chartItem.activeFocusOnWindow ? Qt.SizeVerCursor : Qt.ArrowCursor
                acceptedButtons: Qt.LeftButton
                property double clickPosBottom

                onPressed: {
                    if(chartItem.activeFocusOnWindow) {
                        clickPosBottom = bottomMouseScope.mouseY
                    }
                }

                onPositionChanged: {
                    if(chartItem.activeFocusOnWindow) {
                        let delta = bottomMouseScope.mouseY - clickPosBottom
                        if(delta > 0) {
                            if((rectChart.height + delta) < (backgroundRectangle.height - (360 + rectChart.y))) {
                                rectChart.height += delta
                            } else {
                                delta = (backgroundRectangle.height - (360 + rectChart.y)) - rectChart.height
                                rectChart.height += delta
                            }
                        } else if (delta < 0) {
                            if((rectChart.height + delta) > 300) {
                                rectChart.height += delta
                            } else {
                                delta = 300 - rectChart.height
                                rectChart.height += delta
                            }
                        }
                    }
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
                cursorShape: chartItem.activeFocusOnWindow ? Qt.SizeVerCursor : Qt.ArrowCursor
                acceptedButtons: Qt.LeftButton
                property double clickPosTop

                onPressed: {
                    if(chartItem.activeFocusOnWindow) {
                        clickPosTop = topMouseScope.mouseY
                    }
                }

                onPositionChanged: {
                    if(chartItem.activeFocusOnWindow) {
                        let delta = topMouseScope.mouseY - clickPosTop
                        if(delta > 0) {
                            if((rectChart.height - delta) > 300) {
                                rectChart.height -= delta
                                rectChart.y += delta
                            } else {
                                delta = rectChart.height - 300
                                rectChart.height -= delta
                                rectChart.y += delta
                            }
                        } else if(delta < 0) {
                            if((rectChart.height - delta) < (360 + rectChart.y + rectChart.height)) {
                                rectChart.height -= delta
                                rectChart.y += delta
                            } else {
                                delta = rectChart.height - (360 + rectChart.y + rectChart.height)
                                rectChart.height -= delta
                                rectChart.y += delta
                            }
                        }
                    }
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
                cursorShape: chartItem.activeFocusOnWindow ? Qt.SizeHorCursor : Qt.ArrowCursor
                acceptedButtons: Qt.LeftButton
                pressAndHoldInterval: 50

                property double clickPosLeft

                onPressed: {
                    if(chartItem.activeFocus) {
                       clickPosLeft = leftMouseScope.mouseX
                    }
                }

                onPositionChanged: {
                    if(chartItem.activeFocusOnWindow) {
                        let delta = leftMouseScope.mouseX - clickPosLeft
                        if(delta > 0) {
                            if((rectChart.width - delta) > 677) {
                                rectChart.width -= delta
                                rectChart.x += delta
                            } else {
                                delta = rectChart.width - 677
                                rectChart.width -= delta
                                rectChart.x += delta
                            }
                        } else if(delta < 0) {
                            if((rectChart.width - delta) < (rectChart.x + rectChart.width)) {
                                rectChart.width -= delta
                                rectChart.x += delta
                            } else {
                                delta = rectChart.width - (rectChart.x + rectChart.width)
                                rectChart.width -= delta
                                rectChart.x += delta
                            }
                        }
                    }
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
                cursorShape: chartItem.activeFocusOnWindow ? Qt.SizeHorCursor : Qt.ArrowCursor
                acceptedButtons: Qt.LeftButton
                property double clickPosRight

                onPressed: {
                    if(chartItem.activeFocusOnWindow) {
                       clickPosRight = rightMouseScope.mouseX
                    }
                }

                onPositionChanged: {
                    if(chartItem.activeFocusOnWindow) {
                        let delta = rightMouseScope.mouseX - clickPosRight
                        if(delta > 0) {
                            if((rectChart.width + delta) < (backgroundRectangle.width - rectChart.x)) {
                                rectChart.width += delta
                            } else {
                                delta = (backgroundRectangle.width - rectChart.x) - rectChart.width
                                rectChart.width += delta
                            }
                        } else if (delta < 0) {
                            if((rectChart.width + delta) > 677) {
                                rectChart.width += delta
                            } else {
                                delta = 677 - rectChart.width
                                rectChart.width += delta
                            }
                        }
                    }
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
                cursorShape: chartItem.activeFocusOnWindow ? Qt.SizeFDiagCursor : Qt.ArrowCursor
                acceptedButtons: Qt.LeftButton

                property double clickPosTop
                property double clickPosLeft

                onPressed: {
                    if(chartItem.activeFocusOnWindow) {
                        clickPosTop = topLeftMouseScope.mouseY
                        clickPosLeft = topLeftMouseScope.mouseX
                    }
                }

                onPositionChanged: {
                    if(chartItem.activeFocusOnWindow) {
                        //Верхняя область
                        let deltaY = topLeftMouseScope.mouseY - clickPosTop
                        if(deltaY > 0) {
                            if((rectChart.height - deltaY) > 300) {
                                rectChart.height -= deltaY
                                rectChart.y += deltaY
                            } else {
                                deltaY = rectChart.height - 300
                                rectChart.height -= deltaY
                                rectChart.y += deltaY
                            }
                        } else if(deltaY < 0) {
                            if((rectChart.height - deltaY) < (360 + rectChart.y + rectChart.height)) {
                                rectChart.height -= deltaY
                                rectChart.y += deltaY
                            } else {
                                deltaY = rectChart.height - (360 + rectChart.y + rectChart.height)
                                rectChart.height -= deltaY
                                rectChart.y += deltaY
                            }
                        }

                        //Левая область
                        let deltaX = topLeftMouseScope.mouseX - clickPosLeft
                        if(deltaX > 0) {
                            if((rectChart.width - deltaX) > 677) {
                                rectChart.width -= deltaX
                                rectChart.x += deltaX
                            } else {
                                deltaX = rectChart.width - 677
                                rectChart.width -= deltaX
                                rectChart.x += deltaX
                            }
                        } else if(deltaX < 0) {
                            if((rectChart.width - deltaX) < (rectChart.x + rectChart.width)) {
                                rectChart.width -= deltaX
                                rectChart.x += deltaX
                            } else {
                                deltaX = rectChart.width - (rectChart.x + rectChart.width)
                                rectChart.width -= deltaX
                                rectChart.x += deltaX
                            }
                        }
                    }
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
                cursorShape: chartItem.activeFocusOnWindow ? Qt.SizeBDiagCursor : Qt.ArrowCursor
                acceptedButtons: Qt.LeftButton

                property double clickPosTop
                property double clickPosRight

                onPressed: {
                    if(chartItem.activeFocusOnWindow) {
                        clickPosTop = topRightMouseScope.mouseY
                        clickPosRight = topRightMouseScope.mouseX
                    }
                }

                onPositionChanged: {
                    if(chartItem.activeFocusOnWindow) {
                        //Верхняя область
                        let deltaY = topRightMouseScope.mouseY - clickPosTop
                        if(deltaY > 0) {
                            if((rectChart.height - deltaY) > 300) {
                                rectChart.height -= deltaY
                                rectChart.y += deltaY
                            } else {
                                deltaY = rectChart.height - 300
                                rectChart.height -= deltaY
                                rectChart.y += deltaY
                            }
                        } else if(deltaY < 0) {
                            if((rectChart.height - deltaY) < (360 + rectChart.y + rectChart.height)) {
                                rectChart.height -= deltaY
                                rectChart.y += deltaY
                            } else {
                                deltaY = rectChart.height - (360 + rectChart.y + rectChart.height)
                                rectChart.height -= deltaY
                                rectChart.y += deltaY
                            }
                        }

                        //Правая область
                        let deltaX = topRightMouseScope.mouseX - clickPosRight
                        if(deltaX > 0) {
                            if((rectChart.width + deltaX) < (backgroundRectangle.width - rectChart.x)) {
                                rectChart.width += deltaX
                            } else {
                                deltaX = (backgroundRectangle.width - rectChart.x) - rectChart.width
                                rectChart.width += deltaX
                            }
                        } else if (deltaX < 0) {
                            if((rectChart.width + deltaX) > 677) {
                                rectChart.width += deltaX
                            } else {
                                deltaX = 677 - rectChart.width
                                rectChart.width += deltaX
                            }
                        }
                    }
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
                cursorShape: chartItem.activeFocusOnWindow ? Qt.SizeFDiagCursor : Qt.ArrowCursor
                acceptedButtons: Qt.LeftButton

                property double clickPosBottom
                property double clickPosRight

                onPressed: {
                    if(chartItem.activeFocusOnWindow) {
                        clickPosBottom = bottomRightMouseScope.mouseY
                        clickPosRight = bottomRightMouseScope.mouseX
                    }
                }

                onPositionChanged: {
                    if(chartItem.activeFocusOnWindow) {
                        //Правая область
                        let deltaX = bottomRightMouseScope.mouseX - clickPosRight
                        if(deltaX > 0) {
                            if((rectChart.width + deltaX) < (backgroundRectangle.width - rectChart.x)) {
                                rectChart.width += deltaX
                            } else {
                                deltaX = (backgroundRectangle.width - rectChart.x) - rectChart.width
                                rectChart.width += deltaX
                            }
                        } else if (deltaX < 0) {
                            if((rectChart.width + deltaX) > 677) {
                                rectChart.width += deltaX
                            } else {
                                deltaX = 677 - rectChart.width
                                rectChart.width += deltaX
                            }
                        }

                        //Нижняя область
                        let deltaY = bottomRightMouseScope.mouseY - clickPosBottom
                        if(deltaY > 0) {
                            if((rectChart.height + deltaY) < (backgroundRectangle.height - (360 + rectChart.y))) {
                                rectChart.height += deltaY
                            } else {
                                deltaY = (backgroundRectangle.height - (360 + rectChart.y)) - rectChart.height
                                rectChart.height += deltaY
                            }
                        } else if (deltaY < 0) {
                            if((rectChart.height + deltaY) > 300) {
                                rectChart.height += deltaY
                            } else {
                                deltaY = 300 - rectChart.height
                                rectChart.height += deltaY
                            }
                        }
                    }
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
                cursorShape: chartItem.activeFocusOnWindow ? Qt.SizeBDiagCursor : Qt.ArrowCursor
                acceptedButtons: Qt.LeftButton

                property double clickPosLeft
                property double clickPosBottom

                onPressed: {
                    if(chartItem.activeFocusOnWindow) {
                        clickPosLeft = bottomLeftMouseScope.mouseX
                        clickPosBottom = bottomLeftMouseScope.mouseY
                    }
                }

                onPositionChanged: {
                    if(chartItem.activeFocusOnWindow) {
                        //Нижняя область
                        let deltaY = bottomLeftMouseScope.mouseY - clickPosBottom
                        if(deltaY > 0) {
                            if((rectChart.height + deltaY) < (backgroundRectangle.height - (360 + rectChart.y))) {
                                rectChart.height += deltaY
                            } else {
                                deltaY = (backgroundRectangle.height - (360 + rectChart.y)) - rectChart.height
                                rectChart.height += deltaY
                            }
                        } else if (deltaY < 0) {
                            if((rectChart.height + deltaY) > 300) {
                                rectChart.height += deltaY
                            } else {
                                deltaY = 300 - rectChart.height
                                rectChart.height += deltaY
                            }
                        }

                        //Левая область
                        let deltaX = bottomLeftMouseScope.mouseX - clickPosLeft
                        if(deltaX > 0) {
                            if((rectChart.width - deltaX) > 677) {
                                rectChart.width -= deltaX
                                rectChart.x += deltaX
                            } else {
                                deltaX = rectChart.width - 677
                                rectChart.width -= deltaX
                                rectChart.x += deltaX
                            }
                        } else if(deltaX < 0) {
                            if((rectChart.width - deltaX) < (rectChart.x + rectChart.width)) {
                                rectChart.width -= deltaX
                                rectChart.x += deltaX
                            } else {
                                deltaX = rectChart.width - (rectChart.x + rectChart.width)
                                rectChart.width -= deltaX
                                rectChart.x += deltaX
                            }
                        }
                    }
                }
            }
        }
        /*****************************************************************/
    }

    MouseArea {
        id: mouseRectChart
        width: rectChart.width - 7
        height: rectChart.height - 7
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
