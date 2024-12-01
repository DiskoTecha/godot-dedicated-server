extends Node

var awaiting_verification = {}

func start(player_id):
	awaiting_verification[player_id] = {"Timestamp": Time.get_unix_time_from_system()}
	GameServer.fetchToken(player_id)


func verify(player_id, token):
	var token_verified = false
	while Time.get_unix_time_from_system() - awaiting_verification[player_id].Timestamp <= 30:
		if GameServers.expected_game_tokens.has(token):
			token_verified = true
			createPlayerContainer(player_id)
			awaiting_verification.erase(player_id)
			GameServers.expected_game_tokens.erase(token)
		else:
			await get_tree().create_timer(2).timeout
	GameServer.returnTokenVerificationResults(token_verified)
	if not token_verified:
		awaiting_verification.erase(player_id)
		multiplayer.multiplayer_peer.disconnect_peer(player_id)


func createPlayerContainer(player_id):
	pass
