# First, import the library.
import nigui

# Initialization is mandatory.
app.init()

# Create a window with a given title:
# By default, a window is empty and not visible.
# It is played at the center of the screen.
# A window can contain only one control.
# A container can contain multiple controls.
var window = newWindow("ImageN")


window.width = 600.scaleToDpi
window.height = 50.scaleToDpi

# Create a container for controls.
# By default, a container is empty.
# Its size will adapt to its child's controls.
# A LayoutContainer will automatically align the child controls.
var container = newLayoutContainer(Layout_Horizontal)

# Add the container to the window.
window.add(container)

# Create a button with a given title.
var button_rectangle = newButton("Rectangle")

# Add the button to the container.
container.add(button_rectangle)

var button_oval = newButton("Oval")
container.add(button_oval)


# var button_polygon = newButton("Polygon")
# container.add(button_polygon)
# 
# var button_freehand = newButton("Freehand")
# container.add(button_freehand)
# 
# var button_line = newButton("Line")
# container.add(button_line)
# 
# var button_angle = newButton("Angle")
# container.add(button_angle)
# 
# var button_multipoint = newButton("Multi-point")
# container.add(button_multipoint)
# 
# var button_wand = newButton("Wand")
# container.add(button_wand)
# 
# var button_text = newButton("Text")
# container.add(button_text)


# var button_open = newButton("Open...")




# Make the window visible on the screen.
# Controls (containers, buttons, ..) are visible by default.
window.show()

# At last, run the main loop.
# This processes incoming events until the application quits.
# To quit the application, dispose all windows or call "app.quit()".
app.run()




