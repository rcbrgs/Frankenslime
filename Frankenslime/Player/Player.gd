extends KinematicBody2D

signal changed_player_hp(hp, max_hp)
signal unwield_weapon()

export (int) var max_HP = 3
export (float) var attack_interval = 0.1
export (int) var horizontal_speed = 10
export (int) var vertical_speed = 10

onready var bone_bullet_wrapper_scene = preload("res://Bullets/BoneBulletWrapper.tscn")
onready var spit_bullet_scene = preload("res://Bullets/SpitBullet.tscn")
onready var HP = max_HP

var facing_right = false
var weapon = "spit"
var weapon_node = null

var min_save_pos = 0
var min_last_pos = 0

func _ready():
	emit_signal("changed_player_hp", HP, max_HP)

func _physics_process(delta):
	var motion = Vector2()
	
	motion = Vector2(0,0)
	if Input.is_action_pressed("ui_right"):
		motion.x = horizontal_speed
		facing_right = true
	if Input.is_action_pressed("ui_left"):
		motion.x = -horizontal_speed
		facing_right = false
	if Input.is_action_pressed("ui_up"):
		motion.y = -vertical_speed
	if Input.is_action_pressed("ui_down"):
		motion.y = vertical_speed
	set_facing()
	var collision = move_and_collide(motion)
	if collision != null: 
		if collision.collider.get_parent() != self:
			if collision.collider.has_method("wield"):
				unwield()
				weapon = collision.collider.wield(self)
				
	# Clamp player to scene and forward moving camera2D
	# only clamping y position for vertical range. x-movement clamping is done in func camera_and_lookback()
	var scene = get_parent().get_node("SceneParameters")
	camera_and_lookback()
	position.y = clamp(position.y, scene.min_y, scene.max_y)

func camera_and_lookback():
	# general: good practice -> dont check stuff inside delta+input conditionals directly.
	# hinders performance. moving stuff out of input event conditional works.
	# first condition saves pos half a screen behind current player pos for use in limit_left of Camera2D.
	# and second condition ensures offset so that player gets blocked from movement at left screen-edge
	# (instead of directly after turning left from middle of screen)
	if self.position.x + (get_viewport().size.x / 2) > min_save_pos and (position.x - (get_viewport().size.x / 2) > min_save_pos):
		min_save_pos = self.position.x - (get_viewport().size.x / 2)
		min_last_pos = self.position.x
	#print ("min_save_pos: " + str(min_save_pos) + " min_last_pos: " +  str(min_last_pos) + " player position: " + str(position.x))
	min_last_pos = int(min_last_pos)
	get_node("Camera2D").limit_left = min_save_pos
	
	#adding some 45px threshold offsets to the right in order to trigger conditionals walking to left screen edge.
	#(prolly around 2x20px screen border or so difference in actual viewport/window width)
	if position.x < min_save_pos + 45:
		#print ("positions in left-loop: min_save_pos: " + str(min_save_pos) + " min_last_pos: " +  str(min_last_pos) + " player position: " + str(position.x))
		position.x = min_save_pos + 45
		#print(get_viewport().size.x)
		
	# Attack
	if Input.is_action_pressed("ui_select"):
		if $AttackTimer.is_stopped():
			launch_attack()
			$AttackTimer.set_wait_time(attack_interval)
			$AttackTimer.start()
	
func launch_attack():
	#print("launch_attack")
	if weapon == "spit":
		var bullet = spit_bullet_scene.instance()
		get_parent().add_child(bullet)
		bullet.facing_right = facing_right
		bullet.set_initial_position(position)
		bullet.set_collision_layer_bit(3, 8) # set layer as BulletsFromPlayer
	if weapon == "bone_shotgun":
		var bullet = bone_bullet_wrapper_scene.instance()
		add_child(bullet)
		bullet.collision_layer = 3
		bullet.collision_layer_bit = 8
		bullet.shoot()
	
func set_facing():
	get_node("BodySprite").flip_h = facing_right
	if weapon_node != null:
		weapon_node.get_node("AnimatedSprite").flip_h = facing_right
	
func remove_hp(damage):
	HP -= damage
	emit_signal("changed_player_hp", HP, max_HP)
	if HP <= 0:
		hide()
		
func unwield():
	weapon = "spit"
	emit_signal("unwield_weapon")