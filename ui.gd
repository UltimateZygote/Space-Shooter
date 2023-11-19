extends Control

signal start_game

var start = true
var restart = false


func _process(_delta):
	if Input.is_action_pressed("shoot"):
		if start:
			start_game.emit()
			$Start.hide()
			start = false
		elif restart:
			start_game.emit()
			$GameOver.hide()
			restart = false

func _on_texture_button_pressed():
	start_game.emit()
	$Start.hide()
	start = false


func _on_game_over_pressed():
	start_game.emit()
	$GameOver.hide()
	restart = false
	
func game_over():
	$GameOver.show()
	restart = true
