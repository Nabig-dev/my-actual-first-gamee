extends CanvasLayer

signal opened
signal closed
signal resolved

var PuzzleLine = preload("res://src/ui_elements/spectrum_puzzle_line.tscn")

export var hint: String
export var puzzleid: String = "puzzlespectre"
export (Dictionary) var elements_to_show = {
	0: "PB;82"
}

func _ready() -> void :
	get_node("%SpectraPuzzle").visible = false
	get_node("%LblTextPuzzle").visible = not hint.empty()
	get_node("%LblTextPuzzle").text = tr(hint)
	load_spectres()
	

func _process(_delta: float) -> void :
	if is_active() == true and is_resolved() == false:
		if Input.is_action_just_pressed("ui_cancel"):
			close()
		if Input.is_action_just_pressed("ui_start"):
			_on_BtnPuzzleAccept_pressed()

func is_resolved() -> bool:
	return VarsGlobal.has_flag(puzzleid)

func is_active() -> bool:
	return get_node("%SpectraPuzzle").visible

func open() -> void :
	Audio.play_sfx("ui_accept")
	get_node("%SpectraPuzzle").visible = true
	for n in get_node("%VBxElementsSpectres").get_children():
		if n is HBoxContainer:
			n.focus_btn()
			return
	emit_signal("opened")
func close() -> void :
	Audio.play_sfx("ui_cancel")
	get_node("%SpectraPuzzle").visible = false
	save_spectres()
	emit_signal("closed")


func is_all_spectres_ok() -> bool:
	for n in get_node("%VBxElementsSpectres").get_children():
		if n is HBoxContainer:
			
			if n.get_hash_spectre().hash() != n.get_current_hash_spectre().hash():
				return false
	return true

func save_spectres() -> void :
	for nod in get_node("%VBxElementsSpectres").get_children():
		if nod is HBoxContainer:
			save_spectre_flag(nod.name)

func load_spectres() -> void :
	
	for el_idx in elements_to_show.keys():
		var el_arr: Array = elements_to_show[el_idx].split(";")
		var ObjInstance = PuzzleLine.instance()
		var spect_from_flag: Array = get_spectre_flag(el_arr[0])
		ObjInstance.element = el_arr[0]
		ObjInstance.name = el_arr[0]
		ObjInstance.lbl_string = el_arr[1]
		ObjInstance.show_green_if_correct = true
		get_node("%VBxElementsSpectres").add_child(ObjInstance)
		
		if spect_from_flag[0].empty() == false:
			ObjInstance.set_spectre(spect_from_flag[1])
		ObjInstance.update_spectre_visible()




func get_spectre_flag(element: String = "PB") -> Array:
	var _spectre: Dictionary = {
		"RD": 0, 
		"OR": 0, 
		"YE": 0, 
		"GR": 0, 
		"CY": 0, 
		"PR": 0
	}
	var _spectre_string: String
	var result: Array = [_spectre_string, _spectre]
	
	for n in VarsGlobal.game_data["flags"]:
		
		if n.begins_with(puzzleid + element + "="):
			
			var spectre_string: String = n.replace(puzzleid + element + "=", "")
			result[0] = n
			
			for str_clr in spectre_string.split(","):
				
				var clr_data: Array = str_clr.split(":")
				_spectre[clr_data[0]] = int(clr_data[1])
	
	result[1] = _spectre
	
	return result

func save_spectre_flag(element: String = "PB") -> void :
	var _spectre_empty: Dictionary = {
		"RD": 0, "OR": 0, "YE": 0, "GR": 0, "CY": 0, "PR": 0
	}
	var spectre_element_from_flag: Dictionary = get_spectre_flag(element)[1]
	var spectre_element_string_from_flag: String = get_spectre_flag(element)[0]
	var _spectre_to_save: String
	
	
	if _spectre_empty.hash() != spectre_element_from_flag.hash():
		
		VarsGlobal.erase_flag(spectre_element_string_from_flag)
	
	
	VarsGlobal.add_flag(
		_convert_spectre_element_to_str(
			element, get_node("%VBxElementsSpectres/" + element).get_spectre()
		)
	)

func _convert_spectre_element_to_str(element: String = "PB", spect: Dictionary = {}) -> String:
	var str_result: String = puzzleid + element + "="
	var i: int = 0
	for cl in spect.keys():
		if i == 0:
			str_result += "%s:%d" % [cl, spect[cl]]
		else:
			str_result += ",%s:%d" % [cl, spect[cl]]
		i += 1
	return str_result


func _on_HelperIcon_visibility_changed() -> void :
	get_node("%HbxHelperIncreasePuzzle").visible = get_node("SpectraPuzzle/HBoxContainer/HbxHelperIncreasePuzzle/HelperIconBtn").visible


func _on_InteractEspectraMenuPuzzle_interact_requested() -> void :
	if get_node("%SpectraPuzzle").visible == true:
		return
	
	Audio.play_sfx("ui_accept")
	
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	VarsGlobal.GameInterface.can_pause = false
	yield(get_tree().create_timer(0.5), "timeout")
	
	get_node("%SpectraPuzzle").visible = true
	for n in get_node("%VBxElementsSpectres").get_children():
		if n is HBoxContainer:
			n.focus_btn()
			return


func _on_BtnExitPuzzle_pressed() -> void :
	if is_active() == true:
		close()

func _on_BtnPuzzleAccept_pressed() -> void :
	if is_active() == true:
		
		if is_all_spectres_ok() == true:
			close()
			emit_signal("resolved")
			Audio.stop_sfx("ui_cancel")
			Audio.play_sfx("ui_success")
			VarsGlobal.add_flag(puzzleid)
		else:
			Audio.play_sfx("ui_incorrect")
