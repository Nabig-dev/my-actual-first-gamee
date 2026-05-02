extends Node

var is_talking: bool

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	
	if (
		VarsGlobal.has_flag("margaret_rescued") == true and 
		VarsGlobal.has_flag("margaret_pos_rescue_talk1") == true
	):
		pass
	else:
		VarsGlobal.GameScenario.get_node("NPCMargaret").queue_free()


func refresh_dialogic_vars() -> void :
	
	Dialogic.set_variable(
		"has_sulfuric_acid", 
		0
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
	
	var Dialog = Dialogic.start("margaret-labo-alchemy")
	add_child(Dialog)
	
	
	yield(Dialog, "timeline_end")
	
	
	if int(Dialogic.get_variable("has_sulfuric_acid", 0)) == 1:
		$StoreInterface.open()
	
	else:
		yield(get_tree(), "idle_frame")
		_on_AlchemyInterface_closed()


func _on_AlchemyInterface_closed() -> void :
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
	is_talking = false
