extends Node2D

signal open_animation_finished

export var ide_flag: String

export var frame_seal: int = 0

func _ready() -> void :
	if VarsGlobal.has_flag("sealed_door_opened_" + ide_flag):
		queue_free()
	$Wall / Seal.frame = frame_seal
	$Wall / Seal2.frame = frame_seal
	$Wall / AnimationPlayer.play("loop")

func open_door() -> void :
	if ide_flag.empty() == false:
		VarsGlobal.add_flag("sealed_door_opened_" + ide_flag)
		Audio.play_sfx("crystal_soul_get3")
		$Wall / AnimationPlayer.play("open")

func sfx_opening() -> void :
	Audio.play_sfx("door_opening")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void :
	if anim_name == "open":
		emit_signal("open_animation_finished")
