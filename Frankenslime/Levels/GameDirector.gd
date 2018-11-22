extends Node

signal points_changed(points)

export (float) var prob_yield_limb = 0.1

var current_points = 0

func add_points(points):
	current_points += points
	emit_signal("points_changed", current_points)
	
func despawn(enemy_health):
	var chance = randf()
	if chance < prob_yield_limb:
		enemy_health.yield_limb()
		return
