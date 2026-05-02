extends Node

func _on_HideMinimapTuto_interact_requested() -> void :
	VarsGlobal.GameInterface.show_tuto_screen(8)

func _on_QuickMenuTuto_interact_requested() -> void :
	VarsGlobal.GameInterface.show_tuto_screen(2)

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	if VarsGlobal.has_flag("margaret-meet-lab-neuman"):
		VarsGlobal.GameScenario.get_node("NPCMargaret").queue_free()

func _on_Area2D_area_entered(_area: Area2D) -> void :
	
	
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	yield(get_tree().create_timer(0.5), "timeout")
	
	VarsGlobal.GameInterface.start_dialog("margaret-meet-lab-neuman")
	
	
	yield(VarsGlobal.GameInterface, "dialog_ended")

	VarsGlobal.GameScenario.get_node("NPCMargaret").queue_free()
	VarsGlobal.add_flag("margaret-meet-lab-neuman")
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
