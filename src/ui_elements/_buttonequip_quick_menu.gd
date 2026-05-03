tool 

extends TextureButton

export (String, "A", "B", "C", "D") var equip = "A" setget _update_equip

func _ready() -> void :
	_update_equip(equip)
	_on_ButtonEquip_focus_exited()

func _update_equip(letter: String) -> void :
	equip = letter
	get_node("%LblEquip").text = equip
	
	if equip in ["C", "D"]:
		rect_scale.y = - 1
		get_node("%LblEquip").rect_scale.y = - 1
		get_node("%LblEquip").rect_position.y = - 1.5
	else:
		rect_scale.y = 1
		get_node("%LblEquip").rect_scale.y = 1
		get_node("%LblEquip").rect_position.y = 1.5

func _on_ButtonEquip_focus_entered() -> void :
	get_node("%BGUnfocused").visible = false
	get_node("%LblEquip").modulate.a = 1.0
	Audio.play_sfx("ui_changed_value")

func _on_ButtonEquip_focus_exited() -> void :
	get_node("%BGUnfocused").visible = true
	get_node("%LblEquip").modulate.a = 0.5
