extends Node2D

var seconds = 0
var stopwatch = 0
var timer_start = false
var enemy_wait_time_min = 2
var enemy_wait_time_max = 10
var enemy_speed_min = 120
var enemy_speed_max = 150
var available_enemy_positions = []

@export var enemy : PackedScene
func _ready():
	$AudioStreamPlayer.play()


func spawn_enemies():
	for x in 9:
		for y in 3:
			var e = enemy.instantiate()
			var pos = Vector2(x * (16 + 8) + 24, 16 * 2 + y * 16)
			add_child(e)
			e.start(pos, enemy_wait_time_min, enemy_wait_time_max, enemy_speed_min, enemy_speed_max)
			e.enemy_death.connect(on_enemy_death)
			e.exit_screen.connect(on_enemy_exit_screen)
	if enemy_wait_time_max > 4:
		enemy_wait_time_max -= 1
	enemy_speed_min += 20
	enemy_speed_max += 100
	available_enemy_positions = []
	
	
func _process(delta):
	if timer_start:
		stopwatch += delta
		seconds = int(stopwatch)
		$Second4.frame = counter_frame(seconds / 1000)
		$Second3.frame = counter_frame((seconds / 100) % 10)
		$Second2.frame = counter_frame((seconds / 10) % 10)
		$Second1.frame = counter_frame(seconds % 10)


func counter_frame(digit):
	if digit == 0:
		return 9
	else:
		return digit - 1


func _on_ui_start_game():
	stopwatch = 0
	timer_start = true
	spawn_enemies()
	$Ship.start_ship()


func _on_ship_ship_go_boom():
	timer_start = false
	get_tree().call_group("enemies", "queue_free")
	$UI/Start.hide()
	$UI/GameOver.show()
	enemy_wait_time_min = 2
	enemy_wait_time_max = 10
	enemy_speed_min = 75
	enemy_speed_max = 100


func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()
	

func on_enemy_death(start_pos):
	available_enemy_positions.append(start_pos)
	await get_tree().create_timer(.1).timeout
	if get_tree().get_nodes_in_group("enemies").size() == 0:
		spawn_enemies()
		stopwatch += 100
		
func on_enemy_exit_screen(body, start_pos):
	if available_enemy_positions.size() > 0:
		var new_pos = available_enemy_positions.pick_random()
		body.reset_pos(new_pos)
		available_enemy_positions.erase(new_pos)
		available_enemy_positions.append(start_pos)
	else:
		body.reset_pos(start_pos)
