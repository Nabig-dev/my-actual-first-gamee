extends Control

export var enabled: bool = true

func _ready() -> void :
	if enabled and Features.has("debug"):
		visible = true
		modulate.a = 0.47
	else:
		visible = false
