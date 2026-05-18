extends Node

var has_medallion: bool

func _ready() -> void :
	
	has_medallion = VarsGlobal.game_data["player_key_objects"].has(
		GVar.KEYS_OBJECTS.MAGIC_MEDALLION
	)
	
	yield(get_tree().create_timer(0.3), "timeout")
	if has_medallion == true:
		VarsGlobal.GameScenario.get_node("DoorInterior").active = true
		VarsGlobal.GameScenario.get_node("DoorInterior").refresh_modulate()

func _on_Area2DDetectPlayer_area_entered(_area: Area2D) -> void :

	if has_medallion == false:
		VarsGlobal.GameInterface.start_dialog("about-magic-doors")
