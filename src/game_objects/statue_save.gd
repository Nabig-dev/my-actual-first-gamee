extends Node2D

var MaterialDissolve = preload("res://assets/tres/statue_save_dissolve.tres")

export var inverse: bool = false

var _saved: bool
var _player_entered: bool

func _ready() -> void :
	
	VarsGlobal.GameInterface.enabled_quicksave = false
	
	if VarsGlobal.respawned_savestatue_no_hp_item == true:
		VarsGlobal.respawned_savestatue_no_hp_item = false
		VarsGlobal.game_data["player_inventory"][GVar.INVENTORY_ITEM.POTION_HEALTH] = 1
		VarsGlobal.game_data["player_inventory"][GVar.INVENTORY_ITEM.PAN] = 3

	if Config.get_value(
		"video", "vfx_level", 2
	) < 2:
		$Sprite / AnimatedSprite.self_modulate.a = 1

	if inverse == true:
		$Sprite.material = MaterialDissolve
		$Sprite.scale.y = - 1
		$Sprite.position.y -= 30
		$Sprite / InverseSprites.visible = true
		$Sprite / InverseSprites2.visible = true
	else:
		$Sprite.material = null

func save_game() -> void :
	
	$InteractableArea2DIndicator.set_disabled()
	
	
	if VarsGlobal.game_data["difficulty_base"] <= 1:
		
		VarsGlobal.game_data["player_hp_now"] = VarsGlobal.game_data["player_hp_max"]
		
		VarsGlobal.game_data["player_mp_now"] = VarsGlobal.game_data["player_mp_max"]
		
		
	
	
	VarsGlobal.game_data["player_injured"] = false
	VarsGlobal.game_data["player_poisoned"] = false
	VarsGlobal.game_data["player_cursed"] = false
	
	
	VarsGlobal.game_data["last_save_room_used"] = get_tree().current_scene.filename
	
	
	
	VarsGlobal.GameInterface.update_hud_values()
	VarsGlobal.GameInterface.emit_signal("set_changed")
	VarsGlobal.GameInterface.emit_signal("alloy_changed")
	var err = Savedata.save_game()
	
	if err == OK:
		_saved = true
		$Sprite / Light2DCustom.visible = false
		$Sprite / AnimatedSprite / Light2DCustom.visible = false
		$Sprite / AnimatedSprite.animation = "destroyed"
		$Sprite / AnimatedSprite.self_modulate.a = 1
		$Sprite / Particles.emitting = false
		Audio.play_sfx("ui_saved")
		Notification.show_notif(tr("GAME_SAVED"))
	else:
		Notification.show_notif("Error Saving: " + str(err))

func _on_InteractableArea2DIndicator_interact_requested() -> void :
	if (
		_saved == false
	):
		save_game()
