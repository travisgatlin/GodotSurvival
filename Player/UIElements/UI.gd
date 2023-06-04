extends Control
var UI = true
var captureMouse = true
var inventory = false
var initialInventoryGen = false
var gamePaused = false
var playerDeath = false
var inventoryUpdate = false
var entry = preload("res://Player/Inventory Item Base.tscn")
@onready var network = get_node("/root/Networking")
@onready var playerGlobals = get_node("/root/PlayerStats")
@onready var inventoryGrid = $"PlayerInventory/Inventory/Main/InvScroll/MainInv"
# Called when the node enters the scene tree for the first time.
func _ready():
	initialInventoryGen = false
	playerGlobals.connect("debug",_debugbox)
	playerGlobals.connect("itemPickedUp", addInventory)
	playerGlobals.connect("itemDropped", removeFromInventory)
	playerDeath = false
	playerGlobals.connect("barChange",_on_player_bar_change)
	playerGlobals.connect("playerDeath", _on_player_death)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	encumberanceCounter()
	if Input.is_action_just_pressed("Inventory"):
		generateInventory()
		openInventory()
	
	if captureMouse == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif captureMouse == false: 
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if playerDeath == true:
		get_node("DeathScreen").visible = true
		get_node("Label").visible = true
	else:
		get_node("DeathScreen").visible = false
		get_node("Label").visible = false
func _on_pause_menu_game_pause():
	gamePaused = true



func _on_player_bar_change(key, value):
	if key == "stamina":
		$"QuickBar/VBoxContainer/Staminabar".value = value
	elif key == "health":
		$"QuickBar/VBoxContainer/Healthbar".value = value


func _on_player_death():
	playerDeath = true
	captureMouse = false

func _debugbox(string):
	get_node("Debug").text = string

func openInventory():
	inventory = !inventory
	if inventory == true:
		captureMouse = false
		$"Crosshair".visible = false
		$"PlayerInventory".visible = true
		playerGlobals.inventoryOpen = true
	else:
		captureMouse = true
		$"Crosshair".visible = true
		$"PlayerInventory".visible = false
		playerGlobals.inventoryOpen = false

func addInventory(object):
	var player = playerGlobals.playerName
	var inv = player.inventory
	if initialInventoryGen == true:
		var stackExists = objectStackExists(inv, object.itemStats["id"])
		if stackExists == null:
			var inventoryEntry = entry.instantiate()
			inventoryEntry.itemDefinition(object.itemStats,object.itemProps)
			inventoryEntry.set_name(inventoryEntry.itemStats["ItemName"])
			inventoryGrid.add_child(inventoryEntry)
		else:
			stackExists.stackAdd()
	
func generateInventory():
	if initialInventoryGen == false or inventoryUpdate == true:
		var player = playerGlobals.playerName
		var inv = player.inventory
		for i in inv.size():
			var inventoryEntry = entry.instantiate()
			var stackExists = objectStackExists(inv, inv[i].itemStats["id"])
			inventoryEntry.set_name(inv[i].itemStats["ItemName"])
			if objectStackExists(inv, inv[i].itemStats["id"]) == null:
				inventoryEntry.itemDefinition(inv[i].itemStats, inv[i].itemProps)
				inventoryGrid.add_child(inventoryEntry)
			else:
					stackExists.stackAdd()
					inventoryEntry.queue_free()
	else:
		return
	initialInventoryGen = true

func amountInStack(array,id):
	var amount = 0
	var object = null
	for i in array.size():
		if array[i].itemStats["id"] == id:
			amount+=1
	return amount
	
func objectStackExists(array,id):
	var player = playerGlobals.playerName
	var inventoryEntries = inventoryGrid.get_children()
	for i in inventoryEntries.size():
		if inventoryEntries[i].itemStats["id"] == id:
			return inventoryEntries[i]
	return null
	
func removeFromInventory(object):
	var player = playerGlobals.playerName
	var inventoryEntries = inventoryGrid.get_children()
	for i in inventoryEntries.size():
		if inventoryEntries[i].itemStats["id"] == object.itemStats["id"]:
			inventoryEntries[i].stackRemove()


func encumberanceCounter():
	var player = playerGlobals.playerName
	$"PlayerInventory/Inventory/Encumberance".text = (str(player.playerStats["equipWeight"])+"/"+ str(player.playerStats["maxWeight"]))
