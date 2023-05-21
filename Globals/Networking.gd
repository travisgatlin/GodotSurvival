extends Node
var peer = ENetMultiplayerPeer.new()
var defaultPort = 9090
var playerList = []
func _ready():
	multiplayer.peer_connected.connect(playerConnected)
	multiplayer.peer_disconnected.connect(playerDisconnected)
func _process(_delta):
	pass
	#if multiplayer.peer_connected():
		#_onPlayerConnect()


func hostServer(port):
	peer.create_server(int(port))
	multiplayer.multiplayer_peer = peer
	
	
func connectServer(ip, port):
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	
func playerConnected(id):
	print("connected"+ " " + str(id))

func playerDisconnected(id):
	print("player " + str(id) + " has disconnected.")
