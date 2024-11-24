extends Node

const ADDRESS = "192.168.0.235"
const PORT = 8910
const MAX_CONNECTIONS = 4
var peer

# Signals
signal game_joined

# Vars
@export var replicated_objects: Node3D
var joining_game = false

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func join_game(address = ""):
	if not joining_game:
		joining_game = true
		if address.is_empty():
			address = ADDRESS
		peer = ENetMultiplayerPeer.new()
		var error = peer.create_client(address, PORT)
		if error:
			joining_game = false
			return error
		multiplayer.multiplayer_peer = peer
		joining_game = false

func _on_player_connected(id):
	print("connected")
	game_joined.emit()


func _on_player_disconnected(id):
	print("disconnected")


func _on_connected_ok():
	print("connected ok")
	var peer_id = multiplayer.get_unique_id()


func _on_connected_fail():
	print("connected fail")
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null


func _on_main_menu_join_button_pressed():
	join_game()
