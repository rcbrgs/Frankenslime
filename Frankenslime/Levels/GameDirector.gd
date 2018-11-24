extends Node

signal points_changed(points)

export (float) var prob_yield_limb = 0.1

var current_points = 0

func _ready():
	game_start()
	
func game_start():
	var label = get_node("../CanvasLayer/GUI/VBoxContainer/CenterContainer2/GameOverLabel")
	label.hide()

func add_points(points):
	current_points += points
	emit_signal("points_changed", current_points)
	
func despawn(enemy_health):
	var chance = randf()
	if chance < prob_yield_limb:
		enemy_health.yield_limb()
		return

func game_over():
	var label = get_node("../CanvasLayer/GUI/VBoxContainer/CenterContainer2/GameOverLabel")
	label.show()
	