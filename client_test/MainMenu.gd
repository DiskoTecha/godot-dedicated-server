extends Control

signal login_button_pressed(username, password)

@onready var usernameLineEdit = $VBoxContainer/UsernameLineEdit
@onready var passwordLineEdit = $VBoxContainer/PasswordLineEdit
@onready var loginButton = $VBoxContainer/HBoxContainer/MarginContainer2/LoginButton

func _on_create_account_button_pressed():
	pass # Replace with function body.


func _on_login_button_pressed():
	if usernameLineEdit.text == "" or passwordLineEdit.text == "":
		print("Enter username and password")
		#TODO create popup telling user to enter username and password
	else:
		loginButton.disabled = true
		print("attempting to login...")
		Gateway.connectToServer(usernameLineEdit.text, passwordLineEdit.text)
