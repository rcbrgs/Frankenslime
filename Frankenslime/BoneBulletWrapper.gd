extends Node

onready var bone_bullet_scene = preload("res://Bullets/BoneBullet.tscn")

func shoot():
	var bone_up = bone_bullet_scene.instance()
	var bone_mid = bone_bullet_scene.instance()
	var bone_down = bone_bullet_scene.instance()
	get_parent().get_parent().add_child(bone_up)
	get_parent().get_parent().add_child(bone_mid)
	get_parent().get_parent().add_child(bone_down)
	bone_up.position = get_parent().position
	bone_mid.position = get_parent().position
	bone_down.position = get_parent().position
	if get_parent().get_node("Enemy/Movement").facing_right:
		bone_up.direction = Vector2(1,1)
		bone_mid.direction = Vector2(1,0)
		bone_down.direction = Vector2(1,-1)
	else:
		bone_up.direction = Vector2(-1,1)
		bone_mid.direction = Vector2(-1,0)
		bone_down.direction = Vector2(-1,-1)
	bone_up.impulse()
	bone_mid.impulse()
	bone_down.impulse()
	