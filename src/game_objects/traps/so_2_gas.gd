extends Node2D

func _has_ag_alloy() -> bool:
	if VarsGlobal.game_data["player_ec_alloy_selected"][
		VarsGlobal.game_data["player_current_set"]
	] == GVar.ALLOYS.AG:
		return true
	else:
		return false

func set_visible(val: bool) -> void :
	$CPUParticlesGas.emitting = val

func _on_alloy_changed() -> void :
	set_visible(_has_ag_alloy())

func _on_Timer_timeout() -> void :
	_on_alloy_changed()
	VarsGlobal.GameInterface.connect(
		"alloy_changed", self, "_on_alloy_changed"
	)
	VarsGlobal.GameInterface.connect(
		"set_changed", self, "_on_alloy_changed"
	)
