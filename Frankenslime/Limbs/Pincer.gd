extends KinematicBody2D

export (int) var damage = 3
export (float) var fire_interval = 2

onready var weapon_scene = preload("res://Limbs/Pincer.tscn")

func wield(new_parent):
	var weapon = weapon_scene.instance()
	weapon.set_collision_layer_bit(5, false) # no longer a limb
	weapon.set_collision_layer_bit(0, true)
	new_parent.add_child(weapon)
	new_parent.weapon_node = weapon
	queue_free()
	new_parent.connect("unwield_weapon", weapon, "_on_Player_unwield_weapon")
	return "pincer"
	
func _on_Player_unwield_weapon():
	queue_free()
	
func _process(delta):
	var collisions = get_slide_count()
	if collisions != 0:
		print("collisions = %d" % collisions)
		
func shoot():
	var opponent = get_node("..")
	var player = get_node("../../Player")
	var distance = player.position.distance_to(opponent.position)
	#print("Crab.shoot(): distance = %f, player.position = %s, opponent.position = %s" % [distance, player.position, opponent.position])
	if distance < 50:
		player.remove_hp(damage)