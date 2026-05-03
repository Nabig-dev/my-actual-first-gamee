extends TextureButton

signal set_changed(current_set)

var current_set: int = 0
var sets: = ["A", "B", "C"]

func _ready() -> void :
	
	if VarsGlobal.game_data["player_ec_ability"].has(GVar.EC_ABILITY.MULTIPLE_EQUIPMENT) == false:
		visible = false
	
	refresh_letter()

func refresh_letter() -> void :
	current_set = VarsGlobal.game_data["player_current_set"]
	$Label.text = sets[current_set]
	
	
	
	match sets[current_set]:
		"A":
			get_node("%LightSet").modulate = Color("ff00b9")
		"B":
			get_node("%LightSet").modulate = Color("08ffff")
		"C":
			get_node("%LightSet").modulate = Color("f91ff900")
		"D":
			get_node("%LightSet").modulate = Color("f9f9de00")

func switch_set(dir: String = "next", emit_sign: bool = true) -> void :
	_on_ButtonSwitchSet_pressed(dir, emit_sign)

func _on_ButtonSwitchSet_pressed(dir: String = "next", emit_sign: bool = true) -> void :
	current_set = FuncsArrays.get_new_position_on_array(
		sets, current_set, dir
	)
	$Label.text = sets[current_set]
	VarsGlobal.game_data["player_current_set"] = current_set
	Audio.play_sfx("ui_big_btn_focused")
	if emit_sign == true:
		emit_signal("set_changed", current_set)
