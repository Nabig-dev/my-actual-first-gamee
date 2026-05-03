extends Area2D

signal screen_entered
signal screen_exited

var _on_screen: bool = false

func is_on_screen() -> bool:
	return _on_screen

func _on_VisibilityNotifierCameraArea_area_entered(area: Area2D) -> void :
	if area.name == "AreaVisibilityNotifier":
		_on_screen = true
		emit_signal("screen_entered")

func _on_VisibilityNotifierCameraArea_area_exited(area: Area2D) -> void :
	if area.name == "AreaVisibilityNotifier":
		_on_screen = false
		emit_signal("screen_exited")
