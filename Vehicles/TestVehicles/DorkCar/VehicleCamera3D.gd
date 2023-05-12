extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
func _input(event):
	var _lookSensitivity = 0.003
	var _lookInverted = -1
	if event is InputEventMouseMotion:
		pass
