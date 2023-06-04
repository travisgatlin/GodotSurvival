extends Node3D
@export var player = preload("res://Player/player.tscn")
@export var UI = preload("res://Player/UIElements/ui.tscn")
@export var peer = preload("res://Enemies/DummyAnimated.glb")
@onready var playerGlobals = get_node("../PlayerStats")
@onready var networking = get_node("/root/Networking")
# Called when the node enters the scene tree for the first time.
func _ready():
	playerGlobals.connect("respawnPlayer", _on_ui_respawn_player)
	multiplayer.peer_connected.connect(spawnPlayers)
	multiplayer.peer_disconnected.connect(disconnected)
	playerGlobals.connect("initialSpawn", localPlayerInitSpawn)

func _process(_delta):
	#print(multiplayer.get_peers())
	pass

func _on_ui_respawn_player():
	playerGlobals.UI.queue_free()
	playerGlobals.playerName.queue_free()
	if !self.has_node(playerGlobals.playerPath):
		var playerSpawned = player.instantiate()
		var uiSpawn = UI.instantiate()
		playerSpawned.respawnSetup()
		#await get_tree().create_timer(0.1).timeout
		add_child(playerSpawned)
		add_child(uiSpawn)

func _remotePlayerConnect():
	#var newPeer = peer.instantiate()
	print ("player connected!")

func spawnPlayers(id: int):
	print (id)

func disconnected():
	print ("oh shit he gone")

func localPlayerInitSpawn():
	var playerSpawn = player.instantiate()
	var uiSpawn = UI.instantiate()
	add_child(playerSpawn)
	add_child(uiSpawn)
