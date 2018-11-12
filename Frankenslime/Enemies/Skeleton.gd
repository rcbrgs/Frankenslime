extends KinematicBody2D

func remove_hp(damage):
	$Enemy/Health.remove_hp(damage)
	
func shoot():
	print("Skeleton.shoot()")
	