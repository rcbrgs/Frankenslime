extends KinematicBody2D

signal changed_player_hp(hp, max_hp)
signal unwield_weapon()

export (int) var max_HP = 3
export (float) var attack_interval = 1.5
export (int) var horizontal_speed = 5
export (int) var vertical_speed = 2
export (float) var melee_interval = 1

onready var bone_bullet_wrapper_scene = preload("res://Bullets/BoneBulletWrapper.tscn")
onready var spit_bullet_scene = preload("res://Bullets/SpitBullet.tscn")
onready var HP = max_HP

var facing_right = false
var weapon = "spit"
var weapon_node = null
var melee_active = false

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
			elif collision.collider.has_method("remove_hp"):
				if melee_active:
					print("melee hit")
					collision.collider.remove_hp(weapon_node.damage)
					melee_active = false
			else:
				print("untreated collision: Player and %s" % collision.collider.name)
	
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
	if weapon == "pincer":
		if $MeleeTimer.is_stopped():
			#weapon_node.set_collision_mask_bit(1, true)
			weapon_node.get_node("AnimatedSprite").play("attacking")
			melee_active = true
			$MeleeTimer.set_wait_time(melee_interval)
			$MeleeTimer.start()
	
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

func _on_MeleeTimer_timeout():
	#weapon_node.set_collision_mask_bit(1, false)
	weapon_node.get_node("AnimatedSprite").play("default")
	melee_active = false