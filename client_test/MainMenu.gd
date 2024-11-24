extends Control

signal join_button_pressed


func _on_join_button_pressed():
	join_button_pressed.emit()


func _on_network_game_joined():
	self.hide()
