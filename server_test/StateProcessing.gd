extends Node

var worldState = {}


func _physics_process(delta):
	if not GameServer.playerStateCollection.is_empty():
		worldState = GameServer.playerStateCollection.duplicate(true)
		for player in worldState.keys():
			worldState[player].erase("T")
		worldState["T"] = Time.get_unix_time_from_system()
		# Verifications
		# Anti Cheat
		# Cuts for chunking / different maps
		# Physics checks
		# Anything else?
		GameServer.sendWorldState(worldState)
