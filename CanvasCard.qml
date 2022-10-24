import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Shapes

Rectangle {
    id: rootRect
    width: 677
    height: 300
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 3
        verticalOffset: 3
        radius: 5
        color: "#80000000"
    }
    border.color: "#d1d1d1"
    border.width: 2
    radius: 5
    Drag.active: mouseRectCanvas.drag.active

    property bool activeFocusOnWindow: {canvCard.z > chartComp.z &&
                                        canvCard.z > inpData.z &&
                                        canvCard.z > outData.z}

    property int canvasX: 0
    property int canvasY: 0
    property int canvasWidth: 0
    property int canvasHeight: 0

    MouseArea {
        id: mouseRectCanvas
        anchors.fill: parent
        drag {
            target: rootRect
            minimumX: 0
            minimumY: 0
            maximumX: backgroundRectangle.width - rootRect.width
            maximumY: backgroundRectangle.height - rootRect.height
        }

        onContainsMouseChanged: {
            canvCard.z = chartComp.z + outData.z + inpData.z + 1
        }

        onDoubleClicked: {
            if (rootRect.width == backgroundRectangle.width
                    && rootRect.height == backgroundRectangle.height) {
                rootRect.width = rootRect.canvasWidth
                rootRect.height = rootRect.canvasHeight
                rootRect.x = rootRect.canvasX
                rootRect.y = rootRect.canvasY
            } else {
                rootRect.canvasX = rootRect.x
                rootRect.canvasY = rootRect.y
                rootRect.canvasWidth = rootRect.width
                rootRect.canvasHeight = rootRect.height
                rootRect.width = backgroundRectangle.width
                rootRect.height = backgroundRectangle.height
                rootRect.x = 0
                rootRect.y = 0
            }
        }
    }

    Rectangle {
        id: rectTopBorder
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 25
        color: "#d1d1d1"
        radius: 5
    }

    Rectangle {
        id: rectCanv
        anchors.bottom: parent.bottom
        anchors.top: rectTopBorder.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: -2
        border.color: "#d1d1d1"
        border.width: 2
        clip: true
        radius: 5

        Canvas {
            id: canv
            anchors.fill: parent
            //contextType: "2d"
            /*DragHandler {
                target: canv
            }*/

            /*ShapePath {
                id: shapePath
                startX: 50
                startY: 50
                strokeColor: "blue"
                strokeWidth: 2
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathArc {
                    x: 0
                    y: 100
                    radiusX: 100
                    radiusY: 100
                    useLargeArc: true
                }

                PathSvg {
                    path: "L 150 50 L 100 150 z"
                }
            }*/

            property real lastX: 0
            property real lastY: 0
            property real deltaX: 0
            property real deltaY: 0
            property real scale: 1
            property int count: 7

            onPaint: {
                var myContext = getContext("2d")
                myContext.lineWidth = 1.5
                myContext.strokeStyle = "steelblue"

                lastX = area.mouseX - deltaX
                lastY = area.mouseY - deltaY
                var startX = lastX + canv.width / 10
                var startY = lastY + canv.height / 2
                var radius = 24
                var lineX = canv.width / 4
                var lengthRect = 30

                if(count > 0) myContext.scale(scale, scale)

                myContext.clearRect(0, 0, canv.width * 5, canv.height * 5)
                myContext.beginPath()
                myContext.arc(startX, startY, radius, 0, Math.PI * 2, false)
                myContext.stroke()
                myContext.beginPath()
                myContext.arc(startX + radius, startY, radius, 0, Math.PI * 2, false)
                myContext.lineTo(startX + radius + lineX, startY)
                myContext.strokeRect(startX + radius + lineX, startY - lengthRect / 2, lengthRect, lengthRect)
                myContext.moveTo(startX + radius + lineX + lengthRect, startY)
                myContext.lineTo(startX + 310, startY)
                //myContext.closePath()
                //myContext.stroke()
                myContext.moveTo(startX + 110, startY)
                myContext.lineTo(startX + 110, startY + 100)
                myContext.lineTo(startX + 110 - 10, startY + 100 - 10)
                myContext.moveTo(startX + 110, startY + 100)
                myContext.lineTo(startX + 110 + 10, startY + 100 - 10)

                myContext.moveTo(startX + 310, startY)
                myContext.lineTo(startX + 310, startY + 100)
                myContext.lineTo(startX + 310 - 10, startY + 100 - 10)
                myContext.moveTo(startX + 310, startY + 100)
                myContext.lineTo(startX + 310 + 10, startY + 100 - 10)


                myContext.stroke()
                canv.scale = 1
            }

            MouseArea {
                id: area
                anchors.fill: parent
                onPressed: {
                    canv.deltaX = mouseX - canv.lastX
                    canv.deltaY = mouseY - canv.lastY
                }
                onPositionChanged: {
                    canv.requestPaint()
                }

                onWheel: (wheel)=> {
                             canv.scale = 1 + wheel.angleDelta.y / 1200
                             canv.requestPaint()
                             if(wheel.angleDelta.y / 120 > 0) {
                                 canv.count = canv.count + wheel.angleDelta.y / 120
                             } else {
                                 if(canv.count > 0) canv.count = canv.count + wheel.angleDelta.y / 120
                             }
                }
            }
        }


        /*WheelHandler {
            property: "scale"
            target: canv

        }

        DragHandler {
            target: canv
        }*/

        /*Drag.active: mouseRectCanvas.drag.active

        MouseArea {
            id: mouseRectCanvas
            anchors.fill: parent
            drag {
                target: rectCanv
                minimumX: 0
                minimumY: 0
                maximumX: backgroundRectangle.width - rectCanv.width
                maximumY: backgroundRectangle.height - rectCanv.height
            }

            onContainsMouseChanged: {
                canvCard.z = chartComp.z + outData.z + inpData.z + 1
            }
        }*/
    }

    //Нижняя область для изменения размера
    /**********************************************************************************************************/
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        anchors.rightMargin: 7
        anchors.leftMargin: 7
        height: 5

        MouseArea {
            id: bottomMouseScopeCanv
            anchors.fill: parent
            cursorShape: rootRect.activeFocusOnWindow ? Qt.SizeVerCursor : Qt.ArrowCursor
            property double clickPosBottom

            onPressed: {
                if(rootRect.activeFocusOnWindow) {
                    clickPosBottom = bottomMouseScopeCanv.mouseY
                }
            }

            onPositionChanged: {
                if(rootRect.activeFocusOnWindow) {

                    let delta = bottomMouseScopeCanv.mouseY - clickPosBottom
                    if(delta > 0) {

                        if(delta < (backgroundRectangle.height - (rootRect.height + rootRect.y))) {
                            rootRect.height += delta

                        } else {
                            delta = (backgroundRectangle.height - rootRect.y) - rootRect.height
                            rootRect.height += delta
                        }

                    } else if(delta < 0) {

                        if((rootRect.height + delta) > 360) {
                            rootRect.height += delta
                        } else {
                            delta = 360 - rootRect.height
                            rootRect.height += delta
                        }
                    }
                }
            }
        }
    }
    /**********************************************************************************************************/

    //Верхняя область для изменения размера
    /**********************************************************************************************************/
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.rightMargin: 7
        anchors.leftMargin: 7
        height: 5
        color: "#d1d1d1"

        MouseArea {
            id: topMouseScopeCanv
            anchors.fill: parent
            cursorShape: rootRect.activeFocusOnWindow ? Qt.SizeVerCursor : Qt.ArrowCursor
            property double clickPosTop

            onPressed: {
                if(rootRect.activeFocusOnWindow) {
                    clickPosTop = topMouseScopeCanv.mouseY
                }
            }

            onPositionChanged: {
                if(rootRect.activeFocusOnWindow) {

                    let delta = topMouseScopeCanv.mouseY - clickPosTop

                    if(delta > 0) {
                        if((rootRect.height - delta) > 300) {
                            rootRect.height -= delta
                            rootRect.y += delta
                        } else {
                            delta = rootRect.height - 300
                            rootRect.height -= delta
                            rootRect.y += delta
                        }
                    } else if(delta < 0) {
                        if(-delta < rootRect.y) {
                            rootRect.height -= delta
                            rootRect.y += delta
                        } else {
                            delta = rootRect.y
                            rootRect.height += delta
                            rootRect.y -= delta
                        }
                    }
                }
            }
        }
    }
    /**********************************************************************************************************/

    //Правая область для изменения размера
    /**********************************************************************************************************/
    Rectangle {
        anchors.top: rectTopBorder.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 2
        anchors.topMargin: 7
        anchors.bottomMargin: 7
        width: 5

        MouseArea {
            id: rightMouseScopeCanv
            anchors.fill: parent
            cursorShape: rootRect.activeFocusOnWindow ? Qt.SizeHorCursor : Qt.ArrowCursor
            property double clickPosRight

            onPressed: {
                if(rootRect.activeFocusOnWindow) {
                    clickPosRight = rightMouseScopeCanv.mouseX
                }
            }

            onPositionChanged: {
                if(rootRect.activeFocusOnWindow) {

                    let delta = rightMouseScopeCanv.mouseX - clickPosRight

                    if(delta > 0) {
                        if(delta < (backgroundRectangle.width - rootRect.x - rootRect.width)) {
                            rootRect.width += delta
                        } else {
                            delta = backgroundRectangle.width - rootRect.x - rootRect.width
                            rootRect.width += delta
                        }
                    } else if (delta < 0) {
                        if((rootRect.width + delta) > 677) {
                            rootRect.width += delta
                        } else {
                            delta = 677 - rootRect.width
                            rootRect.width += delta
                        }
                    }
                }
            }
        }
    }
    /**********************************************************************************************************/

    //Левая область для изменения размера
    /**********************************************************************************************************/
    Rectangle {
        anchors.top: rectTopBorder.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 2
        anchors.topMargin: 7
        anchors.bottomMargin: 7
        width: 5

        MouseArea {
            id: leftMouseScopeCanv
            anchors.fill: parent
            cursorShape: rootRect.activeFocusOnWindow ? Qt.SizeHorCursor : Qt.ArrowCursor
            property double clickPosLeft

            onPressed: {
                if(rootRect.activeFocusOnWindow) {
                    clickPosLeft = leftMouseScopeCanv.mouseX
                }
            }

            onPositionChanged: {
                if(rootRect.activeFocusOnWindow) {

                    let delta = leftMouseScopeCanv.mouseX - clickPosLeft

                    if(delta > 0) {
                        if((rootRect.width - delta) > 677) {
                            rootRect.width -= delta
                            rootRect.x += delta
                        } else {
                            delta = rootRect.width - 677
                            rootRect.width -= delta
                            rootRect.x += delta
                        }
                    } else if(delta < 0) {
                        if(-delta < rootRect.x) {
                            rootRect.width -= delta
                            rootRect.x += delta
                        } else {
                            delta = rootRect.x
                            rootRect.width += delta
                            rootRect.x -= delta
                        }
                    }
                }
            }
        }
    }
    /**********************************************************************************************************/

    //Верхний левый угол для изменения размера
    /**********************************************************************************************************/
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 2
        anchors.topMargin: 2
        radius: 2
        width: 7
        height: 7
        color: "#d1d1d1"

        MouseArea {
            id: topLeftMouseScopeCanv
            anchors.fill: parent
            cursorShape: rootRect.activeFocusOnWindow ? Qt.SizeFDiagCursor : Qt.ArrowCursor
            property double clickPosTop
            property double clickPosLeft

            onPressed: {
                if(rootRect.activeFocusOnWindow) {
                    clickPosLeft = topLeftMouseScopeCanv.mouseX
                    clickPosTop = topLeftMouseScopeCanv.mouseY
                }
            }

            onPositionChanged: {
                if(rootRect.activeFocusOnWindow) {
                    let deltaY = topLeftMouseScopeCanv.mouseY - clickPosTop

                    if(deltaY > 0) {
                        if((rootRect.height - deltaY) > 300) {
                            rootRect.height -= deltaY
                            rootRect.y += deltaY
                        } else {
                            deltaY = rootRect.height - 300
                            rootRect.height -= deltaY
                            rootRect.y += deltaY
                        }
                    } else if(deltaY < 0) {
                        if(-deltaY < rootRect.y) {
                            rootRect.height -= deltaY
                            rootRect.y += deltaY
                        } else {
                            deltaY = rootRect.y
                            rootRect.height += deltaY
                            rootRect.y -= deltaY
                        }
                    }

                    let deltaX = topLeftMouseScopeCanv.mouseX - clickPosLeft

                    if(deltaX > 0) {
                        if((rootRect.width - deltaX) > 677) {
                            rootRect.width -= deltaX
                            rootRect.x += deltaX
                        } else {
                            deltaX = rootRect.width - 677
                            rootRect.width -= deltaX
                            rootRect.x += deltaX
                        }
                    } else if(deltaX < 0) {
                        if(-deltaX < rootRect.x) {
                            rootRect.width -= deltaX
                            rootRect.x += deltaX
                        } else {
                            deltaX = rootRect.x
                            rootRect.width += deltaX
                            rootRect.x -= deltaX
                        }
                    }
                }
            }
        }
    }
    /**********************************************************************************************************/

    //Верхний правый угол для изменения размера
    /**********************************************************************************************************/
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 2
        anchors.topMargin: 2
        radius: 2
        width: 7
        height: 7
        color: "#d1d1d1"

        MouseArea {
            id: topRightMouseScopeCanv
            anchors.fill: parent
            cursorShape: rootRect.activeFocusOnWindow ? Qt.SizeBDiagCursor : Qt.ArrowCursor
            property double clickPosTop
            property double clickPosRight

            onPressed: {
                if(rootRect.activeFocusOnWindow) {
                    clickPosRight = topLeftMouseScopeCanv.mouseX
                    clickPosTop = topLeftMouseScopeCanv.mouseY
                }
            }

            onPositionChanged: {
                if(rootRect.activeFocusOnWindow) {
                    let deltaY = topRightMouseScopeCanv.mouseY - clickPosTop

                    if(deltaY > 0) {
                        if((rootRect.height - deltaY) > 300) {
                            rootRect.height -= deltaY
                            rootRect.y += deltaY
                        } else {
                            deltaY = rootRect.height - 300
                            rootRect.height -= deltaY
                            rootRect.y += deltaY
                        }
                    } else if(deltaY < 0) {
                        if(-deltaY < rootRect.y) {
                            rootRect.height -= deltaY
                            rootRect.y += deltaY
                        } else {
                            deltaY = rootRect.y
                            rootRect.height += deltaY
                            rootRect.y -= deltaY
                        }
                    }

                    let deltaX = topRightMouseScopeCanv.mouseX - clickPosRight

                    if(deltaX > 0) {
                        if(deltaX < (backgroundRectangle.width - rootRect.x - rootRect.width)) {
                            rootRect.width += deltaX
                        } else {
                            deltaX = backgroundRectangle.width - rootRect.x - rootRect.width
                            rootRect.width += deltaX
                        }
                    } else if (deltaX < 0) {
                        if((rootRect.width + deltaX) > 677) {
                            rootRect.width += deltaX
                        } else {
                            deltaX = 677 - rootRect.width
                            rootRect.width += deltaX
                        }
                    }
                }
            }
        }
    }
    /**********************************************************************************************************/

    //Нижний левый угол для изменения размера
    /**********************************************************************************************************/
    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 2
        anchors.bottomMargin: 2
        radius: 2
        width: 7
        height: 7

        MouseArea {
            id: bottomLeftMouseScopeCanv
            anchors.fill: parent
            cursorShape: rootRect.activeFocusOnWindow ? Qt.SizeBDiagCursor : Qt.ArrowCursor
            property double clickPosBottom
            property double clickPosLeft

            onPressed: {
                if(rootRect.activeFocusOnWindow) {
                    clickPosLeft = topLeftMouseScopeCanv.mouseX
                    clickPosBottom = topLeftMouseScopeCanv.mouseY
                }
            }

            onPositionChanged: {
                if(rootRect.activeFocusOnWindow) {
                    let deltaX = bottomLeftMouseScopeCanv.mouseX - clickPosLeft

                    if(deltaX > 0) {
                        if((rootRect.width - deltaX) > 677) {
                            rootRect.width -= deltaX
                            rootRect.x += deltaX
                        } else {
                            deltaX = rootRect.width - 677
                            rootRect.width -= deltaX
                            rootRect.x += deltaX
                        }
                    } else if(deltaX < 0) {
                        if(-deltaX < rootRect.x) {
                            rootRect.width -= deltaX
                            rootRect.x += deltaX
                        } else {
                            deltaX = rootRect.x
                            rootRect.width += deltaX
                            rootRect.x -= deltaX
                        }
                    }

                    let deltaY = bottomLeftMouseScopeCanv.mouseY - clickPosBottom
                    if(deltaY > 0) {

                        if(deltaY < (backgroundRectangle.height - (rootRect.height + rootRect.y))) {
                            rootRect.height += deltaY

                        } else {
                            deltaY = (backgroundRectangle.height - rootRect.y) - rootRect.height
                            rootRect.height += deltaY
                        }

                    } else if(deltaY < 0) {

                        if((rootRect.height + deltaY) > 360) {
                            rootRect.height += deltaY
                        } else {
                            deltaY = 360 - rootRect.height
                            rootRect.height += deltaY
                        }
                    }
                }
            }
        }
    }
    /**********************************************************************************************************/

    //Нижний правый угол для изменения размера
    /**********************************************************************************************************/
    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 2
        anchors.bottomMargin: 2
        radius: 2
        width: 7
        height: 7

        MouseArea {
            id: bottomRightMouseScopeCanv
            anchors.fill: parent
            cursorShape: rootRect .activeFocusOnWindow ? Qt.SizeFDiagCursor : Qt.ArrowCursor
            property double clickPosBottom
            property double clickPosRight

            onPressed: {
                if(rootRect.activeFocusOnWindow) {
                    clickPosRight = topLeftMouseScopeCanv.mouseX
                    clickPosBottom = topLeftMouseScopeCanv.mouseY
                }
            }

            onPositionChanged: {
                let deltaX = bottomRightMouseScopeCanv.mouseX - clickPosRight

                if(deltaX > 0) {
                    if(deltaX < (backgroundRectangle.width - rootRect.x - rootRect.width)) {
                        rootRect.width += deltaX
                    } else {
                        deltaX = backgroundRectangle.width - rootRect.x - rootRect.width
                        rootRect.width += deltaX
                    }
                } else if (deltaX < 0) {
                    if((rootRect.width + deltaX) > 677) {
                        rootRect.width += deltaX
                    } else {
                        deltaX = 677 - rootRect.width
                        rootRect.width += deltaX
                    }
                }

                let deltaY = bottomRightMouseScopeCanv.mouseY - clickPosBottom
                if(deltaY > 0) {

                    if(deltaY < (backgroundRectangle.height - (rootRect.height + rootRect.y))) {
                        rootRect.height += deltaY

                    } else {
                        deltaY = (backgroundRectangle.height - rootRect.y) - rootRect.height
                        rootRect.height += deltaY
                    }

                } else if(deltaY < 0) {

                    if((rootRect.height + deltaY) > 360) {
                        rootRect.height += deltaY
                    } else {
                        deltaY = 360 - rootRect.height
                        rootRect.height += deltaY
                    }
                }
            }
        }
    }
    /**********************************************************************************************************/
}

