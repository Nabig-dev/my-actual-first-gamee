extends Position2D

var is_active: bool = false

var _current_item: int = - 1

onready var Tw = $Tween
onready var Anim = $AnimationPlayer

func _process(_delta: float) -> void :
	

	
	if is_active and VarsGlobal.Player != null:
		global_position = VarsGlobal.Player.global_position

func use_item(item: int) -> void :
	
	cancel_use()
	
	is_active = true
	_current_item = item
	var color_item: = Color("ffffff")
	var time_use: float = 1.0
	
	get_node("%SpriteIcon").frame = item
	get_node("%TextureProgress").value = 0
	
	match item:
		0:
			time_use = 3.5
			color_item = Color("006aff")
		2:
			time_use = 3
			color_item = Color("ff1e1e")
		3:
			time_use = 0.9
			color_item = Color("ff1ef1")
		4:
			time_use = 3
			color_item = Color("1effd0")
	
	get_node("%TextureProgress").modulate = color_item
	get_node("%QuickMenuItemUse").modulate = color_item
	
	Anim.play("RESET")
	Anim.play("show")
	
	Tw.stop_all()
	Tw.interpolate_property(
		get_node("%TextureProgress"), "value", 
		get_node("%TextureProgress").min_value, get_node("%TextureProgress").max_value, 
		time_use
	)
	Tw.start()

func cancel_use() -> void :
	if is_active == true:
		is_active = false
		Tw.stop_all()
		Anim.play("RESET")

func _on_Tween_tween_all_completed() -> void :
	Anim.play("completed")
	Audio.play_sfx("ui_quickitem_use")
	
	match _current_item:
		0:
			VarsGlobal.game_data["player_inventory"][
				GVar.INVENTORY_ITEM.POTION_HEALTH
			] -= 1
			
			var hp_recover = int(
				float(VarsGlobal.game_data["player_hp_max"]) * 0.33
			)
			VarsGlobal.game_data["player_hp_now"] = FuncsNumbers.add_value(
				hp_recover, VarsGlobal.game_data["player_hp_now"], 
				VarsGlobal.game_data["player_hp_max"]
			)
		2:
			VarsGlobal.game_data["player_inventory"][
				GVar.INVENTORY_ITEM.FIRST_AID_KIT
			] -= 1
			VarsGlobal.game_data["player_injured"] = false
		3:
			VarsGlobal.game_data["player_inventory"][
				GVar.INVENTORY_ITEM.POTION_POISON
			] -= 1
			VarsGlobal.game_data["player_poisoned"] = false
		4:
			VarsGlobal.game_data["player_inventory"][
				GVar.INVENTORY_ITEM.POTION_CURSE
			] -= 1
			VarsGlobal.game_data["player_cursed"] = false
			

	VarsGlobal.GameInterface.update_hud_values(false)
