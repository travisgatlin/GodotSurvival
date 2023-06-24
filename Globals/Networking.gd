extends Node
var peer = ENetMultiplayerPeer.new()
var defaultPort = 9090
var incomingPlayerID = null
var connectedPlayers = []
func _ready():
	multiplayer.peer_connected.connect(playerConnected)
	multiplayer.peer_disconnected.connect(playerDisconnected)
func _process(_delta):
	#for i in multiplayer.get_peers().size():
	pass


func hostServer(port):
	peer.create_server(int(port))
	multiplayer.multiplayer_peer = peer
	
	
func connectServer(ip, port):
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	
func playerConnected(id):
	incomingPlayerID = id
	#print("connected"+ " " + str(id))

func playerDisconnected(id):
	print("player " + str(id) + " has disconnected.")
