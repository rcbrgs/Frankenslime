extends Node

var father = null
var melee_active = false

func _ready():
	if get_parent().name == "Enemy":
		father = get_parent().get_parent()
	else:
		father = get_parent()
	#print("Melee._ready: father.name = %s" % father.name)

func activate():
	if not father.weapon_node.is_melee:
		return
	if not $InterActionTimer.is_stopped():
		return
	if $BeginActionTimer.is_stopped():
		father.weapon_node.get_node("AnimatedSprite").play("attacking")
		melee_active = true
		$BeginActionTimer.set_wait_time(father.weapon_node.melee_duration)
		$BeginActionTimer.start()

func _on_BeginActionTimer_timeout():
	if not father.weapon_node.is_melee:
		melee_active = false
		return
	father.weapon_node.get_node("AnimatedSprite").play("default")
	melee_active = false
	$InterActionTimer.set_wait_time(father.weapon_node.melee_interval)
	$InterActionTimer.start()
