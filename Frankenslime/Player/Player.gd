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

onready var anim_node = get_node("AnimatedSprites/Animator")
onready var anim_state = ""

var dead = false
var h_flipper = false
var weapon = "spit"
var weapon_node = null

var latest_save_pos = 0
var min_save_pos = 0 # The leftmost position of the walkable window
var oneshot = ""
var motion = Vector2()
onready var scene = get_parent().get_node("SceneParameters")
	
func _ready():
	emit_signal("changed_player_hp", HP, max_HP)
	$AnimatedSprites.connect("animation_finished", self, "_on_AnimatedSprites_animation_finished")

func _on_AnimatedSprites_animation_finished():
	print("[finished] assigned anim: %s" % get_node("AnimatedSprites/Animator").assigned_animation)
	var fin_name = get_node("AnimatedSprites/Animator").assigned_animation
	print("fin name: " + fin_name)
	if fin_name == "spit":
		anim_state = "idle"
		anim_node.change_animation(anim_state, anim_node)

func get_input():
	motion = Vector2(0,0)
	if dead:
		return
	if Input.is_action_pressed("ui_right"):
		motion.x = horizontal_speed
		h_flipper = false
		anim_state = "hop"
	if Input.is_action_pressed("ui_left"):
		motion.x = -horizontal_speed
		h_flipper = true
		anim_state = "hop"
	if Input.is_action_pressed("ui_up"):
		motion.y = -vertical_speed
		anim_state = "hop"
	if Input.is_action_pressed("ui_down"):
		motion.y = vertical_speed
		anim_state = "hop"
	if Input.is_action_pressed("action_jump"):
		jump()
	if Input.is_action_pressed("action_shoot"):
		if $AttackTimer.is_stopped():
			anim_state = "spit"
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
					get_node("../GameDirector").add_points(1)
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
	#print ("min_save_pos: " + str(min_save_pos) + " min_last_pos: " +  str(min_last_pos) + " player position: " + str(position.x))
	get_node("Camera2D").limit_left = min_save_pos
	
	#adding some 45px threshold offsets to the right in order to trigger conditionals walking to left screen edge.
	#(prolly around 2x20px screen border or so difference in actual viewport/window width)
	if position.x < min_save_pos + 45:
		#print ("positions in left-loop: min_save_pos: " + str(min_save_pos) + " min_last_pos: " +  str(min_last_pos) + " player position: " + str(position.x))
		position.x = min_save_pos + 45
		#print(get_viewport().size.x)
	
	if min_save_pos - latest_save_pos > get_viewport().size.x:
		#print("Player.camera_and_lookback: Moved one screen worth of pixels to the right")
		latest_save_pos = min_save_pos
		get_node("../GameDirector").add_points(1)
	
func launch_attack():
	#print("launch_attack")
	if weapon == "spit":
		var bullet = spit_bullet_scene.instance()
		get_parent().add_child(bullet)
		bullet.h_flipper = h_flipper
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

	get_node("AnimatedSprites").flip_h = h_flipper
	if weapon_node != null:
		weapon_node.get_node("BodySprite").flip_h = h_flipper
	
func take_damage(damage):
	remove_hp(damage)
	
func remove_hp(damage):
	HP -= damage
	emit_signal("changed_player_hp", HP, max_HP)
	if HP <= 0:
		dead = true
		hide()
		get_node("../GameDirector").game_over()
		
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
	
func _process(delta):
	if anim_state == "spit":
		anim_node.change_animation(anim_state, anim_node)
	elif anim_state != "" and motion != Vector2(0, 0):
		anim_node.change_animation(anim_state, anim_node)
	elif motion == Vector2(0,0):
		print("motionvector is 0, 0")
		anim_state = "idle"
		anim_node.change_animation(anim_state, anim_node)
