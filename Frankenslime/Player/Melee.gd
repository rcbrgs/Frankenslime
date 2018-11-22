extends Node

func activate():
	if $BeginActionTimer.is_stopped():
		get_parent().weapon_node.get_node("AnimatedSprite").play("attacking")
		get_parent().melee_active = true
		$BeginActionTimer.set_wait_time(get_parent().weapon_node.melee_interval)
		$BeginActionTimer.start()

func _on_BeginActionTimer_timeout():
	get_parent().weapon_node.get_node("AnimatedSprite").play("default")
	get_parent().melee_active = false
