extends Node

var peer
var authenticator_to_game_servers_api: MultiplayerAPI
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
	authenticator_to_game_servers_api = MultiplayerAPI.create_default_interface()
	get_tree().set_multiplayer(authenticator_to_game_servers_api, "/root/GameServers")
	authenticator_to_game_servers_api.set_multiplayer_peer(peer)

	authenticator_to_game_servers_api.peer_connected.connect(_on_game_server_connected)
	authenticator_to_game_servers_api.peer_disconnected.connect(_on_game_server_disconnected)
	authenticator_to_game_servers_api.server_disconnected.connect(_on_server_disconnected)

func _on_game_server_connected(id):
	print("Game server with id: " + str(id) + " connected.")
	# Removed game_server_list addition
	print(game_server_list)

func _on_game_server_disconnected(id):
	print("Game server with id: " + str(id) + " disconnected.")
	var key = game_server_list.find_key(id)
	if key:
		game_server_list.erase(key)
	print(game_server_list)

func _on_server_disconnected():
	print("Authenticator to game servers disconnect.")
	game_server_list.clear()


func distributeLoginToken(token, game_server):
	if game_server_list.has(game_server):
		passLoginToken.rpc_id(game_server_list[game_server], token)
	else:
		print("Could not distribute login token to server named: " + str(game_server))


@rpc("authority", "call_remote", "reliable")
func passLoginToken(token):
	pass

@rpc("any_peer", "call_remote", "reliable")
func passServerName(server_name):
	var client_id = authenticator_to_game_servers_api.get_remote_sender_id()
	game_server_list[server_name] = client_id
	print("Added server: " + server_name + " with id: " + str(client_id))
	print(game_server_list)
