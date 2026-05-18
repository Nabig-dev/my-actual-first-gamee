extends Node2D

export var player_facing: int = - 1
export var id_destination: String
export var go_to: String

func _on_InteractableArea2DIndicator_interact_requested() -> void :

	
	if VarsGlobal.Player.has_method("set_enabled_input"):
		VarsGlobal.Player.set_enabled_input(false)
	
	
	if VarsGlobal.Player.has_method("invencibility"):
		VarsGlobal.Player.invencibility(0.5, false)
	
	VarsGlobal.current_room_changer = id_destination
	
	
	VarsGlobal.game_data["player_facing"] = player_facing
	
	SceneChanger.change_scene(go_to)
