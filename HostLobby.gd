extends Control
var localPlayerinfo = {
	"Name": "Host",
	}
@onready var mp = $"/root/Networking"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#print(mp.connectedPlayers)
	pass


func _on_cancel_pressed():
	self.visible = false
	$"../MainMenu".visible = true

func _on_visibility_changed():
	if self.visible == true:
#		localPlayerinfo["id"] = multiplayer.get_unique_id()
#		rpc("registerPlayer",localPlayerinfo)
		return

func _on_start_pressed():
	if $"Panel/VBoxContainer/HBoxContainer/PortOverride".button_pressed == true:
		mp.hostServer(int($"Panel/VBoxContainer/HBoxContainer/Port".text),int($"Panel/VBoxContainer/Players/PlayerCount".text))
	else: 
		mp.hostServer(mp.defaultPort,int($"Panel/VBoxContainer/Players/PlayerCount".text))
	if multiplayer.is_server():
		mp.startGame($"Panel/VBoxContainer/FlowContainer/NameEdit".get_text())

func _on_player_slider_value_changed(value):
	$"Panel/VBoxContainer/Players/PlayerCount".set("text", int(value))
	$"Panel/VBoxContainer/Warning".visible = false


func _on_player_count_text_changed(new_text):
	var text = new_text
	if text.is_valid_int():
		$"Panel/VBoxContainer/Player Slider".set_value_no_signal(int(text))
		if int(text) > 4096:
			$"Panel/VBoxContainer/Players/PlayerCount".text = str(4096)
		if int(text) > 32:
			$"Panel/VBoxContainer/Warning".visible = true
		else:
			$"Panel/VBoxContainer/Warning".visible = false
	elif text == "":
		text = ""


func _on_port_override_toggled(button_pressed):
	if button_pressed == true:
		$"Panel/VBoxContainer/HBoxContainer/Port".visible = true
	else:
		$"Panel/VBoxContainer/HBoxContainer/Port".visible = false


func _on_hide_password_toggled(button_pressed):
	if button_pressed == true:
		$"Panel/VBoxContainer/Passwordbox/Password".secret = true
	else:
		$"Panel/VBoxContainer/Passwordbox/Password".secret = false
