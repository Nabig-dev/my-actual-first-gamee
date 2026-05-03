extends Node


var is_talking: bool

func _ready() -> void :
	VarsGlobal.GameInterface.connect(
		"dialog_signal_emitted", self, "_on_dialog_signal_emitted"
	)

func refresh_dialogic_vars() -> void :
	Dialogic.set_variable(
		"alessa_talk_office1", 
		int(VarsGlobal.has_flag("alessa_talk_office1"))
	)
	Dialogic.set_variable(
		"birstall_problem_discovered", 
		int(VarsGlobal.has_flag("birstall_problem_discovered"))
	)
	Dialogic.set_variable(
		"birstall_problem_resolve", 
		int(VarsGlobal.has_flag("birstall_problem_resolve"))
	)
	Dialogic.set_variable(
		"train_event_finished", 
		int(VarsGlobal.has_flag("train_event_finished"))
	)

func _on_dialog_signal_emitted(_dialog_name, signal_name) -> void :
	if signal_name == "birstall_problem_resolve":
		VarsGlobal.add_flag("birstall_problem_resolve")

func _on_InteractableArea2DIndicator_interact_requested() -> void :
	if is_talking == true:
		return
	
	is_talking = true
	
	refresh_dialogic_vars()
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	
	Audio.stop_music()

	yield(get_tree().create_timer(0.8), "timeout")
	
	Audio.play_music("alessa_theme")
	
	VarsGlobal.GameInterface.start_dialog("alessa-office")
	
	yield(VarsGlobal.GameInterface, "dialog_ended")
	
	Audio.play_music("the_order")
	
	
	if VarsGlobal.has_flag("alessa_talk_office1") == false:
		VarsGlobal.add_flag("alessa_talk_office1")
		
		VarsGlobal.GameInterface.Node2DMap.add_mark(7, [ - 24, - 2])
		
		VarsGlobal.GameInterface.Node2DMap.add_mark( - 1, [ - 18, - 4])

	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
	is_talking = false

	VarsGlobal.GameInterface.get_paper(GVar.NOTES.ALESSA)
