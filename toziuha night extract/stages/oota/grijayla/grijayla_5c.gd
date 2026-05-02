extends Node

var InvBtn = preload("res://src/ui_elements/button_inventory_item.tscn")

var latin_elements: Dictionary = {
	"PB": "Plumbum", 
	"HG": "Hydrargyrum", 
	"AU": "Aurum", 
	"SN": "Stannum", 
	"AG": "Argentum", 
	"CU": "Cuprum", 
	"FE": "Ferrum"
}

var atomicnumber_elements: Dictionary = {
	"PB": 82, 
	"HG": 80, 
	"AU": 79, 
	"SN": 50, 
	"AG": 47, 
	"CU": 29, 
	"FE": 26
}

func _ready() -> void :
	get_node("%SpectraMenu").visible = false
	yield(get_tree().create_timer(0.3), "timeout")
	
	
	if VarsGlobal.has_flag("neuman-puzzle") == true:
		VarsGlobal.GameScenario.get_node("InteractEspectraMenuPuzzle").queue_free()
		VarsGlobal.GameScenario.get_node("InteractEspectraMenuPuzzle").queue_free()
		VarsGlobal.GameScenario.get_node("NPCMargaret").queue_free()
	
	if VarsGlobal.has_flag("neuman-lab-tour-margaret") == false:
		
		VarsGlobal.Player.set_enabled_input(false)
		VarsGlobal.Player.stop_move()
		VarsGlobal.GameInterface.can_pause = false
		yield(get_tree().create_timer(1.5), "timeout")
		VarsGlobal.GameInterface.start_dialog("about-neuman-lab")
		yield(VarsGlobal.GameInterface, "dialog_ended")
		yield(get_tree().create_timer(0.5), "timeout")
		
		VarsGlobal.Player.move(Vector2.LEFT)
		yield(get_tree().create_timer(1.3), "timeout")
		VarsGlobal.Player.stop_move()
		yield(get_tree().create_timer(1), "timeout")
		VarsGlobal.GameInterface.start_dialog("neuman-lab-about-espectroscope")
		yield(VarsGlobal.GameInterface, "dialog_ended")
		
		yield(get_tree().create_timer(1.5), "timeout")
		VarsGlobal.Player.move(Vector2.LEFT)
		yield(get_tree().create_timer(0.6), "timeout")
		VarsGlobal.Player.stop_move()
		yield(get_tree().create_timer(2), "timeout")
		VarsGlobal.GameInterface.start_dialog("neuman-lab-about-puzzle")
		yield(VarsGlobal.GameInterface, "dialog_ended")
		
		
		VarsGlobal.Player.set_enabled_input(true)
		VarsGlobal.GameInterface.can_pause = true
		VarsGlobal.add_flag("neuman-lab-tour-margaret")
	
	








func _process(_delta: float) -> void :

	if get_node("%SpectraMenu").visible == true:
		if Input.is_action_just_pressed("ui_cancel"):
			_on_BtnExitSpectrum_pressed()

func _on_selected_element(inv_ide: int) -> void :
	Audio.play_sfx("ui_put_object")
	var element_str: String = GVar.INVENTORY_ITEM.keys()[inv_ide]
	
	element_str = element_str.replace("_ELEMT", "")
	
	
	get_node("%LblElementLatin").text = latin_elements[element_str]
	get_node("%Spectre").element = element_str
	get_node("%Spectre").update_spectre()
	
	get_node("%LblDesc").text = "%s.\n%s" % [
		tr(element_str + "_ELEMT_TITLE"), 
		tr(element_str + "_ELEMT_DESC")
	]
	
	get_node("%LblElementNum").text = str(atomicnumber_elements[element_str])
	get_node("%LblElementSym").text = element_str.capitalize()

func _on_InteractableArea2DIndicator_interact_requested() -> void :
	VarsGlobal.GameInterface.start_dialog("margaret-help-puzzle-lab")


func _on_BtnExitSpectrum_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	get_node("%SpectraMenu").visible = false
	VarsGlobal.Player.set_enabled_input(true)
	yield(get_tree(), "idle_frame")
	VarsGlobal.GameInterface.can_pause = true


func _on_InteractEspectraMenu_interact_requested() -> void :

	if get_node("%SpectraMenu").visible == true:
		return
	
	Audio.play_sfx("ui_accept")
	
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	VarsGlobal.GameInterface.can_pause = false
	yield(get_tree().create_timer(0.5), "timeout")
	
	
	for n in get_node("%HbxElementsInv").get_children():
		n.queue_free()
	
	for el in VarsGlobal.game_data["player_inventory"].keys():
		
		if (
			el in [
				GVar.INVENTORY_ITEM.PB_ELEMT, 
				GVar.INVENTORY_ITEM.HG_ELEMT, 
				GVar.INVENTORY_ITEM.AU_ELEMT, 
				GVar.INVENTORY_ITEM.SN_ELEMT, 
				GVar.INVENTORY_ITEM.AG_ELEMT, 
				GVar.INVENTORY_ITEM.CU_ELEMT, 
				GVar.INVENTORY_ITEM.FE_ELEMT
			]
			and VarsGlobal.game_data["player_inventory"][el] > 0
		):
			var ObjInstance = InvBtn.instance()
			ObjInstance.item = el
			ObjInstance.connect(
				"focus_entered", self, 
				"_on_selected_element", 
				[el]
			)
			get_node("%HbxElementsInv").add_child(ObjInstance)
	
	
	if get_node("%HbxElementsInv").get_children().size() == 0:
		Notification.show_notif("ELEMENTALSAMPLENEEDED")
		_on_BtnExitSpectrum_pressed()
		return
	
	get_node("%SpectraMenu").visible = true
	yield(get_tree(), "idle_frame")
	get_node("%HbxElementsInv").get_children()[0].grab_focus()


func _on_HelperIconBtn2_visibility_changed() -> void :
	get_node("%HbxHelpersMove").visible = get_node("%HelperMoveR").visible


func _on_InteractEspectraMenuPuzzle_interact_requested() -> void :
	if get_node("%SpectrePuzzleScreen").is_active() == false:
		VarsGlobal.Player.set_enabled_input(false)
		VarsGlobal.Player.stop_move()
		VarsGlobal.GameInterface.can_pause = false
		yield(get_tree().create_timer(0.5), "timeout")
		get_node("%SpectrePuzzleScreen").open()

func _on_SealedDoor_open_animation_finished() -> void :
	VarsGlobal.GameInterface.start_dialog("neuman-puzzle-resolved")
	yield(VarsGlobal.GameInterface, "dialog_ended")
	VarsGlobal.GameScenario.get_node("InteractEspectraMenuPuzzle").queue_free()
	VarsGlobal.Player.set_enabled_input(true)
	VarsGlobal.GameInterface.can_pause = true

func _on_SpectrePuzzleScreen_opened() -> void :
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	VarsGlobal.GameInterface.can_pause = false

func _on_SpectrePuzzleScreen_closed() -> void :
	VarsGlobal.Player.set_enabled_input(true)
	yield(get_tree(), "idle_frame")
	VarsGlobal.GameInterface.can_pause = true

func _on_SpectrePuzzleScreen_resolved() -> void :
	
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.GameScenario.get_node("NPCMargaret").queue_free()
	VarsGlobal.GameScenario.get_node("SealedDoor").open_door()
