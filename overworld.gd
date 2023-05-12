extends Node3D
@export var player = preload("res://Player/player.tscn")
@export var UI = preload("res://Player/UIElements/ui.tscn")
@export var peer = preload("res://Enemies/test_person.tscn")
@onready var playerGlobals = get_node("../PlayerStats")
@onready var networking = get_node("/root/Networking")
# Called when the node enters the scene tree for the first time.
func _ready():
	playerGlobals.connect("respawnPlayer", _on_ui_respawn_player)
	var playerSpawn = player.instantiate()
	var uiSpawn = UI.instantiate()
	add_child(playerSpawn)
	add_child(uiSpawn)
	#networking.connect("playerConnected",_remotePlayerConnect)
	#multiplayer.peer_connected()

func _process(_delta):
	print(multiplayer.get_peers())


func _on_ui_respawn_player():
	playerGlobals.UI.queue_free()
	playerGlobals.playerName.queue_free()
	var playerSpawned = player.instantiate()
	var uiSpawn = UI.instantiate()
	playerSpawned.respawnSetup()
	add_child(playerSpawned)
	add_child(uiSpawn)


func _remotePlayerConnect():
	#var newPeer = peer.instantiate()
	print ("player connected!")
	
