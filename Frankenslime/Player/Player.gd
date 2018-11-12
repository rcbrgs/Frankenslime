extends KinematicBody2D

export (float) var attack_interval = 1.5
export (int) var horizontal_speed = 5
export (int) var vertical_speed = 2

onready var spit_bullet_scene = preload("res://Bullets/SpitBullet.tscn")

func _physics_process(delta):
	var motion = Vector2()
	
	motion = Vector2(0,0)
	if Input.is_action_pressed("ui_right"):
		motion.x = horizontal_speed
	if Input.is_action_pressed("ui_left"):
		motion.x = -horizontal_speed
	if Input.is_action_pressed("ui_up"):
		motion.y = -vertical_speed
	if Input.is_action_pressed("ui_down"):
		motion.y = vertical_speed
	var collisions = move_and_collide(motion)
	
	# Clamp player to scene
	var scene = get_parent().get_node("SceneParameters")
	position.x = clamp(position.x, scene.min_x, scene.max_x)
	position.y = clamp(position.y, scene.min_y, scene.max_y)
	
	# Attack
	if Input.is_action_pressed("ui_select"):
		if $AttackTimer.is_stopped():
			launch_attack()
			$AttackTimer.set_wait_time(attack_interval)
			$AttackTimer.start()
	
func launch_attack():
	#print("launch_attack")
	var bullet = spit_bullet_scene.instance()
	get_parent().add_child(bullet)
	bullet.set_initial_position(position)
	bullet.set_collision_layer_bit(3, 8) # set layer as BulletsFromPlayer