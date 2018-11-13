extends KinematicBody2D

var limb_type = "BoneShotgun"

func remove_hp(damage):
	$Enemy/Health.remove_hp(damage)
	
func shoot():
	#print("Skeleton.shoot()")
	$BoneBulletWrapper.collision_layer = 4
	$BoneBulletWrapper.collision_layer_bit = 16
	$BoneBulletWrapper.shoot()