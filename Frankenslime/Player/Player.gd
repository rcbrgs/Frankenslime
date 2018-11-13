extends KinematicBody2D

export (int) var HP = 3
export (float) var attack_interval = 1.5
export (int) var horizontal_speed = 5
export (int) var vertical_speed = 2

onready var bone_bullet_wrapper_scene = preload("res://Bullets/BoneBulletWrapper.tscn")
onready var spit_bullet_scene = preload("res://Bullets/SpitBullet.tscn")

var facing_right = false
var weapon = "spit"
var weapon_node = null

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
		#print("collision.collider = %s" % collision.collider)
		#print("collision.collider.name = %s" % collision.collider.name)
		#print("collision.collider.get_class() = %s" % collision.collider.get_class())
		#if collision.collider.name == "BoneShotgun":
		if collision.collider.get_parent() != self:
			if collision.collider.has_method("wield"):
				weapon = collision.collider.wield(self)
	
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
	if HP <= 0:
		hide()