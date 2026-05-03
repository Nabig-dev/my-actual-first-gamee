extends AnimationPlayer

export var anim_name_autostart: String

func _ready() -> void :
	if anim_name_autostart.empty() == false:
		play(anim_name_autostart)
