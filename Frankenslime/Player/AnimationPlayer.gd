extends AnimationPlayer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

#func _ready():
#onready var anim_node = get_node("BodySprite/AnimationPlayer")

var is_ready = false

func change_animation(anim_state, anim_node):
	
	if anim_state == "spit":
		anim_node.play(anim_state)
		
	if anim_state != anim_node.assigned_animation:
#	anim_node.stop()
		#print("animstate is: " + anim_state)
		#print("assigned anim is: " + anim_node.assigned_animation)
#		local_anim_node = anim_node
		#print("current anim is: " + anim_node.current_animation)
		anim_node.play(anim_state)
#	print("current anim is: " + anim_node.current_animation)
		
func _ready():
	#$Animator.connect("animation_finished", self, "_on_Animator_animation_finished")
	pass
	
	
	
func _on_AnimatedSprites_animation_finished(anim_name):
	print("anim sprite stopped: " + anim_name)
	if anim_name == "spit":
#		get_parent().stop(true)
		print(get_parent())
#
func _on_Animator_animation_finished(anim_name):
	print("anim player stopped: " + anim_name)
	if anim_name == "spit":
		get_parent().stop(true)
		print(get_parent())

	
#	print("finished anim: " + anim_name)
#	if get_parent().get_parent().anim_state == anim_name:
#		print("in loop")
#		self.stop(true)
#		print("spit anim stopped")
#		get_parent().get_parent()._process(get_process_delta_time())
#		change_animation("idle", local_anim_node)
		
		
	

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
#	if not is_ready:
#		if $Animator != null:
#			$Animator.connect("animation_finished", self, "_on_Animator_animation_finished")
#			is_ready = true

#func _on_AnimatedSprites_animation_finished(anim):
#	if anim == "spit":
#		print("spit anim finished")
#		change_animation("idle", self)
#	get_parent().get_parent().anim_state
