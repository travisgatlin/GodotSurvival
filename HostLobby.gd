extends Control
@onready var mp = $"/root/Networking"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_cancel_pressed():
	self.visible = false
	$"../MainMenu".visible = true

func _on_visibility_changed():
	if self.visible == true:
		mp.hostServer(mp.defaultPort)
	else:
		mp.peer.close()
