extends Control

func _ready() -> void :

	var Dialog = Dialogic.start("post-prologue-nana-death")
	Dialog.connect("dialogic_signal", self, "_on_dialog_signal")
	Dialog.connect("timeline_end", self, "_on_dialog_end")
	add_child(Dialog)
	
	


func _on_dialog_end(_timeline: String) -> void :
	
	Audio.stop_music()
	
	
	
	SceneChanger.change_scene("res://stages/oota/amerithia/hospital_post_prologue.tscn")

func _on_dialog_signal(dialog_signal: String) -> void :
	match dialog_signal:
		"music_filter":
			AudioServer.set_bus_effect_enabled(
				Audio.music_idx, 1, true
			)
			AudioServer.set_bus_effect_enabled(
				Audio.music_idx, 2, true
			)
		"reset_audio_filter":
			AudioServer.set_bus_effect_enabled(
				Audio.music_idx, 1, false
			)
			AudioServer.set_bus_effect_enabled(
				Audio.music_idx, 2, false
			)
		"start_blood":
			$Control / ParticlesBlood.emitting = true
			$AnimationPlayer.play("Anim")
		_:
			pass
