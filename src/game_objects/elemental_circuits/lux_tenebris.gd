extends Node2D

var Vignette: Object = null

onready var TweenLightUp: SceneTreeTween = create_tween()

func _ready() -> void :
	
	for v in get_tree().get_nodes_in_group("vignette_player"):
		Vignette = v
	
	
	if Vignette == null:
		VarsGlobal.erase_flag("lux_tenebris_started", 1)
		queue_free()
		return

	
	TweenLightUp.tween_property(
		Vignette, "vignette_extra_scale", 0.12, 2
	)
	
	VarsGlobal.add_flag("lux_tenebris_started", 1)
	
	VarsGlobal.GameInterface.connect(
		"set_changed", self, "finish_circuit"
	)
	
	

func _process(_delta: float) -> void :
	global_position = VarsGlobal.Player.global_position - Vector2(0, 25)

func finish_circuit() -> void :
	if Vignette == null:
		return
	TweenLightUp.stop()
	$TimerActive.stop()
	$TimerDecreaseMana.stop()
	var Tw = create_tween()
	Tw.tween_property(
		Vignette, "vignette_extra_scale", 0.0, 0.4
	)
	yield(Tw, "finished")
	VarsGlobal.erase_flag("lux_tenebris_started", 1)
	queue_free()

func _on_TimerActive_timeout() -> void :
	finish_circuit()

func _on_TimerDecreaseMana_timeout() -> void :

	pass

func _on_LuxTenebris_tree_exiting() -> void :
	
	pass

func _on_TimerConnectPlayerSignal_timeout() -> void :
	VarsGlobal.Player.connect(
		"dead", self, "finish_circuit"
	)
