extends Control
var remotePlayerInfo = {
	"Name": "Client",
}
@onready var mp = $"/root/Networking"
@onready var playerGlobals = $"/root/PlayerStats"
# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.connected_to_server.connect(connectedSuccessfully)
	multiplayer.connection_failed.connect(connectionFailed)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_cancel_pressed():
	$Panel/Vbox/Connection/LobbyLabel.visible = false
	self.visible = false
	$"../MainMenu".visible = true
	mp.peer.close()

func _on_join_pressed():
	$"Panel/Vbox/Connection/LobbyLabel".text = "Attempting to connect to host..."
	$"Panel/Vbox/Connection/LobbyLabel".visible = true
	remotePlayerInfo["Name"] = $"Panel/Vbox/Connection/NameEdit".get_text()
	if $"Panel/Vbox/Connection/NameEdit".get_text() != "":
		if $"Panel/Vbox/Connection/Port".get_text() == "":
			mp.connectServer($"Panel/Vbox/Connection/IP".text,mp.defaultPort)
		else:
			mp.connectServer($"Panel/Vbox/Connection/IP".text,int($"Panel/Vbox/Connection/Port".text))

func connectedSuccessfully():
	playerGlobals.connect("readyForSpawn",startGame)
	$"Panel/Vbox/Connection/LobbyLabel".text = "Synchronizing world with host..."
	$"Panel/Vbox/Connection/LobbyLabel".visible = true
func startGame():
	print("connected")
	#mp.disconnect("readyForSpawn",startGame)
	$"../MainMenu/Menu".startGame()
func connectionFailed():
	$"Panel/Vbox/Connection/LobbyLabel".visible = true
	$"Panel/Vbox/Connection/LobbyLabel".text = "Connection Failed. Please check your connection or try another IP."
	mp.peer.close()
