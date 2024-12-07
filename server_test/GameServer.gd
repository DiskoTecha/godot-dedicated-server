extends Node

const PORT = 8909
const MAX_CONNECTIONS = 4


# Vars
@export var replicated_objects : Node3D
@onready var character = preload("res://character.tscn")
@onready var peer = ENetMultiplayerPeer.new()

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	create_game()


func create_game():
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func _on_player_connected(id):
	print("connected")
	PlayerVerification.start(str(id))


func _on_player_disconnected(id):
	print("disconnected")


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null


@rpc("any_peer", "call_remote", "reliable")
func giveTokenToServer(token):
	PlayerVerification.verify(str(multiplayer.get_remote_sender_id()), token)
	print("sender id = " + str(multiplayer.get_remote_sender_id()))


@rpc("authority", "call_remote", "reliable")
func requestTokenFromPlayer():
	pass


@rpc("authority", "call_remote", "reliable")
func sendVerificationResults(results):
	pass


func fetchToken(player_id):
	requestTokenFromPlayer.rpc_id(player_id)


func returnTokenVerificationResults(player_id, results):
	sendVerificationResults.rpc_id(int(player_id), results)
