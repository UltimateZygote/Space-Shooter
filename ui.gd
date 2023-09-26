extends Control

signal start_game


func _on_texture_button_pressed():
	start_game.emit()
	$Start.hide()


func _on_game_over_pressed():
	start_game.emit()
	$GameOver.hide()
