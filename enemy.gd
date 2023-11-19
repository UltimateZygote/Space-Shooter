extends Area2D

var start_pos = Vector2.ZERO
var speed = 0 # pixels/sec
var enemy_speed_min = 0
var enemy_speed_max = 0
var enemy_wait_time_min = 2
var enemy_wait_time_max = 10
signal enemy_death
signal exit_screen

@onready var screensize = get_viewport_rect().size

func start(pos, wait_time_min, wait_time_max, speed_min, speed_max):
	speed = 0
	position = Vector2(pos.x, -pos.y)
	start_pos = pos
	await get_tree().create_timer(randf_range(.25, .5)).timeout
	var tween = create_tween().set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position:y", start_pos.y, 1.4)
	$MoveTimer.wait_time = randf_range(wait_time_min, wait_time_max)
	$MoveTimer.start()
	$ShootTimer.wait_time = randf_range(wait_time_min, wait_time_max)
	$ShootTimer.start()
	enemy_wait_time_min = wait_time_min
	enemy_wait_time_max = wait_time_max
	enemy_speed_min = speed_min
	enemy_speed_max = speed_max

func _on_move_timer_timeout():
	speed = randf_range(enemy_speed_min, enemy_speed_max)

func _on_shoot_timer_timeout():
	pass # Replace with function body.

func _process(delta):
	position.y += speed * delta
	if position.y > screensize.y + 32:
		exit_screen.emit(self, start_pos)

func reset_pos(new_pos):
	start(new_pos, enemy_wait_time_min, enemy_wait_time_max, enemy_speed_min, enemy_speed_max)

func explode():
	speed = 0
	$AnimationPlayer.play("explode")
	$Kaboom.play()
	set_deferred("monitorable", false)
	Input.start_joy_vibration(0, .4, 0)
	await $AnimationPlayer.animation_finished
	Input.stop_joy_vibration(0)
	await $Kaboom.finished
	enemy_death.emit(start_pos)
	queue_free()
