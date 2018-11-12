extends RigidBody2D

export (int) var damage = 1
export (float) var speed_x
export (float) var speed_y

func set_initial_position(pos):
	position = pos
	apply_impulse(Vector2(0,0), Vector2(speed_x, -speed_y))
	
func _on_SpitBullet_body_entered(body):
	print("body = %s" % body)
	body.remove_hp(damage)
	queue_free()
