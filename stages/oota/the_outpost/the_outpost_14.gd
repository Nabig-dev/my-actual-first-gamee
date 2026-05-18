extends Node

func _ready() -> void :

	pass

func _on_AreaDetectPlayerLux_area_entered(_area: Area2D) -> void :
	
	if VarsGlobal.has_flag("grij14_lux_dialog") == true:
		return
	
	VarsGlobal.add_flag("grij14_lux_dialog")
	
	if VarsGlobal.GameScenario.get_node(
		"VignettePlayer"
	).vignette_extra_scale == 0:
		VarsGlobal.GameInterface.start_dialog("the_outpost-14-lux")
