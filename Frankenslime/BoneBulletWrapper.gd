extends Node

export (float) var slantedness = 0.15
#export (float) var fire_interval = 1

onready var bone_bullet_scene = preload("res://Bullets/BoneBullet.tscn")
var collision_layer = 3
var collision_layer_bit = 8

func shoot():
	var bone_up = bone_bullet_scene.instance()
	var bone_mid = bone_bullet_scene.instance()
	var bone_down = bone_bullet_scene.instance()
	bone_up.set_collision_layer_bit(collision_layer, collision_layer_bit)
	bone_mid.set_collision_layer_bit(collision_layer, collision_layer_bit)
	bone_down.set_collision_layer_bit(collision_layer, collision_layer_bit)
	get_parent().get_parent().add_child(bone_up)
	get_parent().get_parent().add_child(bone_mid)
	get_parent().get_parent().add_child(bone_down)
	bone_up.position = get_parent().position + Vector2(0, 50)
	bone_mid.position = get_parent().position 
	bone_down.position = get_parent().position + Vector2(0, -50)
	var h_flipper = false
	if get_parent().has_node("Enemy/Movement"):
		var move_scene = get_parent().get_node("Enemy/Movement") 
		h_flipper = move_scene.h_flipper
	else:
		h_flipper = get_parent().h_flipper
	if h_flipper:
		bone_up.direction = Vector2(1, slantedness)
		bone_mid.direction = Vector2(1,0)
		bone_down.direction = Vector2(1, -slantedness)
	else:
		bone_up.direction = Vector2(-1, slantedness)
		bone_mid.direction = Vector2(-1,0)
		bone_down.direction = Vector2(-1, -slantedness)
	bone_up.impulse()
	bone_mid.impulse()
	bone_down.impulse()
	