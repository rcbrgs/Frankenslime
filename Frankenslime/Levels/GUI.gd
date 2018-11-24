extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	get_node("../../Player").connect("changed_player_hp", self, "_on_Player_hp_changed")
	var hp = get_node("../../Player").HP
	var max_hp = get_node("../../Player").max_HP
	get_node("VBoxContainer/HBoxContainer/MarginContainer/HBoxContainer/Background/Number").text = str(hp)
	get_node("VBoxContainer/HBoxContainer/MarginContainer/HBoxContainer/HPProgressBar").value = hp
	get_node("VBoxContainer/HBoxContainer/MarginContainer/HBoxContainer/HPProgressBar").max_value = max_hp
	
	#current points
	get_node("../../GameDirector").connect("points_changed", self, "_on_GameDirector_points_changed")

func _on_Player_hp_changed(hp, max_hp):
	#print("_on_Player_hp_changed")
	get_node("VBoxContainer/HBoxContainer/MarginContainer/HBoxContainer/Background/Number").text = str(hp)
	get_node("VBoxContainer/HBoxContainer/MarginContainer/HBoxContainer/HPProgressBar").value = hp
	get_node("VBoxContainer/HBoxContainer/MarginContainer/HBoxContainer/HPProgressBar").max_value = max_hp
	
func _on_GameDirector_points_changed(points):
	get_node("VBoxContainer/HBoxContainer/MarginContainer/HBoxContainer/CurrentPoints").text = str(points)