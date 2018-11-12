extends KinematicBody2D

export (int) var horizontal_speed = 5
export (int) var vertical_speed = 2

func _ready():
	pass

func _process(delta):
	pass

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