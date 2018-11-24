extends KinematicBody2D

export (int) var HP = 2

var limb_type = "Pincer"
onready var weapon_node = get_node("Pincer")

func _ready():
	get_node("Enemy/Movement").attack_move_wait_time = 0.02

func remove_hp(damage):
	$Enemy/Health.remove_hp(damage)
	
func shoot():
	$Pincer.shoot()