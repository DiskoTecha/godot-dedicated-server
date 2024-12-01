extends Node

const ADDRESS = "192.168.1.39"
const PORT = 8909
const MAX_CONNECTIONS = 4

# Vars
@export var replicated_objects: Node3D
var joining_game = false
var peer
var token


func _ready():
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func connectToServer():
	if not joining_game:
		joining_game = true
		peer = ENetMultiplayerPeer.new()
		var error = peer.create_client(ADDRESS, PORT)
		if error:
			joining_game = false
			return error
		multiplayer.multiplayer_peer = peer
		joining_game = false

func _on_connected_ok():
	print("connected ok")
	var peer_id = multiplayer.get_unique_id()


func _on_connected_fail():
	print("connected fail")
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null


@rpc("any_peer", "call_remote", "reliable")
func giveTokenToServer(token):
	pass

@rpc("authority", "call_remote", "reliable")
func requestTokenFromPlayer():
	giveTokenToServer.rpc_id(1, token)
