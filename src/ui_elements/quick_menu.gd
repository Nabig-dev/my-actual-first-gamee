extends Control

signal set_changed



var circuit_set_obtained: bool = false

var enabled_input: bool = true

onready var TimerPlayOpenSnd = $TimerPlayOpenSnd
onready var Anim = $AnimationPlayer

func _process(_delta: float) -> void :
	
	
	if enabled_input == false or VarsGlobal.game_data["player_hp_now"] < 1:
		return
	
	if Input.is_action_just_pressed("ui_b"):
		open_menu()
	elif Input.is_action_just_released("ui_b"):
		use_option()
		close_menu()
		return
	
	if Input.is_action_pressed("ui_b") == false:
		return
	
	if (
		Input.is_action_just_released("ui_up")
		or Input.is_action_just_released("ui_down")
		or Input.is_action_just_released("ui_left")
		or Input.is_action_just_released("ui_right")
	):
		get_node("%HexaBG0").grab_focus()
	
	
	if is_diagonal_pressed("ui_up", "ui_left") and circuit_set_obtained == true:
		get_node("%ButtonEquipA").grab_focus()
	elif is_diagonal_pressed("ui_up", "ui_right") and circuit_set_obtained == true:
		get_node("%ButtonEquipB").grab_focus()
	elif is_diagonal_pressed("ui_down", "ui_left") and circuit_set_obtained == true:
		get_node("%ButtonEquipC").grab_focus()
	elif is_diagonal_pressed("ui_down", "ui_right") and circuit_set_obtained == true:
		get_node("%ButtonEquipD").grab_focus()
	
	
	elif Input.is_action_just_pressed("ui_up"):
		get_node("%ButtonItemHP").grab_focus()
	elif Input.is_action_just_pressed("ui_down"):
		get_node("%ButtonItemAidKit").grab_focus()
	elif Input.is_action_just_pressed("ui_left"):
		get_node("%ButtonItemAntiCurse").grab_focus()
	elif Input.is_action_just_pressed("ui_right"):
		get_node("%ButtonItemAntidote").grab_focus()
	
	if Input.is_action_just_pressed("ui_focus_prev"):
		print_debug("change subweapon")
	elif Input.is_action_just_pressed("ui_focus_next"):
		print_debug("change set")
	


func update_status_data() -> void :
	var status_list: Array = []
	var label_text: String
	
	if VarsGlobal.game_data["player_injured"] == true:
		status_list.append(tr("INJURED"))
	if VarsGlobal.game_data["player_poisoned"] == true:
		status_list.append(tr("POISONED"))
	if VarsGlobal.game_data["player_cursed"] == true:
		status_list.append(tr("CURSED"))
	
	if status_list.size() == 0:
		label_text = tr("GOOD")
	else:
		
		for s in status_list:
			label_text = label_text + ", " + s
		
		label_text = label_text.lstrip(",")
	
	get_node("%LblStatus").text = tr("STATUS") + ":"
	get_node("%LblStatusList").text = label_text

func is_diagonal_pressed(action_a: String, action_b: String) -> bool:
	if (
		(Input.is_action_pressed(action_a) and Input.is_action_just_pressed(action_b))
		or (Input.is_action_pressed(action_b) and Input.is_action_just_pressed(action_a))
	):
		return true
	return false

func open_menu() -> void :
	if (
		get_tree().paused == true
		or VarsGlobal.GameInterface.can_pause == false
		or VarsGlobal.GameInterface.dialog_active == true
	):
		return
	
	update_status_data()
	
	circuit_set_obtained = ElementalCircuits.was_obtained(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.MULTIPLE_EQUIPMENT
	)
	
	get_node("%ButtonEquipA").visible = circuit_set_obtained
	get_node("%ButtonEquipB").visible = circuit_set_obtained
	get_node("%ButtonEquipC").visible = circuit_set_obtained
	get_node("%ButtonEquipD").visible = circuit_set_obtained

	get_node("%ButtonItemHP").update_amount()
	get_node("%ButtonItemAidKit").update_amount()
	get_node("%ButtonItemAntiCurse").update_amount()
	get_node("%ButtonItemAntidote").update_amount()

	Anim.play("show")
	get_node("%HexaBG0").grab_focus()
	TimerPlayOpenSnd.start()
	get_tree().paused = true

func close_menu() -> void :
	if get_tree().paused == false or VarsGlobal.GameInterface.dialog_active == true:
		return
	Anim.play_backwards("show")
	TimerPlayOpenSnd.stop()
	get_node("%HexaBG0").grab_focus()

	get_tree().paused = false
	
	
	Input.action_release("ui_left")
	Input.action_release("ui_right")
	Input.action_release("ui_up")
	Input.action_release("ui_down")

func use_option() -> void :
	
	if get_focus_owner() == null:
		return
	
	var selected_opt = get_focus_owner().name
	
	match selected_opt:
		"HexaBG0":
			Audio.play_sfx("ui_close_quickmenu")
		"ButtonEquipA":
			Audio.play_sfx("ui_big_btn_focused")
			VarsGlobal.game_data["player_current_set"] = 0
			emit_signal("set_changed")
		"ButtonEquipB":
			Audio.play_sfx("ui_big_btn_focused")
			VarsGlobal.game_data["player_current_set"] = 1
			emit_signal("set_changed")
		"ButtonEquipC":
			Audio.play_sfx("ui_big_btn_focused")
			VarsGlobal.game_data["player_current_set"] = 2
			emit_signal("set_changed")
		"ButtonEquipD":
			Audio.play_sfx("ui_big_btn_focused")
			VarsGlobal.game_data["player_current_set"] = 3
			emit_signal("set_changed")
		_:
			if get_node("%" + selected_opt).amount_item == 0:
				Audio.play_sfx("ui_not_enough_mana")
				return
			Audio.play_sfx("ui_item_use")
			VarsGlobal.GameScenario.get_node("%QuickMenuItemStatus").use_item(
				get_node("%" + selected_opt).item_ide
			)

	VarsGlobal.GameInterface.update_hud_values(false)

func _on_HexaBG0_focus_entered() -> void :
	get_node("%CloseIcon").visible = true

func _on_HexaBG0_focus_exited() -> void :
	get_node("%CloseIcon").visible = false


func _on_TimerPlayOpenSnd_timeout() -> void :
	Audio.play_sfx("ui_open_quickmenu")


func _on_Btn_focus_entered(nodename: String) -> void :
	var text_use: String
	var text_description: String
	match nodename:
		"ButtonItemHP":
			text_use = tr("POTION_HEALTH_TITLE")
			text_description = tr("POTION_HEALTH_DESC")
		"ButtonItemAidKit":
			text_use = tr("FIRST_AID_KIT_TITLE")
			text_description = tr("FIRST_AID_KIT_DESC")
		"ButtonItemAntiCurse":
			text_use = tr("POTION_CURSE_TITLE")
			text_description = tr("POTION_CURSE_DESC")
		"ButtonItemAntidote":
			text_use = tr("POTION_POISON_TITLE")
			text_description = tr("POTION_POISON_DESC")
		
		"ButtonEquipA":
			text_use = "%s %s" % [tr("EQUIP"), "A"]
			text_description = ""
		"ButtonEquipB":
			text_use = "%s %s" % [tr("EQUIP"), "B"]
			text_description = ""
		"ButtonEquipC":
			text_use = "%s %s" % [tr("EQUIP"), "C"]
			text_description = ""
		"ButtonEquipD":
			text_use = "%s %s" % [tr("EQUIP"), "D"]
			text_description = ""
		
		_:
			text_use = tr("NONE")
			text_description = tr("PRESS_DIR_TO_USE_QUICKMENU")
	
	get_node("%LblUseMsg").text = "%s: %s" % [tr("USE"), text_use]
	get_node("%LblItemDesc").text = text_description
