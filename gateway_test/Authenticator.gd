extends Node

var peer
const ADDRESS = "192.168.0.235"
const PORT = 8911

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

func authenticatePlayerFromGateway(username, password, player_id):
	authenticatePlayer.rpc_id(1, username, password, player_id)


func createAccountFromGateway(username, password, player_id):
	createAccount.rpc_id(1, username, password, player_id)


@rpc("any_peer", "call_remote", "reliable")
func authenticatePlayer(username, password, player_id):
	pass


@rpc("any_peer", "call_remote", "reliable")
func createAccount(username, password, player_id):
	pass


@rpc("authority", "call_remote", "reliable")
func createAccountResults(player_id, message_flag):
	print("Create account results received, replying to player create account request")
	Gateway.returnCreateAccountRequestToPlayer(player_id, message_flag)


@rpc("authority", "call_remote", "reliable")
func authenticationResults(result, player_id, token):
	print("Authentication results received, replying to player login request")
	Gateway.returnLoginRequestToPlayer(result, player_id, token)
