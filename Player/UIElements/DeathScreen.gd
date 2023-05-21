extends ItemList
signal playerRespawn()
@onready var playerGlobals = get_node("/root/PlayerStats")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_item_activated(index):
	if index == 0:
		#self.set("item_0/disabled", true)
		playerGlobals.emit_signal("respawnPlayer")
	elif index == 1:
		get_tree().quit()
	elif index == 2:
		get_tree().quit()
