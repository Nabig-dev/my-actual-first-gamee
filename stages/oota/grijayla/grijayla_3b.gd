extends Node



func _on_Area2DHowToDodge_area_entered(_area: Area2D) -> void :
	if VarsGlobal.has_flag("howtododge_finished") == false:
		Savedata.update_flag_game("howtododge_finished")
		VarsGlobal.GameInterface.show_tuto_screen(3)
