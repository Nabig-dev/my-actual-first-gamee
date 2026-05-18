extends Node

func _on_PaperObject_obtained() -> void :
	VarsGlobal.Player.stop_move()
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.GameInterface.can_pause = false
	yield(get_tree().create_timer(1), "timeout")
	
	VarsGlobal.GameInterface.connect("dialog_ended", self, "_on_dialog_ended", [], 4)
	VarsGlobal.GameInterface.start_dialog("letter-obtained")

func _on_dialog_ended(_dialog: String) -> void :
	VarsGlobal.Player.set_enabled_input(true)
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.GameInterface.show_tuto_screen(9)
