extends Node
@onready var playerName = null
@onready var playerPath = null
@onready var spawnPoint = null
@onready var UI = null
@onready var globalDelta = 0
signal barChange(key, value)
signal respawnPlayer()
signal playerDeath()
signal enterVehicle(state, id)
signal debug (string)
func _ready():
		if spawnPoint == null:
			for i in get_node("../Overworld").get_children():
				if i.has_meta("Spawn"):
					_setSpawn(i)
func _process(delta):
	globalDelta = delta
	if playerName == null:
		for i in get_node("../Overworld").get_children():
			if not i.get("playerStats") == null:
				playerName=i
				playerPath=i.get_path()
	if UI == null:
		for i in get_node("../Overworld").get_children():
			if not i.get("UI") == null:
				UI = i
		
func barPercent(number):
	pass

func _setSpawn(object):
	spawnPoint = object.get_global_position()
