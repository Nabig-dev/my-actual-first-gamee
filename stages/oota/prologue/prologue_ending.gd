extends Control

func _ready() -> void :
	Audio.play_sfx("ambient_sinester", true, 5)
	var Dialog = Dialogic.start("the_outpost-last-flashback")
	Dialog.connect("timeline_end", self, "_on_dialog_end")
	Dialog.connect("dialogic_signal", self, "_on_dialog_signal")
	add_child(Dialog)

func _on_dialog_end(_timeline: String) -> void :
	$AnimationPlayer.play("continued")

func _on_dialog_signal(dialog_signal: String) -> void :
	match dialog_signal:
		"firesnd":
			Audio.play_sfx("ambient_fire_crackle", true, 2)
			Audio.stop_sfx("ambient_sinester", true, 5)
		"ironsnd":
			Audio.play_sfx("iron_fall")
		"skinburn":
			Audio.stop_sfx("ambient_fire_crackle", true, 5)

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void :
	Audio.stop_sfx("ambient_sinester")
	Audio.stop_sfx("ambient_fire_crackle")
	
	if Features.has("demo"):
		SceneChanger.change_scene("res://stages/oota/prologue/prologue_ended.tscn")
	
	else:
		SceneChanger.change_scene("res://stages/oota/misc/flashback_nana_death.tscn")
	
	
