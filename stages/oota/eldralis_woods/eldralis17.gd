extends Node

var enemies_defeated: int

func _ready() -> void :
	
	if VarsGlobal.has_flag("margaret_rescued") == true:
		drop_magnesium()
		VarsGlobal.GameScenario.get_node("EventMargaret").queue_free()
	
	
	else:
		yield(get_tree().create_timer(0.2), "timeout")
		VarsGlobal.GameInterface.Node2DMap.add_mark(4, [ - 53, - 3])
		for e in VarsGlobal.GameScenario.get_node("Enemies").get_children():
			e.get_node("EnemyBase").connect(
				"enemy_defeated", self, "_on_EnemyDefeat"
			)
	
	Dialogic.set_variable(
		"margaret_rescue_ignored", 
		int(VarsGlobal.has_flag("margaret_rescue_ignored"))
	)

func _on_AreaXandriaSeeMargaret_area_entered(_area: Area2D) -> void :
	
	if VarsGlobal.has_flag("margaret_first_dialog") == true:
		return
	
	VarsGlobal.add_flag("margaret_first_dialog")
	
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	VarsGlobal.GameInterface.can_pause = false
	
	VarsGlobal.GameScenario.CameraNode.move_to(
		VarsGlobal.GameScenario.get_node(
			"EventMargaret/NPCMargaret"
		).global_position, 4
	)
	
	yield(VarsGlobal.GameScenario.CameraNode, "tweened_to_position")

	VarsGlobal.GameInterface.start_dialog(
		"/Eldralis/margaret-first"
	)
	
	yield(VarsGlobal.GameInterface, "dialog_ended")
	
	VarsGlobal.GameScenario.CameraNode.return_to_player(3)
	
	yield(VarsGlobal.GameScenario.CameraNode, "tweened_to_player")
	
	VarsGlobal.Player.set_enabled_input(true)
	VarsGlobal.GameInterface.can_pause = true
	
	VarsGlobal.GameInterface.get_paper(GVar.NOTES.MARGARET)

func _on_EnemyDefeat(_enemy_node: Object) -> void :
	enemies_defeated += 1
	
	
	if enemies_defeated >= 9:
		
		Achievments.obtain_ach("ach2")
		
		VarsGlobal.GameInterface.Node2DMap.add_mark( - 1, [ - 53, - 3])
		
		VarsGlobal.add_flag("margaret_rescued")
		
		VarsGlobal.Player.set_enabled_input(false)
		VarsGlobal.Player.stop_move()
		
		VarsGlobal.Player.invencibility(3, false)
		VarsGlobal.GameInterface.can_pause = false
		
		yield(get_tree().create_timer(2), "timeout")
	
		VarsGlobal.GameInterface.start_dialog(
			"/Eldralis/margaret-rescued"
		)
		yield(VarsGlobal.GameInterface, "dialog_ended")
		
		VarsGlobal.Player.set_enabled_input(true)
		VarsGlobal.GameInterface.can_pause = true
		
		drop_magnesium()



func drop_magnesium() -> void :
	
	if VarsGlobal.has_flag("magnesium_droped") == true:
		return
		
	VarsGlobal.add_flag("magnesium_droped")
	
	var AlloyMg: Object = VarsGlobal.GameScenario.get_node_or_null(
		"AlloyElement"
	)
	if AlloyMg != null:
		AlloyMg.global_position = VarsGlobal.Player.global_position



func _on_Node_tree_exiting() -> void :
	if (
		VarsGlobal.has_flag("margaret_first_dialog") == true
		and VarsGlobal.has_flag("margaret_rescued") == false
		and VarsGlobal.has_flag("margaret_rescue_ignored") == false
	):
		VarsGlobal.add_flag("margaret_rescue_ignored")
