extends Node

var HP = 3

func remove_hp(damage):
	HP -= damage
	if HP <= 0:
		get_parent().get_parent().queue_free()