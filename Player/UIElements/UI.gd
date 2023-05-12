extends Control
var UI = true
var captureMouse = true
var inventory = false
var gamePaused = false
var playerDeath = false
@onready var network = get_node("/root/Networking")
@onready var playerGlobals = get_node("/root/PlayerStats")
# Called when the node enters the scene tree for the first time.
func _ready():
	playerDeath = false
	playerGlobals.connect("barChange",_on_player_bar_change)
	playerGlobals.connect("playerDeath", _on_player_death)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and inventory == false or playerDeath == true:
		captureMouse = !captureMouse
	if captureMouse == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif captureMouse == false: 
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if inventory == true:
		captureMouse = false
		get_node("Crosshair").visible = false
	else:
		captureMouse = true
		get_node("Crosshair").visible = true
	if playerDeath == true:
		get_node("DeathScreen").visible = true
		get_node("Label").visible = true
	else:
		get_node("DeathScreen").visible = false
		get_node("Label").visible = false
func _on_pause_menu_game_pause():
	gamePaused = true


func _on_tab_container_inventory_open(_object):
	inventory = !inventory




func _on_player_bar_change(key, value):
	if key == "stamina":
		get_node("QuickBar/VBoxContainer/Staminabar").value = value
	elif key == "health":
		get_node("QuickBar/VBoxContainer/Healthbar").value = value


func _on_player_death():
	playerDeath = true


func _on_connect_pressed():
	network._connectServer(get_node("IPBOX").text, int(get_node("PORT").text))
	print(multiplayer.get_unique_id())


func _on_host_pressed():
	network._hostServer(get_node("PORT").text)
