extends Node
var peer = ENetMultiplayerPeer.new()
var defaultPort = 9090
var incomingPlayerID = null
@onready var peerList = multiplayer.get_peers()
var connectedPlayers = []
var isHost = false
var peerInstance = null
var PeerModel = preload("res://Player/MultiplayerPeer.tscn")

func _ready():
	multiplayer.peer_disconnected.connect(playerDisconnected)
	multiplayer.peer_connected.connect(playerConnected)
func _process(_delta):
	peerList = multiplayer.get_peers()


func hostServer(port:int=defaultPort,maxPlayers:int=2):
	isHost = true
	peer.create_server(int(port),int(maxPlayers))
	multiplayer.multiplayer_peer = peer
	
	
func connectServer(ip, port):
	isHost = false
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer

func playerDisconnected(id):
	print("player " + str(id) + " has disconnected.")
	deleteInstance(id)
	
func playerConnected(id):
	if multiplayer.is_server():
		spawnInstance(id)

@rpc("call_local","any_peer")
func spawnInstance(id):
	peerInstance = PeerModel.instantiate()
	peerInstance.set("name",id)
	$"/root/Overworld".add_child(peerInstance)
	var path = peerInstance.get_path()
	connectedPlayers.append([id,path])

@rpc("authority")
func deleteInstance(id):
	for i in connectedPlayers.size():
		var pathIndex = connectedPlayers[i]
		if pathIndex[0] == id:
			get_node(pathIndex[1]).queue_free()

