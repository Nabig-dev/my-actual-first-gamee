extends Node

func _ready() -> void :
	Audio.play_music("ambient_forest_wind")
	yield(get_tree().create_timer(0.3), "timeout")
	VarsGlobal.GameScenario.get_node("TrainStation").active = VarsGlobal.has_flag("train_event")
