extends Node

export (int) var HP_multiplier = 3
export (float) var interval_between_spawns = 3

var total_enemy_HP = 0

onready var skeleton_scene = preload("res://Enemies/Skeleton.tscn")
onready var crab_scene = preload("res://Enemies/Crab.tscn")
onready var player = get_node("../Player")

func _process(delta):
	# Should we spawn an enemy?
	if not $SpawnTimer.is_stopped():
		return
	if ! weakref(player).get_ref():
		return
	#print("total_enemy_HP = %d" % total_enemy_HP)
	if total_enemy_HP > HP_multiplier * player.HP:
		return
	spawn_an_enemy()

func spawn_an_enemy():
	#print("Spawn an enemy.")
	$SpawnTimer.set_wait_time(interval_between_spawns)
	$SpawnTimer.start()
	var coin = round(randf())
	var initial_position = Vector2(0,0)
	var initial_position_y = randf() * (get_node("../SceneParameters").max_y - get_node("../SceneParameters").min_y) + get_node("../SceneParameters").min_y
	if coin == 0:
		initial_position = Vector2(get_node("../SceneParameters").min_x + 10, initial_position_y)
	else:
		initial_position = Vector2(get_node("../SceneParameters").max_x - 10, initial_position_y)
	#print("Spawn an enemy at %s." % initial_position)
	# choose enemy type
	var enemy
	coin = round(randf())
	if coin == 0:
		enemy = skeleton_scene.instance()
	else:
		enemy = crab_scene.instance()
	get_parent().add_child(enemy)
	enemy.translate(initial_position)
	enemy.get_node("Enemy/Movement").set_initial_position (initial_position)
	total_enemy_HP += enemy.HP