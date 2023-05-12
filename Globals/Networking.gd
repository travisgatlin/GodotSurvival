extends Node
var peer = ENetMultiplayerPeer.new()
signal playerConnected()
func _ready():
	pass
#func _process(delta):
	#if multiplayer.peer_connected():
		#_onPlayerConnect()


func _hostServer(port):
	peer.create_server(int(port))
	multiplayer.multiplayer_peer = peer
	#multiplayer.peer_connected.connect(_onPlayerConnect)
	
	
func _connectServer(ip, port):
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer

func _onPlayerConnect():
	playerConnected.emit()
