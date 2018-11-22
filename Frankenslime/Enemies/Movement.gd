extends Node

enum behaviours { idle, attacking, fleeing }

export (float) var attack_wait_time = 2
export (int) var attack_move_speed = 150
export (float) var attack_move_wait_time = 0.05
export (int) var speed = 1
export (float) var vision_radius = 500
export (float) var wander_direction_interval = 3
export (int) var wander_speed = 100

onready var enemy = get_parent().get_parent()
onready var player = get_parent().get_parent().get_parent().get_node("Player")
onready var scene = get_node("../../../SceneParameters")

var latest_wander_direction = Vector2(0,0)

func enemy_outside_window():
	if enemy.position.x < get_node("../../../Player").min_save_pos - 100:
		return true
	if enemy.position.x > get_node("../../../Player").min_save_pos + get_viewport().size.x + 100:
		return true
	return false

func _physics_process(delta):
	if enemy_outside_window():
		print("Movement:_physics_process: freeing at %s for min_save_pos %s" % [enemy.position, get_node("../../../Player").min_save_pos])
		get_node("../../../AIDirector").total_enemy_HP -= get_node("../Health").max_HP
		enemy.queue_free()
		return
	
	var behaviour = behaviours.idle
	var direction = Vector2(0,0)
	var motion = Vector2(0,0)
		
	behaviour = decide_behaviour()
	if behaviour == behaviours.idle:
		direction = wander()
		motion = direction * wander_speed
	if behaviour == behaviours.attacking:
		direction = (player.position - enemy.position).normalized()
		motion = direction * attack_move_speed
		launch_attack()
	
	set_facing(enemy.position, enemy.position + motion * delta)
	enemy.move_and_collide(motion * delta)
	clamp_to_playing_field()
	
func clamp_to_playing_field():
	enemy.position.y = clamp(enemy.position.y, scene.min_y, scene.max_y)

func launch_attack():
	if $AttackTimer.is_stopped():
		enemy.shoot()
		$AttackTimer.set_wait_time(attack_wait_time)
		$AttackTimer.start()

func decide_behaviour():
	var behaviour = behaviours.idle
	# can we see player?
	if player != null:
		if not player.dead:
			var distance = enemy.position.distance_to(player.position)
			if distance < vision_radius:
				behaviour = behaviours.attacking
	return behaviour

func wander():
	if $WanderTimer.is_stopped():
		var new_direction = Vector2(0,0)
		new_direction.x = -1 + 2 * randf()
		new_direction.y = -1 + 2 * randf()
		latest_wander_direction = new_direction
		$WanderTimer.set_wait_time(wander_direction_interval)
		$WanderTimer.start()
	return latest_wander_direction.normalized()

var facing_right = false
func set_facing(origin, destiny):
	if destiny.x - origin.x > 0: # moving to the right
		facing_right = true
	else:
		facing_right = false
			
	get_parent().get_parent().get_node("BodySprite").flip_h = facing_right
	if not get_parent().get_parent().has_node("Weapon"):
		return
	get_parent().get_parent().get_node("Weapon").get_node("AnimatedSprite").flip_h = facing_right