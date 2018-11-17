extends Node

signal points_changed(points)

var current_points = 0

func add_points(points):
	current_points += points
	emit_signal("points_changed", current_points)