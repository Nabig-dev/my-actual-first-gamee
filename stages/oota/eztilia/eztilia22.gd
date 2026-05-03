extends Node

func _on_Area2DMovingDetectTop_area_entered(area: Area2D) -> void :
	if area.name == "EztiliaPlatform":
		var platform: KinematicBody2D = area.get_parent()
		platform.global_position = VarsGlobal.GameScenario.get_node(
			"Node2D/ColL/PositionSpawnBottom"
		).global_position

func _on_Area2DMovingDetectBottom_area_entered(area: Area2D) -> void :
	if area.name == "EztiliaPlatform":
		var platform: KinematicBody2D = area.get_parent()
		platform.global_position = VarsGlobal.GameScenario.get_node(
			"Node2D/ColR/PositionSpawnTop"
		).global_position


func _on_Area2DMovingDetectTop2_area_entered(area: Area2D) -> void :
	if area.name == "EztiliaPlatform":
		var platform: KinematicBody2D = area.get_parent()
		platform.global_position = VarsGlobal.GameScenario.get_node(
			"Node2D/ColR2/PositionSpawnBottom"
		).global_position
