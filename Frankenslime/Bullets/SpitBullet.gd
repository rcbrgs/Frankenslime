extends RigidBody2D

export (int) var damage = 1
export (float) var speed_x = 2000
export (float) var speed_y

var h_flipper = false

func set_initial_position(pos):
	position = pos
	if h_flipper:
		speed_x *= -1
	apply_impulse(Vector2(0,0), Vector2(speed_x, -speed_y))
	
func _on_SpitBullet_body_entered(body):
	#print("body = %s" % body)
	body.remove_hp(damage)
	queue_free()

func _process(delta):
	if position.y > get_node("../SceneParameters").max_y + 100:
		#print("SpitBullet._process: bullet outside window")
		queue_free()