extends Control

signal login_button_pressed(username, password)

@onready var usernameLineEdit = $VBoxContainer/UsernameLineEdit
@onready var passwordLineEdit = $VBoxContainer/PasswordLineEdit
@onready var loginButton = $VBoxContainer/HBoxContainer/MarginContainer2/LoginButton
@onready var createAccountButton = $VBoxContainer/HBoxContainer/MarginContainer/CreateAccountButton

@onready var loginScreen = $VBoxContainer
@onready var createAccountScreen = $VBoxContainer2

@onready var createAccountUsernameLineEdit = $VBoxContainer2/UsernameLineEdit
@onready var createAccountPasswordLineEdit = $VBoxContainer2/PasswordLineEdit
@onready var createAccountConfirmPasswordLineEdit = $VBoxContainer2/PasswordLineEdit2

@onready var createAccountBackButton = $VBoxContainer2/HBoxContainer/MarginContainer/BackButton
@onready var createAccountConfirmButton = $VBoxContainer2/HBoxContainer/MarginContainer2/ConfirmCreateAccountButton

func _ready():
	createAccountScreen.hide()
	loginScreen.show()

func _on_create_account_button_pressed():
	loginScreen.hide()
	createAccountScreen.show()


func _on_login_button_pressed():
	if usernameLineEdit.text == "" or passwordLineEdit.text == "":
		print("Enter username and password")
		#TODO create popup telling user to enter username and password
	else:
		loginButton.disabled = true
		createAccountButton.disabled = true
		print("attempting to login...")
		Gateway.connectToServer(usernameLineEdit.text, passwordLineEdit.text, false)


func _on_back_button_pressed():
	createAccountScreen.hide()
	loginScreen.show()


func _on_confirm_create_account_button_pressed():
	# TODO create popups for all of these instead of print statements
	if createAccountUsernameLineEdit.text == "":
		print("Please provide valid username")
	elif createAccountPasswordLineEdit.text == "":
		print("Please provide valid password")
	elif createAccountConfirmPasswordLineEdit.text == "":
		print("Please confirm your password")
	elif createAccountPasswordLineEdit.text != createAccountConfirmPasswordLineEdit.text:
		print("Passwords do not match")
	elif createAccountPasswordLineEdit.text.length() <= 6:
		print("Password must be at least seven characters long")
	else:
		createAccountConfirmButton.disabled = true
		createAccountBackButton.disabled = true
		var username = createAccountUsernameLineEdit.text
		var password = createAccountPasswordLineEdit.text
		Gateway.connectToServer(username, password, true)
