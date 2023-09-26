extends Area2D

var speed = 150 # pixels/sec
var cooldown = 1.2 # sec
var can_shoot = true
var shoot_pause = true
var move_pause = true
signal ship_go_boom
@export var bullet_scene : PackedScene

@onready var screensize = get_viewport_rect().size
func _ready():
	start()


func start():
	$AnimationPlayer.play("normal")
	position = Vector2(screensize.x / 2, screensize.y - 64)
	$GunCooldown.wait_time = cooldown
	$Sprite2D.frame = 1
	$Sprite2D.show()


func _process(delta):
	if shoot_pause:
		return
	if Input.is_action_pressed("shoot"):
		shoot()
	var input = Input.get_vector("left", "right", "up", "down")
	if input.x > 0:
		$Sprite2D.frame = 2
	elif input.x < 0:
		$Sprite2D.frame = 0
	else:
		$Sprite2D.frame = 1
	position += input * speed * delta
	position = position.clamp(Vector2(8, 7), screensize - Vector2(8, 7))


func shoot():
	if not can_shoot:
		return
	if shoot_pause:
		return
	can_shoot = false
	$GunCooldown.start()
	var new_bullet = bullet_scene.instantiate()
	get_tree().root.add_child(new_bullet)
	new_bullet.start(position + Vector2(0, -12))
	$Pew.pitch_scale = 1 + randf_range(-.07, .07)
	$Pew.play()



func _on_gun_cooldown_timeout():
	can_shoot = true


func _on_area_entered(area):
	if area.is_in_group("enemies"):
		area.explode()
		explode()
	#if area.is_in_group("enemy_bullet"):
		#area.queue_free()
		#explode()

func explode():
	shoot_pause = true
	move_pause = true
	$AnimationPlayer.play("explosion")
	$Kaboom.play()
	set_deferred("monitorable", false)
	ship_go_boom.emit()
	await $AnimationPlayer.animation_finished
	$Sprite2D.hide()
	

func start_ship():
	shoot_pause = false
	move_pause = false
	start()
