extends GridContainer
@onready var playerGlobals = $"/root/PlayerStats" 
var chest = null
# Called when the node enters the scene tree for the first time.
func _ready():
	playerGlobals.connect("openChest",chestInv)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _can_drop_data(_at_position, _data):
	return true

func _drop_data(_at_position, data):
	var old = data.get_parent()
	old.remove_child(data)
	self.add_child(data)

func chestInv(chest):
	pass
