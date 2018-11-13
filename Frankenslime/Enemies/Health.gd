extends Node

onready var bone_shotgun_scene = preload("res://Limbs/BoneShotgun.tscn")

var HP = 1
onready var father = get_parent().get_parent()
onready var level = father.get_parent()

func remove_hp(damage):
	HP -= damage
	if HP <= 0:
		yield_limb()
		father.queue_free()
		
func yield_limb():
	var limb_type = father.limb_type
	if limb_type == "BoneShotgun":
		var initial_position = father.position
		#print("Yielding a BoneShotgun at %s" % initial_position)
		var bone_shotgun = bone_shotgun_scene.instance()
		level.add_child(bone_shotgun)
		bone_shotgun.translate(initial_position)
		bone_shotgun.rotate(PI/4)