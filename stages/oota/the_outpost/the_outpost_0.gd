extends Node

var SkeletonWarriorEnemy = preload("res://src/game_objects/enemies/skeleton_warrior.tscn")
var SkeletonEnemy = preload("res://src/game_objects/enemies/skeleton.tscn")

func _ready() -> void :
	
	if VarsGlobal.has_flag("move_jump_tuto_finished") == false:
		Audio.play_music("ambient_forest_wind")
	

	

	VarsGlobal.GameScenario.get_node("CanvasLayerTuto/Control/Move").visible = false
	VarsGlobal.GameScenario.get_node("CanvasLayerTuto/Control/Jump").visible = false

	
	if VarsGlobal.has_flag("move_jump_tuto_finished") == false:
		VarsGlobal.GameScenario.get_node("CanvasLayerTuto/Control/Move").visible = true
	
	
	if VarsGlobal.has_flag("eva_1st_dialog") == true:
		var enemy: Object
		
		enemy = SkeletonWarriorEnemy.instance()
		enemy.global_position = VarsGlobal.GameScenario.get_node("PositionEnemies/Position2D2").global_position
		VarsGlobal.GameScenario.add_child(enemy)
		
		enemy = SkeletonEnemy.instance()
		enemy.global_position = VarsGlobal.GameScenario.get_node("PositionEnemies/Position2D").global_position
		VarsGlobal.GameScenario.add_child(enemy)

func _on_Area2DMoved_area_entered(_area: Area2D) -> void :
	
	if VarsGlobal.has_flag("move_jump_tuto_finished"):
		return
	
	
	Input.action_release("ui_left")
	Input.action_release("ui_right")
	VarsGlobal.GameScenario.get_node("CanvasLayerTuto/Control/Move").visible = false
	VarsGlobal.GameScenario.get_node("CanvasLayerTuto/Control/Jump").visible = true
	

func _on_Area2DTutoFinished_area_entered(_area: Area2D) -> void :
	if VarsGlobal.has_flag("move_jump_tuto_finished"):
		return
	
	Savedata.update_flag_game("move_jump_tuto_finished")

	VarsGlobal.GameScenario.get_node("CanvasLayerTuto/Control/Move").visible = false
	VarsGlobal.GameScenario.get_node("CanvasLayerTuto/Control/Jump").visible = false
	
	
	VarsGlobal.GameInterface.show_tuto_screen(0)
