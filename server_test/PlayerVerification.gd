extends Node

var awaiting_verification = {}

func start(player_id: String):
	awaiting_verification[player_id] = {"Timestamp": Time.get_unix_time_from_system()}
	GameServer.fetchToken(int(player_id))
	print(awaiting_verification)


#func verify(player_id: String, token: String):
	#var token_verified = false
	#while Time.get_unix_time_from_system() - awaiting_verification[player_id].Timestamp <= 30:
		#if GameServers.expected_game_tokens.has(token):
			#GameServers.expected_game_tokens.erase(token)
			#token_verified = true
			#createPlayerContainer(player_id)
			#awaiting_verification.erase(player_id)
		#else:
			#await get_tree().create_timer(2).timeout
	#GameServer.returnTokenVerificationResults(token_verified)
	#if not token_verified:
		#awaiting_verification.erase(player_id)
		#multiplayer.multiplayer_peer.disconnect_peer(int(player_id))


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

func createPlayerContainer(player_id):
	pass
