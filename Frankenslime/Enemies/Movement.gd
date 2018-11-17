extends Node

enum behaviours { idle, attacking, fleeing }

var behaviour
var initial_position

export (float) var attack_wait_time = 2
export (int) var attack_move_speed = 5
export (float) var attack_move_wait_time = 0.05
export (float) var vision_radius = 400
export (int) var wander_range_x
export (int) var wander_step_x
export (int) var wander_step_y
export (float) var wander_wait_time = 1

onready var enemy = get_parent().get_parent()
onready var player = get_parent().get_parent().get_parent().get_node("Player")

func set_initial_position(pos):
	initial_position = pos
	#print("initial_position = %s" % initial_position)

func enemy_outside_window():
	if enemy.position.x < get_node("../../../Player").min_save_pos:
		#print("freeing at %s for min_save_pos %s" % [enemy.position, get_node("../../../Player").min_save_pos])
		return true
	return false

func _physics_process(delta):
	if enemy_outside_window():
		#print("freeing enemy outside window")
		get_node("../../../AIDirector").total_enemy_HP -= get_node("../Health").max_HP
		queue_free()
		return
	# update behaviour
	behaviour = behaviours.idle
	# can we see player?
	if player != null:
		var distance = enemy.position.distance_to(player.position)
		if distance < vision_radius:
			behaviour = behaviours.attacking
	
	# act according to behaviour
	if behaviour == behaviours.idle:
		if $WanderTimer.is_stopped():
			wander()
			$WanderTimer.set_wait_time(wander_wait_time)
			$WanderTimer.start()
			
	if behaviour == behaviours.attacking:
		#print("attacking")
		initial_position = get_parent().get_parent().position		
		#move towards player
		if $AttackMoveTimer.is_stopped():
			var direction = Vector2(-1,-1)
			#direction = player.position - enemy.position
			if player.position.x > enemy.position.x:
				direction.x = 1
			if player.position.y > enemy.position.y:
				direction.y = 1
			set_facing(enemy.position, enemy.position + direction * attack_move_speed)
			enemy.position += direction * attack_move_speed
			$AttackMoveTimer.set_wait_time(attack_move_wait_time)
			$AttackMoveTimer.start()
		#try to shoot
		if $AttackTimer.is_stopped():
			enemy.shoot()
			$AttackTimer.set_wait_time(attack_wait_time)
			$AttackTimer.start()
		
func wander():
	var wander = Vector2(0,0)
	var coin = round(randf())
	if coin == 1:
		var dir = round(randf())
		if dir == 1:
			wander.x = wander_step_x
		else:
			wander.x = -wander_step_x
	coin = round(randf())
	if coin == 1:
		var dir = round(randf())
		if dir == 1:
			wander.y = wander_step_y
		else:
			wander.y = -wander_step_y
	# Move the enemy
	var en = get_parent().get_parent()
	set_facing(en.position, en.position + wander)
	en.position += wander
	en.position.x = clamp(en.position.x, initial_position.x - wander_range_x, initial_position.x + wander_range_x)
	var scene_params = get_node("../../../SceneParameters")
	#en.position.x = clamp(en.position.x, scene_params.min_x, scene_params.max_x)

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