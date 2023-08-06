extends Node
@onready var playerName = null
@onready var playerPath = null
@onready var spawnPoint = null
@onready var UI = null
@onready var globalDelta = 0
var inventoryOpen = false
var gameStarted = false
var spawners = [
	
]
var nickname=""
signal barChange(key, value)
signal respawnPlayer()
signal playerDeath()
signal enterVehicle(state, id)
signal debug (string)
signal initialSpawn()
signal itemPickedUp(object,id)
signal itemDropped(object,grid)
signal dropItem(index,grid, idFlag)
signal equipItem(objectID)
signal itemUsed(object)
signal invRestack(object)
signal readyForSpawn()
signal mainMenu()
signal updateItem()
signal openChest(chest)
signal eatFood(amount)
signal drinkLiquid(amount)
func _ready():
	multiplayer.peer_connected.connect(playerConnected)
func _process(delta):
	if spawnPoint == null and gameStarted == true:
		findSpawn()
	globalDelta = delta
	if playerName == null and gameStarted == true:
		for i in $"../Overworld".get_children():
			if not i.get("playerStats") == null and str(i.get("peerID")) == str(multiplayer.get_unique_id()):
				playerName=i
				playerPath=i.get_path()
	if UI == null and gameStarted == true and playerName != null:
		for i in $"../Overworld".get_children():
			if not i.get("UI") == null:
				UI = i
	if spawnPoint != null and gameStarted == true and playerName == null:
		initialSpawn.emit()
func playerConnected(id):
	if multiplayer.is_server():
		findSpawn(id)
@rpc("any_peer","call_local")
func _setSpawn(vector):
	spawnPoint = vector
	if !multiplayer.is_server():
		readyForSpawn.emit()

func findSpawn(id:=1):
	for i in $"../Overworld".get_children():
		if i.has_meta("Spawn") and i.get_meta("PlayerID") == 0:
				i.set_meta("PlayerID", multiplayer.get_unique_id())
				rpc_id(id,"_setSpawn", i.get_global_position())
				break
