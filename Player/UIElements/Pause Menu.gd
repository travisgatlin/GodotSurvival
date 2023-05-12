extends ItemList
var isPaused = false
var selectItem = null
var inventoryOpen = false
@onready var playerGlobals = get_node("/root/PlayerStats")
signal gamePause()
# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = get_node(".").PROCESS_MODE_ALWAYS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("pause") and get_parent().playerDeath == false:
		gamePause.emit()
		isPaused = !isPaused
		
	if isPaused == true:
		get_node(".").visible = true
		get_node("../Suicide").visible = true
		get_tree().paused = true
	else: 
		get_node(".").visible = false
		get_tree().paused = false
		get_node("../Suicide").visible = false
	
	selectItem = get_item_at_position(get_global_mouse_position(), true)


func _on_item_activated(selectedItem):
	if selectedItem ==  1:
		isPaused = false
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
	get_node("../SaveLoad").visible = true
	get_node("../Exit").visible = true
	
	


func _on_exit_pressed():
	get_node("../SaveLoad").visible = false
	get_node("../Exit").visible = false
