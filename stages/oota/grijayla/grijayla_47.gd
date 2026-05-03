extends Node

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	
	if VarsGlobal.has_flag("eztilia_enter_marked") == false:
		VarsGlobal.add_flag("eztilia_enter_marked")
		VarsGlobal.GameInterface.Node2DMap.add_mark(13, [29, - 17])

func _on_Area2D_area_entered(_area: Area2D) -> void :
	
	if VarsGlobal.game_data["player_ec_action"].has(GVar.EC_ACTION.CONGELATIO) == false:
		pass
	
	elif VarsGlobal.has_flag("can_enter_eztilia") == false:
		VarsGlobal.GameInterface.show_quick_text(tr("IFICONGELATEWATER"), VarsGlobal.Player)



func _on_Area2D2_area_entered(_area: Area2D) -> void :
	VarsGlobal.add_flag("can_enter_eztilia")
	VarsGlobal.GameInterface.Node2DMap.add_mark( - 1, [29, - 17])


func _on_AboutEABarrier_interact_requested() -> void :
	VarsGlobal.GameInterface.start_dialog("about-ea-barrier")
