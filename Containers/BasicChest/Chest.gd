extends RigidBody3D
var limit = 100.0
var Inventory = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@rpc("any_peer","call_local")
func addItem(ref,stats,props):
	pass
	
@rpc("any_peer","call_local")
func removeItem(index):
	pass
