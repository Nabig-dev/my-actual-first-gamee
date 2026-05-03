extends Node



func _on_KeyObject_obtained() -> void :
	VarsGlobal.GameInterface.start_dialog("medallion-joseph-obtained")
	yield(VarsGlobal.GameInterface, "dialog_ended")
	VarsGlobal.GameInterface.get_paper(GVar.NOTES.CAVENDISH_BROTHERS)
