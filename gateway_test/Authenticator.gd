extends Node

var peer
const ADDRESS = "192.168.0.235"
const PORT = 8910

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	
	connectToServer()


func connectToServer():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ADDRESS, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func _on_connected_ok():
	print("Connected to authenticator server")


func _on_connected_fail():
	print("Failed to connect to authenticator server")


@rpc("authority", "call_remote", "reliable")
func authenticatePlayer(username, password, player_id):
	pass
