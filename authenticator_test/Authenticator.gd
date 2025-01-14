extends Node

var peer
const PORT = 8911
const MAX_SERVERS = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect to multiplayer connection signals
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	# Initialize rng
	randomize()
	
	# Start authenticator to gateway server
	startServer()


func startServer():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_SERVERS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func _on_player_connected(id):
	print("Gateway with id " + str(id) + " connected.")


func _on_player_disconnected(id):
	print("Gateway with id " + str(id) + " disconnected.")


func _on_server_disconnected():
	print("Authenticator server disconnected.")


@rpc("any_peer", "call_remote", "reliable")
func authenticatePlayer(username, password, player_id):
	print("Authentication request received")
	var gateway_id = multiplayer.get_remote_sender_id()
	var result
	var token
	var hashed_password
	print("Starting authentication")
	if not PlayerData.PlayerIDs.has(username):
		print("User not recognized")
		result = false
	else:
		var retrieved_salt = PlayerData.PlayerIDs[username].Salt
		hashed_password = generateHashedPassword(password, retrieved_salt)
		if not PlayerData.PlayerIDs[username].Password == hashed_password:
			print("Incorrect password")
			result = false
		else:
			print("Authentication succeeded")
			result = true
		
			token = str(randi()).sha256_text() + str(Time.get_unix_time_from_system())
			var game_server = "Alpha"
			GameServers.distributeLoginToken(token, game_server)
	
	print("Authentication result sent to gateway server")
	authenticationResults.rpc_id(gateway_id, result, player_id, token)


@rpc("any_peer", "call_remote", "reliable")
func createAccount(username, password, player_id):
	print("Create account request received")
	var gateway_id = multiplayer.get_remote_sender_id()
	var message_flag = 1
	print("Starting create account registration")
	if PlayerData.PlayerIDs.has(username):
		print("User already exists")
		message_flag = 2
	elif username == "" or password == "" or password.length() < 7:
			print("Username or password invalid")
			message_flag = 1
	else:
		print("Account creation succeeded")
		var salt = generateSalt()
		var hashed_password = generateHashedPassword(password, salt)
		PlayerData.PlayerIDs[username] = {"Password": hashed_password, "Salt": salt}
		message_flag = 3
	
	print("Account creation result sent to gateway server")
	createAccountResults.rpc_id(gateway_id, player_id, message_flag)


func generateSalt():
	var salt = str(randi()).sha256_text()
	print("Salt: " + salt)
	return salt


func generateHashedPassword(password, salt):
	var hashed_password = password
	var rounds = pow(2, 18) # TODO INCREASE THIS AMOUNT maybe???
	print("hashed_password as input: " + hashed_password)
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	print("Final hashed password: " + hashed_password)
	return hashed_password


@rpc("authority", "call_remote", "reliable")
func authenticationResults(result, player_id):
	pass


@rpc("authority", "call_remote", "reliable")
func createAccountResults(player_id, message_flag):
	pass
