extends KinematicBody2D

var is_melee = false
var is_ranged = true

export (bool) var being_wielded = false
export (float) var fire_interval = 0.5

onready var bone_shotgun_scene = preload("res://Limbs/BoneShotgun.tscn")

func wield(new_parent):
	var bone_shotgun = bone_shotgun_scene.instance()
	bone_shotgun.set_collision_layer_bit(5, false) # no longer a limb
	new_parent.add_child(bone_shotgun)
	new_parent.weapon_node = bone_shotgun
	queue_free()
	new_parent.connect("unwield_weapon", bone_shotgun, "_on_Player_unwield_weapon")
	return "bone_shotgun"
	
func _on_Player_unwield_weapon():
	queue_free()
	#print("queue_free on unwield")