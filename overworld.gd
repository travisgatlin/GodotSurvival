extends Node3D
@export var player = preload("res://Player/player.tscn")
@export var UI = preload("res://Player/UIElements/ui.tscn")
@export var peer = preload("res://Player/MultiplayerPeer.tscn")
@onready var playerGlobals = $"/root/PlayerStats"
@onready var mp = $"/root/Networking"
@export var itemList = []
# Called when the node enters the scene tree for the first time.
func _ready():
	playerGlobals.connect("respawnPlayer", _on_ui_respawn_player)
	playerGlobals.connect("initialSpawn", localPlayerInitSpawn)
	playerGlobals.connect("mainMenu", mainMenu)
	multiplayer.peer_connected.connect(playerConnected)
func _process(_delta):
	pass

func playerConnected(id):
	pass

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
func itemSpawn(reference,objname,transform3d,stats:Dictionary,props:Dictionary, parent:=$"Items"):
	$"MultiplayerSpawner".add_spawnable_scene(reference)
	$"MultiplayerSpawner".set_spawn_path(parent.get_path())
	if multiplayer.is_server():
		var itemReference = load(reference)
		var itemToBeSpawned = itemReference.instantiate()
		itemToBeSpawned.name = objname
		itemToBeSpawned.itemStats = stats
		itemToBeSpawned.itemProps = props
		itemToBeSpawned.set_global_transform(transform3d)
		parent.add_child(itemToBeSpawned,true)

@rpc("call_local","reliable")
func peerSpawn(id,inventory,loc):
	var peerInstance = peer.instantiate()
	peerInstance.set("name",id)
	peerInstance.inventory = inventory
	peerInstance.set_global_position(loc)
	self.add_child(peerInstance)
 
func itemMPSync():
	pass

@rpc("any_peer","call_local")
func itemLocationSync(objectPath,transform3d):
	get_node(objectPath).set_global_transform(transform3d)

@rpc("any_peer","call_local")
func useObject(path):
	get_node(path).USE()
	playerGlobals.emit_signal("itemUsed", get_node(path))
