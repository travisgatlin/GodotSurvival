extends Node3D
var mouseVisible = false
var playerDead = false
func _on_player_player_dead():
	playerDead = !playerDead
# Called when the node enters the scene tree for the first time.
func _ready():
	transform.basis = Basis()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	var lookSensitivity = 0.003
	var lookInverted = -1
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouseVisible = false
	else:
		mouseVisible = true
		
	if event is InputEventMouseMotion and mouseVisible == false and playerDead == false:
		rotate(Vector3(0,1,0), event.relative.x * lookSensitivity * lookInverted)
		get_node("Camera3D").rotate_object_local(Vector3(1,0,0), event.relative.y * lookSensitivity * lookInverted)
	
