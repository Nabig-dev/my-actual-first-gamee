extends HBoxContainer

export var lbl_string: String = "99"
export var element: String = "PB"
export var show_green_if_correct: bool

var _hash_colors: Dictionary

func _ready() -> void :
	
	get_node("%Spectre").element = element
	$Label.text = lbl_string
	
	_hash_colors = {
		"RD": 0, 
		"OR": 0, 
		"YE": 0, 
		"GR": 0, 
		"CY": 0, 
		"PR": 0
	}
	
	for n in $HBoxContainer2.get_children():
		n.connect(
			"num_changed", self, 
			"_on_btn_color_change", 
			[n.name]
		)
	

func show_if_spectre_is_correct() -> void :
	if get_hash_spectre().hash() == get_current_hash_spectre().hash():
		get_node("%ClrRectGr").visible = true
		get_node("%ClrRectGr2").visible = true
	else:
		get_node("%ClrRectGr").visible = false
		get_node("%ClrRectGr2").visible = false

func set_spectre(spectre_dict: Dictionary) -> void :
	for spect_clr in spectre_dict.keys():
		_set_button_value(spect_clr, spectre_dict[spect_clr])
		_hash_colors[spect_clr] = spectre_dict[spect_clr]

func get_spectre() -> Dictionary:
	
	var spect: Dictionary
	for cl in _hash_colors.keys():
		spect[cl] = _get_button_value(cl)
	return spect

func update_spectre_visible() -> void :
	get_node("%Spectre").hash_colors = _hash_colors
	get_node("%Spectre").update_spectre(false)
	if show_green_if_correct == true:
		show_if_spectre_is_correct()

func _set_button_value(clr: String = "RD", val: int = 0) -> void :
	get_node("HBoxContainer2/" + clr).num = val
	get_node("HBoxContainer2/" + clr).update_info()
	_hash_colors[clr] = val
func _get_button_value(clr: String = "RD") -> int:
	return get_node("HBoxContainer2/" + clr).num

func get_hash_spectre(elemnthash: String = element) -> Dictionary:
	return get_node("%Spectre").get_spectre_hashes(elemnthash)

func get_current_hash_spectre() -> Dictionary:
	return get_node("%Spectre").get_current_spectre_hashes()

func focus_btn() -> void :
	$HBoxContainer2 / RD.grab_focus()

func _on_btn_color_change(num: int, clr: String) -> void :
	_hash_colors[clr] = num
	update_spectre_visible()
