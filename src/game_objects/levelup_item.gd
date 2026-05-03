tool 

extends Node2D

export var ide: String = ""

export (
	int, "ATK", "DEF", "INT", "HP", "MP", "POTION", "SP"
) var type = 0 setget _update_sprite

export var amount: int = 1

var color_item: Color

func _ready() -> void :
	if Engine.is_editor_hint() == true:
		return

	$AnimationPlayer.play("idle")

	
	if ide.empty() == true or VarsGlobal.game_data["levelup_items"].has(ide) == true:
		queue_free()

func _update_color(clr: Color) -> void :
	color_item = clr
	$Particles.color = color_item
	$Sprite / Shine.modulate = color_item
	$Light2DCustom.color = color_item

func _update_sprite(val: int) -> void :
	
	type = val
	$Sprite.frame = type

	match type:
		0:
			_update_color(Color("e50000"))
		1, 5:
			_update_color(Color("002aec"))
		2:
			_update_color(Color("1db108"))
		3:
			_update_color(Color("e98dea"))
		4:
			_update_color(Color("58e0cd"))
		6:
			_update_color(Color("86ffffff"))


func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	
	if Engine.is_editor_hint() == true:
		return
	
	VarsGlobal.game_data["levelup_items"].append(ide)

	var txt: String
	
	match type:
		0:
			VarsGlobal.game_data["player_atk"] += amount
			txt = tr("ATK_TITLE") + " Max"
		1:
			VarsGlobal.game_data["player_def"] += amount
			txt = tr("DEF_TITLE") + " Max"
		2:
			VarsGlobal.game_data["player_int"] += amount
			txt = tr("INT_TITLE") + " Max"
		3:
			VarsGlobal.game_data["player_hp_max"] += amount
			VarsGlobal.game_data["player_hp_now"] = VarsGlobal.game_data["player_hp_max"]
			txt = tr("HP_TITLE") + " Max"
		4:
			VarsGlobal.game_data["player_mp_max"] += amount
			VarsGlobal.game_data["player_mp_now"] = VarsGlobal.game_data["player_mp_max"]
			txt = tr("MP_TITLE") + " Max"
		5:
			VarsGlobal.game_data["player_potions_max"] += amount
			txt = "POTIONMAX_TITLE"
		6:
			VarsGlobal.game_data["player_sp_max"] += amount
			VarsGlobal.game_data["player_sp_now"] = VarsGlobal.game_data["player_sp_max"]
			txt = tr("SP_TITLE") + " Max"

	VarsGlobal.GameInterface.show_levelup_message("%s +%d" % [tr(txt), amount])

	$Sprite.visible = false
	$Particles.emitting = false
	$AnimationPlayer.stop()
	$Light2DCustom.enabled = false
