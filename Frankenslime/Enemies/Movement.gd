extends Node

enum behaviours { idle, attacking, fleeing }

var behaviour
var initial_position

export (int) var wander_range_x
export (int) var wander_step_x
export (int) var wander_step_y
export (float) var wander_wait_time = 1

func _ready():
	initial_position = get_parent().get_parent().position

func _process(delta):
	# update behaviour
	behaviour = behaviours.idle
	
	# act according to behaviour
	if behaviour == behaviours.idle:
		if $WanderTimer.is_stopped():
			wander()
			$WanderTimer.set_wait_time(wander_wait_time)
			$WanderTimer.start()
		
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
	en.move_and_collide(wander)
	en.position.x = clamp(en.position.x, initial_position.x - wander_range_x, initial_position.x + wander_range_x)
