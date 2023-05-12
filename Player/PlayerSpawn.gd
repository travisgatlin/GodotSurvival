extends Node3D
@onready var spawnLocation = get_node(".").get_global_position()
var isPlayerSpawned = false
var spawnOnLoad = true
var spawnHealth = 100
var player = load("res://player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if spawnOnLoad == true and isPlayerSpawned == false: 
		isPlayerSpawned = true
		var playerInstance = player.instantiate()
		add_child(playerInstance)
		playerInstance.set_global_position(spawnLocation)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
