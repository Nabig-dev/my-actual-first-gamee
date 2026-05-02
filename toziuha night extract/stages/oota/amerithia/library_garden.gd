extends Node

var is_talking: bool

func _ready() -> void :
	Audio.play_music("rachel_theme")

func refresh_dialogic_vars() -> void :
	Dialogic.set_variable(
		"has_nacatamal_pan_cafe", 
		0
	)
	Dialogic.set_variable(
		"rachel_ec_improv_introduction", 
		int(VarsGlobal.has_flag("rachel_ec_improv_introduction"))
	)
	Dialogic.set_variable(
		"rachel_nacatamal_received", 
		int(VarsGlobal.has_flag("rachel_nacatamal_received"))
	)

func _on_InteractableArea2DIndicator_interact_requested() -> void :
	
	if is_talking == true:
		return
	
	refresh_dialogic_vars()
	
	is_talking = true
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	var Dialog = Dialogic.start("rachel-library-garden")
	add_child(Dialog)
	
	
	yield(Dialog, "timeline_end")
	
	VarsGlobal.add_flag("rachel_ec_improv_introduction")
	
	
	if int(Dialogic.get_variable("rachel_nacatamal_received", 0)) == 1:
		VarsGlobal.add_flag("rachel_nacatamal_received")
	
		
		$StoreInterface.open()
	
	else:
		yield(get_tree(), "idle_frame")
		_on_CircuitsImproveInterface_closed()


func _on_CircuitsImproveInterface_closed() -> void :
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
	is_talking = false
	VarsGlobal.GameInterface.get_paper(GVar.NOTES.RACHEL)
