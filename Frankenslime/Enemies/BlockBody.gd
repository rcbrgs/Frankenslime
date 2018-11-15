extends KinematicBody2D

func remove_hp(damage):
	get_parent().remove_hp(damage)
	