extends Node3D

var other_player = preload("res://other_character.tscn")
var local_player = preload("res://character.tscn")

var lastWorldState = 0

var worldStateBuffer = []
const INTERPOLATION_OFFSET = 0.1

func spawnLocalPlayer(start_pos: Vector3):
	var new_local_player = local_player.instantiate()
	new_local_player.position = start_pos
	new_local_player.name = "LocalPlayer"
	add_child(new_local_player)


func spawnPlayer(player_id, start_pos: Vector3):
	if str(get_tree().get_multiplayer().get_unique_id()) == str(player_id):
		pass
	elif not has_node(str(player_id)):
		var new_player = other_player.instantiate()
		new_player.position = start_pos
		new_player.name = str(player_id)
		add_child(new_player)


func despawnPlayer(player_id):
	var playerToDespawn = get_node(str(player_id))
	print("Despawning player: " + str(player_id))
	print(playerToDespawn)
	if playerToDespawn:
		await get_tree().create_timer(0.2).timeout # To log out crashed players
		# For quitting during the game, turn off them sending their player state to the server and wait like 10 seconds or something
		# If they move in that time, then send the player state.
		# That way, their player state won't be in a world state that is 100 ms in the past if they are completely offline
		# and they won't get respawned by the spawnPlayer() call in the _physics_process() function
		playerToDespawn.queue_free()


func updateWorldState(worldState):
	if worldState["T"] > lastWorldState:
		lastWorldState = worldState["T"]
		worldStateBuffer.append(worldState)


func _physics_process(delta):
	var timeRenderedAt = GameServer.clientClock - INTERPOLATION_OFFSET
	if worldStateBuffer.size() > 1:
		while worldStateBuffer.size() > 2 and timeRenderedAt > worldStateBuffer[2]["T"]:
			worldStateBuffer.remove_at(0)
		if worldStateBuffer.size() > 2: # timeRenderedAt <= worldStateBuffer[2]["T"] (we have a future world state)
			var interpolationFactor = (timeRenderedAt - worldStateBuffer[1]["T"]) / (worldStateBuffer[2]["T"] - worldStateBuffer[1]["T"])
			for player in worldStateBuffer[2].keys():
				if str(player) == "T":
					continue
				if str(player) == str(get_tree().get_multiplayer().get_unique_id()):
					continue
				if not worldStateBuffer[1].has(player):
					continue
				if has_node(str(player)):
					interpolationFactor = clampf(interpolationFactor, 0, 1)
					var newPos = lerp(worldStateBuffer[1][player]["P"], worldStateBuffer[2][player]["P"], interpolationFactor)
					get_node(str(player)).movePlayer(newPos)
				else:
					print("spawning player")
					spawnPlayer(str(player), worldStateBuffer[2][player]["P"])
		elif timeRenderedAt > worldStateBuffer[1]["T"]: # We have no future world state
			var extrapolationFactor = (timeRenderedAt - worldStateBuffer[0]["T"]) / (worldStateBuffer[1]["T"] - worldStateBuffer[0]["T"]) - 1.00
			for player in worldStateBuffer[1].keys():
				if str(player) == "T":
					continue
				if str(player) == str(get_tree().get_multiplayer().get_unique_id()):
					continue
				if not worldStateBuffer[0].has(player):
					continue
				if has_node(str(player)):
					var positionDelta = worldStateBuffer[1][player]["P"] - worldStateBuffer[0][player]["P"]
					var newPos = worldStateBuffer[1][player]["P"] + (positionDelta * extrapolationFactor)
					get_node(str(player)).movePlayer(newPos)
