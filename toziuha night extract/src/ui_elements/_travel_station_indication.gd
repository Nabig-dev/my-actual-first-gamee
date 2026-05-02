extends MarginContainer

signal accept_pressed
signal cancel_pressed

func _on_BtnSelect_pressed() -> void :
	emit_signal("accept_pressed")
func _on_BtnExit_pressed() -> void :
	emit_signal("cancel_pressed")
