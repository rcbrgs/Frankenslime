extends KinematicBody2D

export (int) var HP = 3

var limb_type = "Pincer"

func _ready():
	get_node("Enemy/Movement").attack_move_wait_time = 0.02

func remove_hp(damage):
	$Enemy/Health.remove_hp(damage)
	
func shoot():
	#print("Skeleton.shoot()")
	#$BoneBulletWrapper.collision_layer = 4
	#$BoneBulletWrapper.collision_layer_bit = true
	#$BoneBulletWrapper.shoot()
	pass