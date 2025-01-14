extends Node

var peer
var gateway_api
var username
var password
var create_account = false

const ADDRESS = "192.168.0.235"
const PORT = 8910

var cert = load("res://Resources/Certificate/X509_Certificate.crt")

func _ready():
	pass


func connectToServer(_username, _password, _create_account):
	username = _username
	password = _password
	create_account = _create_account
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ADDRESS, PORT)
	gateway_api = MultiplayerAPI.create_default_interface()
	
	peer.host.dtls_client_setup("ip:port", TLSOptions.client_unsafe(cert))
	
	get_tree().set_multiplayer(gateway_api, "/root/Gateway")
	gateway_api.set_multiplayer_peer(peer)
	
	gateway_api.connected_to_server.connect(_on_connection_ok)
	gateway_api.connection_failed.connect(_on_connection_failed)


func _on_connection_ok():
	print("Connected to gateway.")
	if create_account:
		requestCreateAccount()
	else:
		requestLogin()


func _on_connection_failed():
	print("Connection to gateway failed.")
	#TODO create popup for user that says connection to gateway has failed
	get_node("../Main/MainMenu/VBoxContainer/HBoxContainer/MarginContainer2/LoginButton").disabled = false
	get_node("../Main/MainMenu/VBoxContainer/HBoxContainer/MarginContainer/CreateAccountButton").disabled = false
	get_node("../Main/MainMenu/VBoxContainer2/HBoxContainer/MarginContainer2/ConfirmCreateAccountButton").disabled = false
	get_node("../Main/MainMenu/VBoxContainer2/HBoxContainer/MarginContainer/BackButton").disabled = false


@rpc("any_peer", "call_remote", "reliable")
func loginRequest(username, password):
	pass


@rpc("any_peer", "call_remote", "reliable")
func createAccountRequest(username, password):
	pass


func requestLogin():
	print("Connecting to gateway to request login")
	loginRequest.rpc_id(1, username, password.sha256_text())
	username = ""
	password = ""

func requestCreateAccount():
	print("Connecting to gateway to request create account")
	createAccountRequest.rpc_id(1, username, password.sha256_text())
	username = ""
	password = ""

@rpc("authority", "call_remote", "reliable")
func returnLoginRequest(result, token):
	print("Login result received")
	gateway_api.multiplayer_peer.disconnect_peer(1)
	
	if result == true:
		GameServer.token = token
		GameServer.connectToServer()
	else:
		print("Incorrect username and/or password")
		#TODO create popup saying username and/or password are incorrect
		get_node("../Main/MainMenu/VBoxContainer/HBoxContainer/MarginContainer2/LoginButton").disabled = false
		get_node("../Main/MainMenu/VBoxContainer/HBoxContainer/MarginContainer/CreateAccountButton").disabled = false
	
	gateway_api.connected_to_server.disconnect(_on_connection_ok)
	gateway_api.connection_failed.disconnect(_on_connection_failed)


@rpc("authority", "call_remote", "reliable")
func returnCreateAccountRequest(message_flag):
	print("Create account result received")
	gateway_api.multiplayer_peer.disconnect_peer(1)
	
	get_node("../Main/MainMenu/VBoxContainer2/HBoxContainer/MarginContainer/BackButton").disabled = false
	get_node("../Main/MainMenu/VBoxContainer2/HBoxContainer/MarginContainer2/ConfirmCreateAccountButton").disabled = false
	
	if message_flag == 3:
		print("Create account result successful")
		get_node("../Main/MainMenu/VBoxContainer2").hide()
		get_node("../Main/MainMenu/VBoxContainer").show()
	elif message_flag == 2:
		# TODO add popup telling user what messed up
		print("Cannot create account, username already exists")
	else:
		print("Cannot create account, unknown error occurred")
	
	gateway_api.connected_to_server.disconnect(_on_connection_ok)
	gateway_api.connection_failed.disconnect(_on_connection_failed)
