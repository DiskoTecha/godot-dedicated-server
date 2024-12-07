extends Node

var peer
var gateway_api
var username
var password
const ADDRESS = "192.168.0.235"
const PORT = 8910


func _ready():
	pass


func connectToServer(_username, _password):
	username = _username
	password = _password
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ADDRESS, PORT)
	gateway_api = MultiplayerAPI.create_default_interface()
	get_tree().set_multiplayer(gateway_api, "/root/Gateway")
	gateway_api.set_multiplayer_peer(peer)
	
	gateway_api.connected_to_server.connect(_on_connection_ok)
	gateway_api.connection_failed.connect(_on_connection_failed)


func _on_connection_ok():
	print("Connected to gateway.")
	requestLogin()


func _on_connection_failed():
	print("Connection to gateway failed.")
	#TODO create popup for user that says connection to gateway has failed
	get_node("../Main/MainMenu/VBoxContainer/HBoxContainer/MarginContainer2/LoginButton").disabled = false


@rpc("any_peer", "call_remote", "reliable")
func loginRequest(username, password):
	pass


func requestLogin():
	print("Connecting to gateway to request login")
	loginRequest.rpc_id(1, username, password)
	username = ""
	password = ""


@rpc("authority", "call_remote", "reliable")
func returnLoginRequest(result, token):
	print("Login result received")
	
	if result == true:
		GameServer.token = token
		GameServer.connectToServer()
	else:
		print("Incorrect username and/or password")
		gateway_api.multiplayer_peer.disconnect_peer(1)
		#TODO create popup saying username and/or password are incorrect
		get_node("../Main/MainMenu/VBoxContainer/HBoxContainer/MarginContainer2/LoginButton").disabled = false
	
	gateway_api.connected_to_server.disconnect(_on_connection_ok)
	gateway_api.connection_failed.disconnect(_on_connection_failed)
