extends Node

onready var bone_shotgun_scene = preload("res://Limbs/BoneShotgun.tscn")
onready var pincer_scene = preload("res://Limbs/Pincer.tscn")

onready var father = get_parent().get_parent()
onready var level = father.get_parent()
onready var max_HP = father.HP

func remove_hp(damage):
	father.HP -= damage
	if father.HP <= 0:
		yield_limb()
		level.get_node("AIDirector").total_enemy_HP -= max_HP
		level.get_node("GameDirector").add_points(max_HP)
		print("Health.remove_hp: enemy died at %s" % father.position)
		father.queue_free()
		
func yield_limb():
	var limb_type = father.limb_type
	var initial_position = father.position
	var weapon
	if limb_type == "BoneShotgun":
		weapon = bone_shotgun_scene.instance()
		weapon.rotate(PI/4)
	if limb_type == "Pincer":
		weapon = pincer_scene.instance()
	level.add_child(weapon)
	weapon.translate(initial_position)
	weapon.set_owner(level)