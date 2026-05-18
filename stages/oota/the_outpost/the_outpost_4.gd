extends Node

func _ready() -> void :

	yield(get_tree().create_timer(0.1), "timeout")

	if VarsGlobal.has_flag("firstwindow_crushed") == true:
		VarsGlobal.GameScenario.get_node("Bg/Window/Window0").set_crushed()
		VarsGlobal.GameScenario.get_node("Enemies/SkeletonWarrior").global_position = VarsGlobal.GameScenario.get_node("Enemies/Position2DSkeleton").global_position
	
	if VarsGlobal.has_flag("consecutivewindow_crushed") == true:
		VarsGlobal.GameScenario.get_node("Bg/Window/WindowTop1").set_crushed()
		
		VarsGlobal.GameScenario.get_node("Bg/Window/WindowTop3").set_crushed()
	
	yield(get_tree().create_timer(0.9), "timeout")
	
	if VarsGlobal.has_flag("openpausemenu_tuto_finished") == false:
		Savedata.update_flag_game("openpausemenu_tuto_finished")
		VarsGlobal.GameInterface.show_tuto_screen(7)
		
	else:
		
		pass

func _on_Area2DFirstWindowBreak_area_entered(_area: Area2D) -> void :
	if VarsGlobal.has_flag("firstwindow_crushed") == false:
		VarsGlobal.add_flag("firstwindow_crushed")
		VarsGlobal.GameScenario.get_node("Bg/Window/Window0").crush()

func _on_Area2DWindowBreak2_area_entered(_area: Area2D) -> void :
	if VarsGlobal.has_flag("consecutivewindow_crushed") == false:
		VarsGlobal.add_flag("consecutivewindow_crushed")
		VarsGlobal.GameScenario.get_node("TimerShowHowToDodge").start()
		
		
		VarsGlobal.GameScenario.get_node("Bg/Window/WindowTop3").crush()

func _on_TimerShowHowToDodge_timeout() -> void :
	pass

func _on_RoomChanger3_player_positioned() -> void :
	$GameScenario / Enemies / AhuizoteMolotov.queue_free()
