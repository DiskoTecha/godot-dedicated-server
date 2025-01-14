extends Node

const PORT = 8909
const MAX_CONNECTIONS = 4


# Vars
@export var replicated_objects : Node3D
@onready var character = preload("res://character.tscn")
@onready var peer = ENetMultiplayerPeer.new()

var playerStateCollection = {}

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
	playerStateCollection.erase(str(id))
	despawnPlayer.rpc(id)
	print(playerStateCollection)



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


@rpc("authority", "call_remote", "reliable")
func spawnPlayer(player_id: int, startPosition: Vector3):
	pass


@rpc("authority", "call_remote", "reliable")
func despawnPlayer(player_id: int):
	pass


@rpc("any_peer", "call_remote", "unreliable")
func receivePlayerState(playerState):
	var player_id = str(multiplayer.get_remote_sender_id())
	if playerStateCollection.has(player_id):
		if playerStateCollection[player_id]["T"] < playerState["T"]:
			playerStateCollection[player_id] = playerState
	else:
		playerStateCollection[player_id] = playerState


@rpc("authority", "call_remote", "unreliable")
func receiveWorldState(worldState):
	pass


@rpc("any_peer", "call_remote", "reliable")
func fetchServerTime(clientTime):
	var playerId = multiplayer.get_remote_sender_id()
	returnServerTime.rpc_id(playerId, Time.get_unix_time_from_system(), clientTime)


@rpc("authority", "call_remote", "reliable")
func returnServerTime(serverTime, clientTime):
	pass


@rpc("any_peer", "call_remote", "reliable")
func determineLatencyFromServer(clientTime):
	var playerId = multiplayer.get_remote_sender_id()
	returnLatency.rpc_id(playerId, clientTime)


@rpc("authority", "call_remote", "reliable")
func returnLatency(clientTime):
	pass


func fetchToken(player_id):
	requestTokenFromPlayer.rpc_id(player_id)


func returnTokenVerificationResults(player_id, results):
	sendVerificationResults.rpc_id(int(player_id), results)
	if results == true:
		spawnPlayer.rpc(int(player_id), Vector3(-5, 0, -5))


func sendWorldState(worldState):
	receiveWorldState.rpc(worldState)
