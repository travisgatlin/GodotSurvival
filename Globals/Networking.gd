extends Node
var peer = ENetMultiplayerPeer.new()
var defaultPort = 9090
var incomingPlayerID = null
@onready var playerGlobals = $"/root/PlayerStats"
@onready var peerList = multiplayer.get_peers()
var connectedPlayers = []
var peerInstance = null
var PeerModel = preload("res://Player/MultiplayerPeer.tscn")

func _ready():
	multiplayer.peer_disconnected.connect(playerDisconnected)
	multiplayer.peer_connected.connect(playerConnected)
	multiplayer.connected_to_server.connect(clientConnected)
func _process(_delta):
	peerList = multiplayer.get_peers()

func startGame(_name:="Player"):
	ResourceLoader.load_threaded_request("res://overworld.tscn","",true,ResourceLoader.CACHE_MODE_REUSE)
	var levelResource = ResourceLoader.load_threaded_get("res://overworld.tscn")
	var level = levelResource.instantiate()
	playerGlobals.gameStarted = true
	get_node("/root").add_child(level,true)
	get_node("/root/Menu").queue_free()

func hostServer(port:int=defaultPort,maxPlayers:int=2):
	peer.create_server(int(port),int(maxPlayers))
	multiplayer.multiplayer_peer = peer
	
	
func connectServer(ip, port):
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer

func clientConnected():
	startGame()
	for i in peerList.size():
		spawnInstance(peerList[i])

func playerDisconnected(id):
	print("player " + str(id) + " has disconnected.")
	deleteInstance(id)
	
func playerConnected(id):
	spawnInstance(id)

func spawnInstance(id):
	if id != multiplayer.get_unique_id():
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
