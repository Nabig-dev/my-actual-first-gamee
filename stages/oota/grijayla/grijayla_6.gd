extends Node



func _on_Area2DHowToAbsorbCircuit_area_entered(_area: Area2D) -> void :
	if VarsGlobal.has_flag("howtoabsorb_tuto_finished") == false:
		Savedata.update_flag_game("howtoabsorb_tuto_finished")
		VarsGlobal.GameInterface.show_tuto_screen(5)


func _on_ElementalCircuit_absorbed_anim_end() -> void :
	pass



