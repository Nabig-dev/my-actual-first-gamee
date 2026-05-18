extends Node

var is_talking: bool

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	if VarsGlobal.has_flag("dirian_meets") == false:
		VarsGlobal.GameScenario.get_node(
			"InteractDirian/CollisionShape2D"
		).disabled = true
	
	
	
	if VarsGlobal.has_flag("tahua22_visited") == true:
		VarsGlobal.GameScenario.get_node(
			"InteractDirian"
		).queue_free()
		VarsGlobal.GameScenario.get_node(
			"darryl"
		).queue_free()

func _on_Area2DDetect_area_entered(_area: Area2D) -> void :
	
	if VarsGlobal.has_flag("dirian_meets") == true:
		return
	Audio.stop_music()
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	yield(get_tree().create_timer(0.2), "timeout")
	VarsGlobal.GameInterface.connect(
		"dialog_signal_emitted", 
		self, 
		"_on_dialog_signal_emitted"
	)
	VarsGlobal.GameInterface.connect(
		"dialog_ended", 
		self, 
		"_on_dialog_ended"
	)
	VarsGlobal.GameInterface.start_dialog("darryl-meet-restaurant")
	get_tree().paused = false
	

func _on_dialog_signal_emitted(_dialog: String, signal_name: String) -> void :
	if signal_name == "xandria_notice":
		VarsGlobal.Player.move(Vector2.LEFT)
		yield(get_tree().create_timer(0.8), "timeout")
		VarsGlobal.Player.stop_move()
		yield(get_tree().create_timer(2), "timeout")
		VarsGlobal.Player.anim_state_machine.start("idle")
		Audio.play_music("before_dirian_sheal")

func _on_dialog_ended(_dialog: String) -> void :
	if VarsGlobal.has_flag("dirian_meets") == false:
		VarsGlobal.add_flag("dirian_meets")
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
	VarsGlobal.GameScenario.get_node(
		"InteractDirian/CollisionShape2D"
	).disabled = false

func _on_InteractDirian_interact_requested() -> void :
	VarsGlobal.GameInterface.start_dialog("darryl-talk-restaurant")

func _on_InteractWaitress_interact_requested() -> void :
	
	if is_talking == true:
		return
	
	
	
	is_talking = true
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	var Dialog = Dialogic.start("waitress-restaurant-help")
	add_child(Dialog)
	
	
	yield(Dialog, "timeline_end")
	
	
	
	
	
	
	if VarsGlobal.has_flag("restaurant_helped") == true:
		
		$StoreInterface.open()
	
	else:
		yield(get_tree(), "idle_frame")
		_on_StoreInterface_closed()

func _on_StoreInterface_closed() -> void :
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
	is_talking = false
