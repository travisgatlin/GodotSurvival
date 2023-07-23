extends ItemList
@onready var playerGlobals = $/root/PlayerStats
@onready var mp = $"/root/Networking"
signal percentage(percent)
signal spawnReady()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_item_activated(index):
	if index == 0:
		mp.startGame()
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
