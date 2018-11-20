extends AnimationPlayer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

#func _ready():
#onready var anim_node = get_node("BodySprite/AnimationPlayer")

func change_animation(anim_state, anim_node):
	if anim_state != anim_node.current_animation:
		print(anim_state + " " + anim_node.assigned_animation)
		anim_node.play(anim_state)
#		anim_node.current_animation = anim_state
		
#		var animation = self.get_animation(anim_state)
		
	

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
