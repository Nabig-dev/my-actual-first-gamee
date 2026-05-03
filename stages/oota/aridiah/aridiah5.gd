extends Node

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	if VarsGlobal.has_flag("aridiah5switched") == true:
		VarsGlobal.GameScenario.get_node("SpikeThrowFloor").active = false
		VarsGlobal.GameScenario.get_node("FactoryTileMap").queue_free()

func _on_SpikeThrowFloor_player_entered() -> void :
	Audio.play_sfx("ui_changed_value2")
	if VarsGlobal.has_flag("aridiah5switched") == false:
		VarsGlobal.add_flag("aridiah5switched")
		VarsGlobal.GameScenario.get_node("AnimationPlayer").play("pilar_remove")
		Audio.play_sfx("door_opening")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void :
	Audio.play_sfx("door_closed")
	VarsGlobal.GameScenario.CameraNode.start_shake(
		0.2, false, 
		true, false
	)
	Gamepad.start_vibration(0, 0.8, 0.8, 0.5)
