extends Area2D

func _on_AreaInstaKill_area_entered(area: Area2D) -> void :
	var PlayerBody = area.get_parent().get_parent()
	if PlayerBody.has_method("endgame") == true:
		VarsGlobal.GameInterface.can_pause = false
		
		VarsGlobal.game_data["player_hp_now"] = 0
		PlayerBody.endgame()
