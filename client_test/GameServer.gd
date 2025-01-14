extends Node

const ADDRESS = "192.168.0.235"
const PORT = 8909
const MAX_CONNECTIONS = 4

# Vars
@export var replicated_objects: Node3D
var joining_game = false
var peer
var token

@onready var map = get_node("../Main/Map")

var latencyArray = []
var latency = 0.0
var clientClock = 0.0
var deltaLatency = 0.0

func _ready():
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _physics_process(delta):
	clientClock += delta + deltaLatency
	deltaLatency -= deltaLatency


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
	fetchServerTime.rpc_id(1, Time.get_unix_time_from_system())
	
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", determineLatency)
	add_child(timer)


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


@rpc("authority", "call_remote", "reliable")
func sendVerificationResults(results):
	if results == true:
		get_node("../Main/MainMenu").queue_free()
		print("Successful token verification")
		print("Spawning local player")
		map.spawnLocalPlayer(Vector3(5, 5, 5))
	else:
		#TODO create popup alerting user the login failed
		print("Token verification failed, please try again")
		get_node("../Main/MainMenu/VBoxContainer/HBoxContainer/MarginContainer2/LoginButton").disabled = false
		get_node("../Main/MainMenu/VBoxContainer/HBoxContainer/MarginContainer/CreateAccountButton").disabled = false


@rpc("authority", "call_remote", "reliable")
func spawnPlayer(player_id: int, startPosition: Vector3):
	map.spawnPlayer(player_id, startPosition)


@rpc("authority", "call_remote", "reliable")
func despawnPlayer(player_id: int):
	map.despawnPlayer(player_id)


@rpc("any_peer", "call_remote", "unreliable")
func receivePlayerState(playerState):
	pass


@rpc("authority", "call_remote", "unreliable")
func receiveWorldState(worldState):
	map.updateWorldState(worldState)


@rpc("any_peer", "call_remote", "reliable")
func fetchServerTime(clientTime):
	pass


@rpc("authority", "call_remote", "reliable")
func returnServerTime(serverTime, clientTime):
	latency = (Time.get_unix_time_from_system() - clientTime) / 2.0
	clientClock = serverTime + latency


@rpc("any_peer", "call_remote", "reliable")
func determineLatencyFromServer(clientTime):
	pass


@rpc("authority", "call_remote", "reliable")
func returnLatency(clientTime):
	latencyArray.append((Time.get_unix_time_from_system() - clientTime) / 2.0)
	if latencyArray.size() == 9:
		var totalLatency = 0.0
		latencyArray.sort()
		var median = latencyArray[4]
		for i in range(latencyArray.size() - 1, -1, -1):
			if latencyArray[i] > (2.0 * median) and latencyArray[i] > 0.2:
				latencyArray.remove_at(i)
			else:
				totalLatency += latencyArray[i]
		deltaLatency = (totalLatency / latencyArray.size()) - latency
		latency = totalLatency / latencyArray.size()
		print("New latency: ", latency)
		print("Delta latency: ", deltaLatency)
		latencyArray.clear()


func sendPlayerState(playerState):
	receivePlayerState.rpc_id(1, playerState)


func determineLatency():
	determineLatencyFromServer.rpc_id(1, Time.get_unix_time_from_system())
