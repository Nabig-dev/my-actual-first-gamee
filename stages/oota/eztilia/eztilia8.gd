extends Node




func _modulate_snow(to_color: Color) -> void :
	var Tw: Tween = VarsGlobal.GameScenario.get_node_or_null("Tween")
	
	if Tw == null:
		return
	
	var SnowCanvas: CanvasLayer = VarsGlobal.GameScenario.get_node("SnowCanvasLayer2")
	
	Tw.interpolate_property(
		SnowCanvas, "modulate", 
		SnowCanvas.modulate, to_color, 1
	)
	
	Tw.start()
	if to_color == Color.white:
		SnowCanvas.visible = true



func _on_AreaRecoverThermal_body_entered(_body: Node) -> void :
	Audio.play_music("eztilia", "low")
	_modulate_snow(Color("00ffffff"))

func _on_AreaRecoverThermal_body_exited(_body: Node) -> void :
	Audio.play_music("eztilia", "high")
	_modulate_snow(Color.white)


func _on_RoomChanger2_player_positioned() -> void :
	$GameScenario / SnowCanvasLayer2.visible = true
	yield(get_tree().create_timer(0.5), "timeout")
	Audio.play_music("eztilia", "high")
