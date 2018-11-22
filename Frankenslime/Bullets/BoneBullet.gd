extends RigidBody2D

export (int) var damage = 1
export (float) var speed = 1750
export (float) var fire_interval = 0.3

var direction = Vector2(0,0)

func impulse():
	#print("impulse %s at %s" % [direction, position] )
	apply_impulse(Vector2(0,0), direction * speed)
	$AnimatedSprite.show()

func _on_BoneBullet_body_entered(body):
	body.remove_hp(damage)
	queue_free()
	
func _process(delta):
	if position.y > get_node("../SceneParameters").max_y + 100:
		#print("BoneBullet._process: bullet outside window")
		queue_free()
		
func do_damage(body):
	body.take_damage(damage)
	queue_free()