extends Node

func _ready() -> void :
	VarsGlobal.GameScenario.get_node("CanvasLayerTutoDropFloor").visible = false

func _process(_delta: float) -> void :
	
	if (
		Input.is_action_pressed("ui_down") and 
		Input.is_action_just_pressed("jump")
		and VarsGlobal.GameScenario.get_node("CanvasLayerTutoDropFloor").visible == true
	):
		Savedata.update_flag_game("dropfloor_tuto_finished")
		VarsGlobal.GameScenario.get_node("CanvasLayerTutoDropFloor").visible = false

func _on_Area2DHowDropFloor_area_entered(_area: Area2D) -> void :
	if VarsGlobal.has_flag("dropfloor_tuto_finished") == false:
		VarsGlobal.GameScenario.get_node("CanvasLayerTutoDropFloor").visible = true

func _on_Area2DHowDropFloor_area_exited(_area: Area2D) -> void :
	VarsGlobal.GameScenario.get_node("CanvasLayerTutoDropFloor").visible = false

func _on_Area2DStartMiniDialog_area_entered(_area: Area2D) -> void :
	if VarsGlobal.has_flag("showed_first_minidialog") == false:
		VarsGlobal.add_flag("showed_first_minidialog")
		VarsGlobal.GameInterface.show_quick_text(
			"GRIJAYLA1DAMNED", 
			VarsGlobal.Player
		)

func _on_RottenChicken_obtained() -> void :
	VarsGlobal.GameInterface.show_quick_text(
		"ROTTENCHICKENWALLOBTAINED", 
		VarsGlobal.Player
	)

func _on_TimerShowTitle_timeout() -> void :
	
	if VarsGlobal.has_flag("showed_first_grij_title") == false:
		VarsGlobal.add_flag("showed_first_grij_title")
		var area_title_translated: String = tr("GRIJAYLA_TOWN")
		
		if area_title_translated == "GRIJAYLA_TOWN":
			area_title_translated = area_title_translated.capitalize()
		VarsGlobal.GameInterface.can_pause = false
		VarsGlobal.GameInterface.get_node("%DramaticTitle").show_title(area_title_translated)
		yield(VarsGlobal.GameInterface.get_node("%DramaticTitle"), "ended")
		VarsGlobal.GameInterface.can_pause = true
