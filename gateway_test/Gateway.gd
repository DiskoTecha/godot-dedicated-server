extends Node

var peer
var gateway_api
const PORT = 8911
const MAX_PLAYERS = 100

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
	get_tree().set_multiplayer(gateway_api, "/root/Gateway")
	gateway_api.set_multiplayer_peer(peer)
	
	gateway_api.peer_connected(_on_player_connected)
	gateway_api.peer_disconnected(_on_player_disconnected)
	gateway_api.server_disconnected(_on_server_disconnected)


func _on_player_connected(id):
	print("Player with id: " + str(id) + " connected to gateway.")

func _on_player_disconnected(id):
	print("Player with id: " + str(id) + " disconnected from gateway.")


func _on_server_disconnected():
	print("Gateway server disconnected.")
