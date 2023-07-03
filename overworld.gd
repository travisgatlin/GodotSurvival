extends Node3D
@export var player = preload("res://Player/player.tscn")
@export var UI = preload("res://Player/UIElements/ui.tscn")
@export var peer = preload("res://Player/MultiplayerPeer.tscn")
@onready var playerGlobals = $"/root/PlayerStats"
@onready var mp = $"/root/Networking"
# Called when the node enters the scene tree for the first time.
func _ready():
	playerGlobals.connect("respawnPlayer", _on_ui_respawn_player)
	playerGlobals.connect("initialSpawn", localPlayerInitSpawn)
	playerGlobals.connect("mainMenu", mainMenu)

func _process(_delta):
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

