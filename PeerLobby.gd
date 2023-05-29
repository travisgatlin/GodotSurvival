extends Control
@onready var mp = $"/root/Networking"
# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.connected_to_server.connect(connectedSuccessfully)
	multiplayer.connection_failed.connect(connectionFailed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
		if self.visible == true:
			$PlayerList.clear()
			for i in mp.playerList.size():
				$PlayerList.add_item(str(i))


func _on_cancel_pressed():
	$LobbyLabel.visible = false
	self.visible = false
	$"../MainMenu".visible = true
	mp.peer.close()

func _on_join_pressed():
	$"LobbyLabel".text = "Attempting to connect to host..."
	$"LobbyLabel".visible = true
	if $"NameEdit".get_text() != "":
		if $"Port".get_text() == "":
			mp.connectServer($"IP".text,mp.defaultPort)
		else:
			mp.connectServer($"IP".text,int($"Port".text))

func connectedSuccessfully():
	$"LobbyLabel".text = "Waiting for host to begin game..."
	$"LobbyLabel".visible = true

func connectionFailed():
	$LobbyLabel.visible = true
	$"LobbyLabel".text = "Connection Failed. Please check your connection or try another IP."
	mp.peer.close()