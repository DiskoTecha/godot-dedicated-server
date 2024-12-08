extends Node

var peer
var gateway_api
const PORT = 8910
const MAX_PLAYERS = 100

var cert = load("res://Certificate/X509_Certificate.crt")
var key = load("res://Certificate/X509_Key.key")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	startServer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func startServer():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_PLAYERS)
	gateway_api = MultiplayerAPI.create_default_interface()
	
	peer.host.dtls_server_setup(TLSOptions.server(key, cert))
	
	get_tree().set_multiplayer(gateway_api, "/root/Gateway")
	gateway_api.set_multiplayer_peer(peer)
	
	gateway_api.peer_connected.connect(_on_player_connected)
	gateway_api.peer_disconnected.connect(_on_player_disconnected)
	gateway_api.server_disconnected.connect(_on_server_disconnected)


func _on_player_connected(id):
	print("Player with id: " + str(id) + " connected to gateway.")

func _on_player_disconnected(id):
	print("Player with id: " + str(id) + " disconnected from gateway.")


func _on_server_disconnected():
	print("Gateway server disconnected.")


@rpc("any_peer", "call_remote", "reliable")
func loginRequest(username, password):
	print("Login request received")
	var player_id = gateway_api.get_remote_sender_id()
	Authenticator.authenticatePlayerFromGateway(username, password, player_id)


func returnLoginRequestToPlayer(result, player_id, token):
	returnLoginRequest.rpc_id(player_id, result, token)


@rpc("authority", "call_remote", "reliable")
func returnLoginRequest(result, token):
	pass
