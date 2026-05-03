extends Node

var Cat = preload("res://src/game_objects/npc/cat.tscn")

var is_talking: bool

func _ready() -> void :
	
	yield(get_tree().create_timer(0.3), "timeout")
	
	
	if VarsGlobal.has_flag("aura_rescue_accepted") == false:
		VarsGlobal.GameScenario.get_node("Aura").queue_free()
	
	VarsGlobal.GameInterface.connect(
		"dialog_signal_emitted", self, "_on_dialog_signal"
	)

	spawn_gabriel_reward()
	
	
	for n in range(3):
		if VarsGlobal.has_flag("sophiacat" + str(n)):
			var ObjInstance = Cat.instance()
			ObjInstance.cat = n
			ObjInstance.auto_queue = false
			if n == 0:
				ObjInstance.dir = - 1
			ObjInstance.global_position = VarsGlobal.GameScenario.get_node("PositionCat" + str(n)).global_position
			VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_gabriel_reward() -> void :
	if VarsGlobal.GameScenario.get_node_or_null("EquipmentItem") != null and VarsGlobal.has_flag("reward_gabriel_obtained"):
		VarsGlobal.GameScenario.get_node("EquipmentItem").position = VarsGlobal.GameScenario.get_node("PositionGabrielReward").position

func refresh_dialogic_vars() -> void :
	Dialogic.set_variable(
		"gabriel_talk1_store", 
		int(VarsGlobal.has_flag("gabriel_talk1_store"))
	)
	
	Dialogic.set_variable(
		"aura_rescue_accepted", 
		int(VarsGlobal.has_flag("aura_rescue_accepted"))
	)
	
	Dialogic.set_variable(
		"aura_meeted", 
		int(VarsGlobal.has_flag("aura_meeted"))
	)
	
	
	Dialogic.set_variable(
		"gabriel_thanked_rescue", 
		int(VarsGlobal.has_flag("gabriel_thanked_rescue"))
	)
	
	
	Dialogic.set_variable(
		"aura_cats_accepted_rescue", 
		int(VarsGlobal.has_flag("aura_cats_accepted_rescue"))
	)

	
	var cats_rescued: int
	
	var cats_needed: int = 3
	
	cats_rescued += int(VarsGlobal.has_flag("sophiacat0"))
	cats_rescued += int(VarsGlobal.has_flag("sophiacat1"))
	cats_rescued += int(VarsGlobal.has_flag("sophiacat2"))
	cats_needed -= cats_rescued
	
	Dialogic.set_variable(
		"cats_need_rescue", 
		cats_needed
	)
	
	
	Dialogic.set_variable(
		"aura_cats_rescue_rewarded", 
		int(VarsGlobal.has_flag("aura_cats_rescue_rewarded"))
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
	
	var Dialog = Dialogic.start("gabriel-store")
	add_child(Dialog)
	
	
	yield(Dialog, "timeline_end")
	
	
	if VarsGlobal.has_flag("gabriel_talk1_store") == false:
		VarsGlobal.add_flag("gabriel_talk1_store")

	
	if VarsGlobal.has_flag("aura_rescue_accepted"):
		Achievments.obtain_ach("ach5")
		VarsGlobal.add_flag("gabriel_thanked_rescue")
		VarsGlobal.add_flag("reward_gabriel_obtained")
		spawn_gabriel_reward()
	
	
	$StoreInterface.open()

func _on_dialog_signal(_dialog_name, signal_name: String) -> void :
	if signal_name == "aura_cats_accepted_rescue":
		VarsGlobal.add_flag("aura_cats_accepted_rescue")

func _on_StoreInterface_closed() -> void :
	
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
	is_talking = false
	VarsGlobal.GameInterface.get_paper(GVar.NOTES.GABRIEL)


func _on_Aura_interact_requested() -> void :
	if is_talking == true:
		return
	is_talking = true
	refresh_dialogic_vars()
	VarsGlobal.GameInterface.start_dialog("aura-talk")
	yield(VarsGlobal.GameInterface, "dialog_ended")
	is_talking = false
	
	
	if (
		VarsGlobal.has_flag("aura_cats_accepted_rescue")
		and VarsGlobal.GameScenario.get_node_or_null("KeyObject") != null
	):
		VarsGlobal.GameInterface.get_paper(GVar.NOTES.AURA)
		VarsGlobal.GameScenario.get_node("KeyObject").global_position = VarsGlobal.Player.global_position

	
	if (
		VarsGlobal.has_flag("aura_cats_rescue_rewarded") == false
		and bool(Dialogic.get_variable("aura_cats_rescue_rewarded")) == true
		and int(Dialogic.get_variable("cats_need_rescue")) < 1
	):
		VarsGlobal.GameScenario.get_node("KeyObject2").global_position = VarsGlobal.Player.global_position
		VarsGlobal.add_flag("aura_cats_rescue_rewarded")
