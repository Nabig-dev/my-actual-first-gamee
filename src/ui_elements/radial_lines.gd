extends Control

var time_show: float = 1.0

func _ready() -> void :
	
	$Timer.start(time_show)
	
	$AnimationPlayer.play("loop")
		
	modulate.a = 0
	var Tw = get_tree().create_tween()
	Tw.tween_property(
		self, "modulate", Color("ffffff"), 0.5
	)

func _on_Timer_timeout() -> void :
	var Tw = get_tree().create_tween()
	Tw.tween_property(
		self, "modulate", Color("00ffffff"), 0.5
	)
	yield(Tw, "finished")
	queue_free()
