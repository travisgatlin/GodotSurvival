extends Control
var localPlayerinfo = {
	"Name": "Host",
}
var incomingPlayerID = null
@onready var mp = $"/root/Networking"

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_playerConnected)
	#multiplayer.peer_disconnected.connect(playerDisconnected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#print(mp.connectedPlayers)
	pass


func _on_cancel_pressed():
	self.visible = false
	$"../MainMenu".visible = true
	mp.peer.close()

func _on_visibility_changed():
	if self.visible == true:
		mp.hostServer(mp.defaultPort)
#		localPlayerinfo["id"] = multiplayer.get_unique_id()
#		rpc("registerPlayer",localPlayerinfo)
		return


func _on_player_name_pressed():
	localPlayerinfo["Name"] = $"NameEdit".get_text()
	#print (localPlayerinfo)

func _on_start_pressed():
	$"../MainMenu/Menu".startGame()

func _playerConnected(id):
	incomingPlayerID = id
	#print (incomingPlayerID)
@rpc("any_peer")
func registerPlayer(info):
	info["id"] = incomingPlayerID
	mp.connectedPlayers.append(info)
	$"PlayerList".clear()
	for i in mp.connectedPlayers.size():
		$"PlayerList".add_item(str(info["Name"]))
		print (mp.connectedPlayers)
