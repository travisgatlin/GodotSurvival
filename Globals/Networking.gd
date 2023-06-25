extends Node
var peer = ENetMultiplayerPeer.new()
var defaultPort = 9090
var incomingPlayerID = null
var connectedPlayers = []
var isHost = false
func _ready():
	multiplayer.peer_connected.connect(playerConnected)
	multiplayer.peer_disconnected.connect(playerDisconnected)
func _process(_delta):
	#for i in multiplayer.get_peers().size():
	pass


func hostServer(port:int=defaultPort,maxPlayers:int=2):
	isHost = true
	peer.create_server(int(port),int(maxPlayers))
	multiplayer.multiplayer_peer = peer
	
	
func connectServer(ip, port):
	isHost = false
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	
func playerConnected(id):
	incomingPlayerID = id
	print("connected"+ " " + str(id))

func playerDisconnected(id):
	print("player " + str(id) + " has disconnected.")

#@rpc("any_peer")
#func registerPlayer(info):
#	info["id"] = incomingPlayerID
#	connectedPlayers.append(info)
#	$"PlayerList".clear()
#	for i in connectedPlayers.size():
#		$"PlayerList".add_item(str(info["Name"]))
