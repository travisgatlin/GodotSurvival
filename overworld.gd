extends Node3D
@export var player = preload("res://Player/player.tscn")
@export var UI = preload("res://Player/UIElements/ui.tscn")
@export var peer = preload("res://Player/MultiplayerPeer.tscn")
@onready var playerGlobals = $"/root/PlayerStats"
@onready var mp = $"/root/Networking"
@export var itemList = []
# Called when the node enters the scene tree for the first time.
func _ready():
	syncToHost()
	playerGlobals.connect("respawnPlayer", _on_ui_respawn_player)
	playerGlobals.connect("initialSpawn", localPlayerInitSpawn)
	playerGlobals.connect("mainMenu", mainMenu)
	multiplayer.peer_connected.connect(playerConnected)

func _process(_delta):
	pass

func playerConnected(id):
	worldSync.rpc(itemList)

@rpc("authority","call_remote")
func worldSync(list):
	itemList = list

func syncToHost():
	if !multiplayer.is_server():
		var worldItems = $"Items".get_children()
		for i in worldItems.size():
			worldItems[i].queue_free()
		for i in itemList.size():
			var spawnableItem = itemList[i]
			itemSpawn.rpc(spawnableItem[0],spawnableItem[1],spawnableItem[2],spawnableItem[3],spawnableItem[4])
	else:
		var worldItems = $"Items".get_children()
		for i in worldItems.size():
			var objectDescription = [worldItems[i].reference,worldItems[i].name, worldItems[i].get_global_transform(),worldItems[i].itemStats,worldItems[i].itemProps]
			itemList.append(objectDescription)

func _on_ui_respawn_player():
	playerGlobals.UI.queue_free()
	playerGlobals.playerName.queue_free()
	if !self.has_node(playerGlobals.playerPath):
		var playerSpawned = player.instantiate()
		var uiSpawn = UI.instantiate()
		playerSpawned.respawnSetup()
		await get_tree().create_timer(0.1).timeout
		add_child(playerSpawned)
		add_child(uiSpawn)

func localPlayerInitSpawn():
	var playerSpawn = player.instantiate()
	var uiSpawn = UI.instantiate()
	add_child(playerSpawn)
	add_child(uiSpawn)

func mainMenu():
	var menu = load("res://Main Menu.tscn")
	var newMenu = menu.instantiate()
	$"/root".add_child(newMenu)
	playerGlobals.gameStarted = false
	self.queue_free()

@rpc("any_peer","reliable","call_local")
func itemSpawn(reference,objname,transform3d,stats:Dictionary,props:Dictionary):
	print("test")
	$"MultiplayerSpawner".add_spawnable_scene(reference)
	$"MultiplayerSpawner".set_spawn_path($"Items".get_path())
	if multiplayer.is_server():
		var itemReference = load(reference)
		var itemToBeSpawned = itemReference.instantiate()
		itemToBeSpawned.name = objname
		itemToBeSpawned.itemStats = stats
		itemToBeSpawned.itemProps = props
		itemToBeSpawned.set_global_transform(transform3d)
		$"Items".add_child(itemToBeSpawned,true)

@rpc("call_local","reliable")
func peerSpawn(id,inventory,loc):
	if multiplayer.is_server():
		var peerInstance = peer.instantiate()
		peerInstance.set("name",id)
		peerInstance.inventory = inventory
		peerInstance.set_global_transform(loc)
		self.add_child(peerInstance)
