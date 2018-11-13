extends KinematicBody2D

onready var bone_shotgun_scene = preload("res://Limbs/BoneShotgun.tscn")

func wield(new_parent):
	var bone_shotgun = bone_shotgun_scene.instance()
	bone_shotgun.set_collision_layer_bit(5, false) # no longer a limb
	new_parent.add_child(bone_shotgun)
	new_parent.weapon_node = bone_shotgun
	queue_free()
	return "bone_shotgun"