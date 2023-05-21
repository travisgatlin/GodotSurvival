extends ItemList
@onready var playerGlobals = $/root/PlayerStats

# Called when the node enters the scene tree for the first time.
func _ready():
	print (playerGlobals.gameStarted)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_item_activated(index):
	if index == 0:
		var level = load("res://overworld.tscn").instantiate()
		playerGlobals.gameStarted = true
		get_node("/root").add_child(level)
		get_node("/root/Control").queue_free()
		print (playerGlobals.gameStarted)
	elif index == 1:
		pass
	elif index == 2:
		$"../../MainMenu".visible = false
		$"../../HostLobby".visible = true
	elif index == 3:
		$"../../MainMenu".visible = false
		$"../../PeerLobby".visible = true
	elif index == 4:
		pass
	elif index == 5:
		get_tree().quit()
