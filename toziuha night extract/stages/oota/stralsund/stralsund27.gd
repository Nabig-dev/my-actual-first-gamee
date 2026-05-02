extends Node



func _on_Area2D_area_entered(_area: Area2D) -> void :
	if VarsGlobal.has_flag("stralsund_entered") == true:
		return
	VarsGlobal.add_flag("stralsund_entered")
	VarsGlobal.GameInterface.start_dialog("stralsund-entered")
	yield(VarsGlobal.GameInterface, "dialog_ended")
	VarsGlobal.GameInterface.get_paper(GVar.NOTES.ABOUT_STRALSUND)
