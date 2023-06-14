extends ItemList
var isPaused = false
var selectItem = null
var inventoryOpen = false
@onready var playerGlobals = $"/root/PlayerStats"
signal gamePause()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("pause") and get_parent().playerDeath == false:
		gamePause.emit()
	
	selectItem = get_item_at_position(get_global_mouse_position(), true)


func _on_item_activated(selectedItem):
	if selectedItem ==  1:
		gamePause.emit()
	elif selectedItem == 2:
		print ("no options for you bitch")
	elif selectedItem == 3:
		saveLoadMenu()
	elif selectedItem == 4:
		get_tree().quit()
	


func _on_inventory_background_inventory_open():
	inventoryOpen = !inventoryOpen


func _on_suicide_pressed():
	isPaused = false
	var currentPlayer = playerGlobals.playerName
	currentPlayer.playerStats["health"] = 0

func saveLoadMenu():
	$"../SaveLoad".visible = true
	$"../Exit".visible = true


func _on_exit_pressed():
	get_node("../SaveLoad").visible = false
	get_node("../Exit").visible = false
