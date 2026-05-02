extends Node

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	if VarsGlobal.has_flag("eztilia34_event_finished") == true:
		VarsGlobal.GameScenario.get_node("Bodies").queue_free()

func _on_InteractableArea2DIndicator_interact_requested() -> void :
	
	VarsGlobal.GameInterface.start_dialog("defeated-alchemist")
