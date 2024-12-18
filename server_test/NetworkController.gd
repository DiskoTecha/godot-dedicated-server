extends Node

const PORT = 8910
const MAX_CONNECTIONS = 4
var peer

# Vars
@export var replicated_objects : Node3D
@onready var character = preload("res://character.tscn")


func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	create_game()


func create_game():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

func _on_player_connected(id):
	print("connected")
	var new_char = character.instantiate()
	new_char.position = Vector3(randf() * 20.0 - 10.0, 1.0, randf() * 20.0 - 10.0)
	replicated_objects.add_child(new_char)


func _on_player_disconnected(id):
	print("disconnected")


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
