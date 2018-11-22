extends KinematicBody2D

signal changed_player_hp(hp, max_hp)
signal unwield_weapon()

export (int) var jump_height = 250
export (int) var jump_speed = 25
export (int) var max_HP = 3
export (float) var melee_interval = 1
export (float) var spit_attack_interval = 0.5
export (int) var horizontal_speed = 500
export (int) var vertical_speed = 250

onready var bone_bullet_wrapper_scene = preload("res://Bullets/BoneBulletWrapper.tscn")
onready var spit_bullet_scene = preload("res://Bullets/SpitBullet.tscn")
onready var HP = max_HP

var dead = false
var facing_right = false
var weapon = "spit"
var weapon_node = null

var latest_save_pos = 0
var min_save_pos = 0 # The leftmost position of the walkable window
var min_last_pos = 0
var motion = Vector2()
onready var scene = get_parent().get_node("SceneParameters")
	
func _ready():
	emit_signal("changed_player_hp", HP, max_HP)

func get_input():
	motion = Vector2(0,0)
	if dead:
		return
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
	if Input.is_action_pressed("action_jump"):
		jump()
	if Input.is_action_pressed("action_shoot"):
		if $AttackTimer.is_stopped():
			launch_attack()
			var attack_interval = spit_attack_interval
			if weapon_node != null:
				attack_interval = weapon_node.fire_interval
			$AttackTimer.set_wait_time(attack_interval)
			$AttackTimer.start()

func _physics_process(delta):
	get_input()
	set_facing()
	var collision = move_and_collide(motion * delta)
	if collision != null: 
		if collision.collider.get_parent() != self:
			if collision.collider.has_method("wield"):
				if collision.collider.being_wielded == false:
					unwield()
					weapon = collision.collider.wield(self)
			elif collision.collider.has_method("remove_hp"):
				if $Melee.melee_active:
					print("Player._physics_process: melee hit")
					collision.collider.remove_hp(weapon_node.damage)
					$Melee.melee_active = false
			elif collision.collider.has_method("do_damage"):
				collision.collider.do_damage(self)
			else:
				print("Player._physics_process: untreated collision with %s" % collision.collider.name)
				
	# Clamp player to scene and forward moving camera2D
	# only clamping y position for vertical range. x-movement clamping is done in func camera_and_lookback()
	camera_and_lookback()
	# jump
	if jumping:
		#print("jumping")
		if position.y <= jump_y:
			jumping = false
			falling = true
		else:
			position.y -= jump_speed
	if falling:
		#print("falling")
		if position.y >= jump_initial_y:
			falling = false
		else:
			position.y += jump_speed
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
	
	if min_save_pos - latest_save_pos > get_viewport().size.x:
		print("Moved one screen worth of pixels to the right")
		latest_save_pos = min_save_pos
		get_node("../GameDirector").add_points(1)
	
func launch_attack():
	#print("launch_attack")
	if weapon == "spit":
		var bullet = spit_bullet_scene.instance()
		get_parent().add_child(bullet)
		bullet.facing_right = facing_right
		bullet.set_initial_position(position)
		bullet.set_collision_layer_bit(3, 8) # set layer as BulletsFromPlayer
		return
	if weapon == "bone_shotgun":
		var bullet = bone_bullet_wrapper_scene.instance()
		add_child(bullet)
		bullet.collision_layer = 3
		bullet.collision_layer_bit = 8
		bullet.shoot()
	if weapon == "pincer":
		$Melee.activate()
	if weapon_node.has_node("ShootSound"):
		weapon_node.get_node("ShootSound").play()
	
func set_facing():
	get_node("BodySprite").flip_h = facing_right
	if weapon_node != null:
		weapon_node.get_node("AnimatedSprite").flip_h = facing_right
	
func take_damage(damage):
	remove_hp(damage)
	
func remove_hp(damage):
	HP -= damage
	emit_signal("changed_player_hp", HP, max_HP)
	if HP <= 0:
		dead = true
		hide()
		
func unwield():
	weapon = "spit"
	emit_signal("unwield_weapon")

var jumping = false
var falling = false
var jump_y = 0
var jump_initial_y = 0

func jump():
	if $JumpTimer.is_stopped():
		#print("Player.jump()")
		$JumpTimer.set_wait_time(1)
		$JumpTimer.start()
		jump_initial_y = position.y
		jump_y = position.y - jump_height
		jump_y = clamp(jump_y, scene.min_y, scene.max_y)
		jumping = true
	