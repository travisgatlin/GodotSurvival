extends ItemList
@onready var playerGlobals = $/root/PlayerStats
signal percentage(percent)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_item_activated(index):
	if index == 0:
		startGame()
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


func startGame(name:="Player"):
	$"../../LoadingScreen".visible= true
	ResourceLoader.load_threaded_request("res://overworld.tscn","",true,ResourceLoader.CACHE_MODE_REUSE)
	#var loadStatus = ResourceLoader.load_threaded_get_status("res://overworld.tscn")
	var levelResource = ResourceLoader.load_threaded_get("res://overworld.tscn")
	var level = levelResource.instantiate()
	playerGlobals.gameStarted = true
	get_node("/root").add_child(level,true)
	get_node("/root/Menu").queue_free()
