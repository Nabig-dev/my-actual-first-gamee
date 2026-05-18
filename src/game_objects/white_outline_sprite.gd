extends Node

export var timer_delay: float = 0

func _ready() -> void :
	if timer_delay > 0:
		$Timer.start(timer_delay)
	else:
		$AnimationPlayer.play("flash")
	
	var parent_n = get_parent()
	
	if parent_n is Sprite:
		$SpriteTest.material = $SpriteTest.material.duplicate()
		parent_n.material = $SpriteTest.material

func _on_Timer_timeout() -> void :
	$AnimationPlayer.play("flash_oneshot")
