extends Control
var UI = true
var inventory = false
var initialInventoryGen = false
var mouseVisible = false
var gamePaused = false
var playerDeath = false
var inventoryUpdate = false
var entry = preload("res://Player/Inventory Item Base.tscn")
var totalInventory = null
@onready var network = $"/root/Networking"
@onready var playerGlobals = $"/root/PlayerStats"
@onready var inventoryGrid = $"PlayerInventory/Inventory/Main/InvScroll/MainInv"
@onready var hotbar = $"QuickBar/VBoxContainer/Items"
# Called when the node enters the scene tree for the first time.
func _ready():
	playerDeath = false
	initialInventoryGen = false
	playerGlobals.connect("debug",_debugbox)
	playerGlobals.connect("itemPickedUp", addInventory)
	playerGlobals.connect("itemDropped", removeFromInventory)
	playerGlobals.connect("barChange",_on_player_bar_change)
	playerGlobals.connect("playerDeath", _on_player_death)
	playerGlobals.connect("invRestack", addInventory)
	multiplayer.server_disconnected.connect(lostConnection)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	totalInventory = inventoryGrid.get_children()+hotbar.get_children()
	encumberanceCounter()
	if Input.is_action_just_pressed("Inventory"):
		openInventory()
	if mouseVisible == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if playerDeath == true:
		$"DeathScreen".visible = true
		$"Label".visible = true
	else:
		$"DeathScreen".visible = false
		$"Label".visible = false
func _on_pause_menu_game_pause():
	gamePaused = !gamePaused
	if gamePaused == true:
		mouseVisible = true
		$"Pause Menu".visible = true
		$"Suicide".visible = true
		get_tree().paused = true
	if gamePaused == false:
		mouseVisible = false
		$"Pause Menu".visible = false
		$"Suicide".visible = false
		get_tree().paused = false



func _on_player_bar_change(key, value):
	if key == "stamina":
		$"QuickBar/VBoxContainer/Staminabar".value = value
	elif key == "health":
		$"QuickBar/VBoxContainer/Healthbar".value = value


func _on_player_death():
	mouseVisible = true
	playerDeath = true

func _debugbox(string):
	$"Debug".text = string

func openInventory():
	inventory = !inventory
	if inventory == true:
		$"Crosshair".visible = false
		$"PlayerInventory".visible = true
		mouseVisible = true
		playerGlobals.inventoryOpen = true
	else:
		$"Crosshair".visible = true
		mouseVisible = false
		$"PlayerInventory".visible = false
		playerGlobals.inventoryOpen = false

func addInventory(object,id,grid:=$"PlayerInventory/Inventory/Main/InvScroll/MainInv"):
	var stackIndex = objectStackExists(object.itemProps)
	if stackIndex == null or object.itemStats["Stackable"] == false:
		var inventoryEntry = entry.instantiate()
		inventoryEntry.setup(object,id)
		inventoryEntry.set_name(object.itemStats["ItemName"])
		grid.add_child(inventoryEntry)
	else:
		totalInventory[stackIndex].stackAdd(object)

func amountInStack(array,id):
	var amount = 0
	for i in array.size():
		if array[i].itemStats["id"] == id:
			amount+=1
	return amount
	
func objectStackExists(props):
	var exists = null
	for i in totalInventory.size():
		if totalInventory[i].stack[0].itemProps != props:
			exists = null
		else:
			return i
		#print (inventoryEntries[i].shouldBeInStack(props))
	return exists
	
func removeFromInventory(object,_grid):
	for i in totalInventory.size():
		if totalInventory[i].stack[0].itemStats["id"] == object.itemStats["id"]:
			if object.itemStats["Stackable"] == true:
				totalInventory[i].stackRemove()
			else:
				totalInventory[i].stackRemove()
				break
func encumberanceCounter():
	var player = playerGlobals.playerName
	$"PlayerInventory/Inventory/Encumberance".text = (str(player.playerStats["equipWeight"])+"/"+ str(player.playerStats["maxWeight"]))

func lostConnection():
	$"LostConnection".visible = true
	await get_tree().create_timer(5).timeout
	playerGlobals.emit_signal("mainMenu")
