import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Shapes

Rectangle {
    id: rootRect
    width: 677
    height: 300
    color: "#d1d1d1"
    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 3
        verticalOffset: 3
        radius: 5
        color: "#80000000"
    }
    border.color: "#d1d1d1"
    radius: 5
    Drag.active: mouseRectCanvas.drag.active

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
    }

    Rectangle {
        id: rectCanv
        width: 650
        height: 273
        clip: true
        radius: 5
        //color: "#d1d1d1"
        anchors.centerIn: parent

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
}

