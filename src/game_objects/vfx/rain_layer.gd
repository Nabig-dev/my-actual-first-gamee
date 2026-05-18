extends CanvasLayer

export var active: bool

func _ready() -> void :
	if active == true:
		$AnimationPlayer.play("active")

func start_rain() -> void :
	Audio.play_sfx("ambient_rain", true, 1)
	$AnimationPlayer.play("show")
func stop_rain() -> void :
	Audio.stop_sfx("ambient_rain")
	$AnimationPlayer.play_backwards("show")

func _on_RainLayer_tree_exiting() -> void :
	Audio.stop_sfx("ambient_rain")
