extends Node2D

var status: String = "POISONED"

func _ready() -> void :
	Audio.play_sfx("negative_status")
	$Label.text = tr(status)
	match status:
		"POISONED":
			$Label.self_modulate = Color("f69cff")
			$Light.self_modulate = Color("f69cff")
		"CURSED":
			$Label.self_modulate = Color("9cffdc")
			$Light.self_modulate = Color("9cffdc")
		"INJURED":
			$Label.self_modulate = Color("ff7163")
			$Light.self_modulate = Color("ff7163")
