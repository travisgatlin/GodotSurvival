extends Node
enum inventoryDrop {DONT_DROP,DROP_EVERYTHING,KEEP_HOTBAR}
@export var mouseCapture = false
#in seconds
var buttonHoldTime = 1.0
func _process(_delta):
	if mouseCapture == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
