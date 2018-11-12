extends RigidBody2D

export (int) var damage = 1
export (float) var speed = 500

var direction = Vector2(0,0)

func impulse():
	#print("impulse %s at %s" % [direction, position] )
	apply_impulse(Vector2(0,0), direction * speed)
	$AnimatedSprite.show()

func _on_BoneBullet_body_entered(body):
	body.remove_hp(damage)
	queue_free()