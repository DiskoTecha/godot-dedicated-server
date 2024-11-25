extends Node

var peer
const PORT = 8911
const MAX_SERVERS = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	startServer()


func startServer():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_SERVERS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func _on_player_connected(id):
	print("Gateway with id " + str(id) + " connected.")


func _on_player_disconnected(id):
	print("Gateway with id " + str(id) + " disconnected.")


func _on_server_disconnected():
	print("Authenticator server disconnected.")


@rpc("any_peer", "call_remote", "reliable")
func authenticatePlayer(username, password, player_id):
	print("Authentication request received")
	var gateway_id = multiplayer.get_remote_sender_id()
	var result = true
	print("Staring authentication")
	if not PlayerData.PlayerIDs.has(username):
		print("User not recognized")
		result = false
	elif not PlayerData.PlayerIDs[username].Password == password:
		print("Incorrect password")
		result = false
	print("Authentication result sent to gateway server")
	authenticationResults.rpc_id(gateway_id, result, player_id)


@rpc("authority", "call_remote", "reliable")
func authenticationResults(result, player_id):
	pass
