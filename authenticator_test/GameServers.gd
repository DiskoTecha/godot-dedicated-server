extends Node

var peer
var authenticator_to_game_servers_api
const PORT = 8912
const MAX_GAME_SERVERS = 50

var game_server_list = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startServer()


func startServer():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_GAME_SERVERS)
	if error:
		return error
	authenticator_to_game_servers_api = MultiplayerAPI.get_default_interface()
	get_tree().set_multiplayer(authenticator_to_game_servers_api, "/root/GameServers")
	authenticator_to_game_servers_api.set_multiplayer_peer(peer)
	
	authenticator_to_game_servers_api.peer_connected.connect(_on_game_server_connected)
	authenticator_to_game_servers_api.peer_disconnected.connect(_on_game_server_disconnected)
	authenticator_to_game_servers_api.server_disconnected.connect(_on_server_disconnected)


func _on_game_server_connected(id):
	print("Game server with id: " + str(id) + " connected.")
	#TODO change hard coded name to a name creator when load balancing
	game_server_list["GameServer1"] = id
	print(game_server_list)


func _on_game_server_disconnected(id):
	print("Game server with id: " + str(id) + " disconnected.")
	game_server_list.erase("GameServer1")


func _on_server_disconnected():
	print("Authenticator to game servers disconnect.")
	game_server_list.clear()


func distributeLoginToken(token, game_server):
	var gameserver_id = game_server_list[game_server]
	passLoginToken.rpc_id(gameserver_id, token)

@rpc("authority", "call_remote", "reliable")
func passLoginToken(token):
	pass
