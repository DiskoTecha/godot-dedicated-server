extends Node

var peer
var authenticator_to_game_servers_api
const PORT = 8912
const ADDRESS = "192.168.1.39"

var expected_game_tokens = []

@onready var token_expiration_timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connectToServer()
	token_expiration_timer.autostart = true
	token_expiration_timer.wait_time = 10
	token_expiration_timer.timeout.connect(_on_token_expiration_timer_timeout)
	self.add_child(token_expiration_timer)


func connectToServer():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ADDRESS, PORT)
	if error:
		return error
	authenticator_to_game_servers_api = MultiplayerAPI.get_default_interface()
	get_tree().set_multiplayer(authenticator_to_game_servers_api, "/root/GameServers")
	authenticator_to_game_servers_api.set_multiplayer_peer(peer)
	
	authenticator_to_game_servers_api.connected_to_server.connect(_on_connected_ok)
	authenticator_to_game_servers_api.connection_failed.connect(_on_connected_fail)
	authenticator_to_game_servers_api.server_disconnected.connect(_on_server_disconnected)


func _on_connected_ok():
	print("Connected to authenticator ok.")


func _on_connected_fail():
	print("Connection to authenticator failed.")


func _on_server_disconnected():
	print("To game server from authenticator, authenticator server disconnected")


@rpc("authority", "call_remote", "reliable")
func passLoginToken(token):
	expected_game_tokens.append(token)


func _on_token_expiration_timer_timeout():
	var current_time = Time.get_unix_time_from_system()
	var token_time
	if expected_game_tokens == []:
		pass
	else:
		for i in range(expected_game_tokens.size() - 1, -1, -1):
			token_time = int(expected_game_tokens[i].right(64))
			if current_time - token_time >= 30:
				expected_game_tokens.remove(i)
	print("Expected game tokens:")
	print(expected_game_tokens)
