extends Node

var awaiting_verification = {}

@onready var awaiting_verification_expiration_timer = Timer.new()

func _ready():
	awaiting_verification_expiration_timer.autostart = true
	awaiting_verification_expiration_timer.wait_time = 10
	awaiting_verification_expiration_timer.timeout.connect(_on_awaiting_verification_expiration_timer_timeout)
	self.add_child(awaiting_verification_expiration_timer)


func start(player_id: String):
	awaiting_verification[player_id] = {"Timestamp": Time.get_unix_time_from_system()}
	GameServer.fetchToken(int(player_id))
	print(awaiting_verification)


func verify(player_id: String, token: String):
	var token_verified = false
	while Time.get_unix_time_from_system() - float(token.right(14)) <= 30:
		print(token)
		print(GameServers.expected_game_tokens)
		if GameServers.expected_game_tokens.has(token):
			GameServers.expected_game_tokens.erase(token)
			token_verified = true
			createPlayerContainer(player_id)
			awaiting_verification.erase(player_id)
			break
		else:
			await get_tree().create_timer(2).timeout
	GameServer.returnTokenVerificationResults(player_id, token_verified)
	if not token_verified:
		awaiting_verification.erase(player_id)
		multiplayer.multiplayer_peer.disconnect_peer(int(player_id))


func _on_awaiting_verification_expiration_timer_timeout():
	var current_time = Time.get_unix_time_from_system()
	var start_time
	if awaiting_verification == {}:
		pass
	else:
		for key in awaiting_verification.keys():
			start_time = awaiting_verification[key].Timestamp
			if current_time - start_time >= 30:
				awaiting_verification.erase(key)
				var connected_peers = multiplayer.get_peers()
				if connected_peers.has(key):
					GameServer.returnTokenVerificationResults(key, false)
					GameServer.multiplayer.multiplayer_peer.disconnect_peer(key)
	print("Awaiting verification")
	print(awaiting_verification)


func createPlayerContainer(player_id):
	pass
