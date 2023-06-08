extends Camera3D
var playerDead = false
@onready var playerGlobals = get_node("/root/PlayerStats")


func _ready():
	playerGlobals.connect("playerDeath",_on_player_death)
	transform.basis = Basis() 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$"../../BodyCollision2".rotation.y = self.get_global_rotation().y

func _input(event):
	#print (self.get_rotation())
	var lookSensitivity = 0.003
	var lookInverted = -1
	if event is InputEventMouseMotion and playerDead == false and playerGlobals.inventoryOpen == false:
		rotate(Vector3(0,1,0), event.relative.x * lookSensitivity * lookInverted)
		self.rotate_object_local(Vector3(1,0,0), event.relative.y * lookSensitivity * lookInverted)
		$"../DummyAnimated".rotation.y = self.rotation.y
#	if event is InputEventJoypadMotion:
#		var rotateRate = 1
#		var currentDirection = transform.basis
#		var rotateVector = Input.get_vector("LookDown","LookUp","LookRight","LookLeft").normalized()
#		rotate(Vector3(0,rotateVector.y,0), rotateVector.slerp(Vector2(0,0), 0.1).x)
#		print (rotateVector)
func _on_player_death():
	playerDead = true
