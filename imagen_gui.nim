import streams
import os
import endians
import arraymancer
import nigui

app.init()

var window = newWindow()
var container = newLayoutContainer(Layout_Vertical)
window.add(container)

var control = newControl()
control.widthMode = WidthMode_Fill
control.heightMode = HeightMode_Fill
container.add(control)

var button = newButton("Next")
container.add(button)





