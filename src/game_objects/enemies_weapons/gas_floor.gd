extends Node2D

func activate() -> void :
	
	Audio.play_sfx("gas_loop", true, 1)
	$AnimationPlayer.play("active")
func deactivate() -> void :
	Audio.stop_sfx("gas_loop", true, 1)
	$AnimationPlayer.play_backwards("active")


func _on_GasFloor_tree_exiting() -> void :
	Audio.stop_sfx("gas_loop", true, 1)
