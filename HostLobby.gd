extends Control
@onready var mp = $"/root/Networking"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.visible == true:
		$PlayerList.clear()
		for i in mp.playerList.size():
			$PlayerList.add_item(str(i))


func _on_cancel_pressed():
	self.visible = false
	$"../MainMenu".visible = true

func _on_visibility_changed():
	if self.visible == true:
		mp.hostServer(mp.defaultPort)
		pass
	else:
		mp.peer.close()


func _on_player_name_pressed():
	pass # Replace with function body.
