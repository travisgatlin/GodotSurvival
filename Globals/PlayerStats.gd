extends Node
@onready var playerName = null
@onready var playerPath = null
@onready var spawnPoint = null
@onready var UI = null
@onready var globalDelta = 0
var inventoryOpen = false
var gameStarted = false
signal barChange(key, value)
signal respawnPlayer()
signal playerDeath()
signal enterVehicle(state, id)
signal debug (string)
signal initialSpawn()
signal itemPickedUp(object)
signal itemDropped(object,grid)
signal dropItem(index,grid, idFlag)
signal equipItem(objectID)
signal itemUsed(object)
signal invUpdate(oldId,newObject)
func _ready():
	pass
func _process(delta):
	if spawnPoint == null and gameStarted == true:
		for i in get_node("../Overworld").get_children():
			if i.has_meta("Spawn"):
				_setSpawn(i)
	globalDelta = delta
	if playerName == null and gameStarted == true:
		for i in get_node("../Overworld").get_children():
			if not i.get("playerStats") == null:
				playerName=i
				playerPath=i.get_path()
	if UI == null and gameStarted == true and playerName != null:
		for i in get_node("../Overworld").get_children():
			if not i.get("UI") == null:
				UI = i
	if spawnPoint != null and gameStarted == true and playerName == null:
		initialSpawn.emit()
func _setSpawn(object):
	spawnPoint = object.get_global_position()
