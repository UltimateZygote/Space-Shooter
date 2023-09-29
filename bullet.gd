extends Area2D

var prev_speed = 250.0 # pixels/sec
var acceleration = -0.65 # pixels/sec^2

func start(pos):
	position = pos
	
	
func _process(delta):
	prev_speed = (prev_speed + acceleration)
	position.y -= prev_speed * delta


func _on_area_entered(area):
	if area.is_in_group("enemies"):
		queue_free()
		area.explode()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
