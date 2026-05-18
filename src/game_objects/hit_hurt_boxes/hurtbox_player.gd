extends Area2D

var BloodSpurt = preload("res://src/game_objects/vfx/blood_spurt.tscn")



var damage_multiplier: float = 1

onready var TimerCoolDownDamage = $TimerCoolDownDamage
onready var TimerFloorDamage = $TimerFloorDamage
onready var AreaFoo = $AreaFoo

func _ready() -> void :
	if VarsGlobal.game_data.has("enemy_damage_multiplier"):
		damage_multiplier = VarsGlobal.game_data["enemy_damage_multiplier"]

func reduce_hp(val: int) -> void :
	if DebugMenu.player_no_death == false:
		
		VarsGlobal.game_data["player_hp_now"] = FuncsNumbers.decrease_value(
			val, VarsGlobal.game_data["player_hp_now"]
		)
	
	VarsGlobal.GameScenario.show_damage_number(
		val, global_position - Vector2(0, 25), "red"
	)






func _apply_floor_damage(add_neg_status: int = - 1) -> void :
	
	
	if VarsGlobal.game_data["player_hp_now"] == 0:
		return
	
	var parent: KinematicBody2D = get_parent()
	
	var hp_to_reduce: int = VarsGlobal.game_data["player_hp_max"] / 4
	
	AreaFoo.global_position = VarsGlobal.Player.global_position
	
	reduce_hp(hp_to_reduce)
	
	
	if (
		add_neg_status == 0 and VarsGlobal.game_data["player_poisoned"] == false
		and VarsGlobal.GameInterface.TimerNoNegStatusPoison.is_stopped() == true
	):
		VarsGlobal.GameInterface.apply_negative_status("POISONED")
		VarsGlobal.game_data["player_poisoned"] = true
		VarsGlobal.GameInterface.start_timers_negative_status()
		VarsGlobal.GameInterface.update_hud_values(false)
	if (
		add_neg_status == 1 and VarsGlobal.game_data["player_injured"] == false
		and VarsGlobal.GameInterface.TimerNoNegStatusInjury.is_stopped() == true
	):
		VarsGlobal.GameInterface.apply_negative_status("INJURED")
		VarsGlobal.game_data["player_injured"] = true
		VarsGlobal.GameInterface.start_timers_negative_status()
		VarsGlobal.GameInterface.update_hud_values(false)
	if (
		add_neg_status == 2 and VarsGlobal.game_data["player_cursed"] == false
		and VarsGlobal.GameInterface.TimerNoNegStatusCurse.is_stopped() == true
	):
		VarsGlobal.GameInterface.apply_negative_status("CURSED")
		VarsGlobal.game_data["player_cursed"] = true
		VarsGlobal.GameInterface.start_timers_negative_status()
		VarsGlobal.GameInterface.update_hud_values(false)
	
	
	if VarsGlobal.game_data["player_hp_now"] == 0 and parent.has_method("death"):
		parent.death()
	
	
	
	if parent.has_method("hurt"):
		parent.hurt(2, AreaFoo)


func _on_HurtBoxPlayer_area_entered(area: Area2D) -> void :
	
	
	if VarsGlobal.Player.is_physics_processing() == false:
		return
	
	if (
		VarsGlobal.game_data["player_hp_now"] == 0
		or TimerCoolDownDamage.is_stopped() == false
	):
		return
	TimerCoolDownDamage.start()
	
	var parent: KinematicBody2D = get_parent()
	
	
	var damage_percentage: float = 0.0
	
	
	var knockback_intensity: int = 1
	
	
	var damage: int = 0
	
	var player_def: = VarsGlobal.get_stat("def")
	
	
	var data_enemy: Dictionary
	
	
	var percentage_life_now: int = FuncsNumbers.get_percentage(
		VarsGlobal.game_data["player_hp_now"], 
		VarsGlobal.game_data["player_hp_max"]
	)
	
	
	if area.is_weapon == false:
		data_enemy = CSVDBLoader.get_db("enemies")
	else:
		data_enemy = CSVDBLoader.get_db("enemies_weapons")
	
	
	damage = data_enemy[area.identifier]["atk"]
	
	
	
	
	
	
	if VarsGlobal.game_data["player_injured"] == true and player_def > 0:
		
		player_def = int(player_def / 2)
	
	
	if player_def >= 0:
		damage = int(
			FuncsNumbers.decrease_value(player_def, damage)
		)
	
	else:
		
		damage += abs(player_def)
	
	
	if damage <= 0:
		damage = 1
	
	
	damage = int(damage * damage_multiplier)
	
	var equip_mid_ide: int = VarsGlobal.game_data["player_equip_2"][
		VarsGlobal.game_data["player_current_set"]
	]
	
	
	
	if (
		equip_mid_ide == GVar.EQUIPMENT.CAPEBLOOD
		and VarsGlobal.game_data["player_bl_now"] >= damage
	):
		var blood_to_decrease: int = damage
		
		damage = int(FuncsNumbers.decrease_value(
			VarsGlobal.game_data["player_bl_now"], blood_to_decrease
		))
		
		VarsGlobal.game_data["player_bl_now"] = FuncsNumbers.decrease_value(
			blood_to_decrease * 2, VarsGlobal.game_data["player_bl_now"]
		)
		VarsGlobal.GameInterface.update_hud_values(false)
	
	reduce_hp(damage)

	
	damage_percentage = FuncsNumbers.get_percentage(
		damage, 
		VarsGlobal.game_data["player_hp_max"]
	)
	
	
	
	
	
	if (
		Config.get_value(
			"difficulty", "unbreakable_will", false
		) == true
		and percentage_life_now >= 20
		and damage_percentage >= 60
		and VarsGlobal.game_data["player_hp_now"] == 0
	):
		VarsGlobal.game_data["player_hp_now"] = 1

	
	knockback_intensity = 1
	
	if (
		Config.get_value(
			"difficulty", "dynamic_knockback", false)
	) == true:
	
		if area.knockback_ultra == true:
			knockback_intensity = 0
		
		elif damage_percentage >= 60:
			knockback_intensity = 3

		elif damage_percentage >= 20:
			knockback_intensity = 2
		
		else:
			knockback_intensity = 1
	
	
	if knockback_intensity in [0, 3]:
		VarsGlobal.GameScenario.show_hit_lines(
			"hit_mid", 1, VarsGlobal.Player.BodyNode.global_position
		)
	else:
		VarsGlobal.GameScenario.show_hit_lines(
			"hit_low", 1, VarsGlobal.Player.BodyNode.global_position
		)
	
	var equip_accesory_ide: int = VarsGlobal.game_data["player_equip_0"][
		VarsGlobal.game_data["player_current_set"]
	]
	
	var quantity_blood_spurt: int = 5
	if damage_percentage < 20:
		quantity_blood_spurt = 1
	elif damage_percentage < 50:
		quantity_blood_spurt = 3
	for _n in range(quantity_blood_spurt):
		var ObjInstance = BloodSpurt.instance()
		ObjInstance.global_position = VarsGlobal.Player.BodyNode.global_position
		randomize()
		ObjInstance.global_position += Vector2(rand_range( - 10, 10), rand_range( - 15, 15))
		VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
	
	
	if (
		VarsGlobal.game_data["player_hp_now"] == 0
		or equip_accesory_ide == GVar.EQUIPMENT.DEMONSLAYERARMOR
	) and parent.has_method("death"):
		parent.death()

	
	
	if parent.has_method("hurt"):
		parent.hurt(knockback_intensity, area)
	
	
	if (
		VarsGlobal.game_data["player_hp_now"] > 0 and 
		damage_percentage >= 50 and area.knockback_ultra == false
	):
		Audio.hit_filter_audio_start()
		VarsGlobal.GameScenario.CameraNode.trauma = float(
			VarsGlobal.GameScenario.CameraNode.trauma / 1.5
		)

	
	if DebugMenu.player_no_death == false:
		if area.poison == true and VarsGlobal.GameInterface.TimerNoNegStatusPoison.is_stopped() == true:
			VarsGlobal.GameInterface.apply_negative_status("POISONED")
			VarsGlobal.game_data["player_poisoned"] = true
			VarsGlobal.GameInterface.start_timers_negative_status()
			VarsGlobal.GameInterface.update_hud_values(false)
		if area.curse == true and VarsGlobal.GameInterface.TimerNoNegStatusCurse.is_stopped() == true:
			VarsGlobal.GameInterface.apply_negative_status("CURSED")
			VarsGlobal.game_data["player_cursed"] = true
			VarsGlobal.GameInterface.start_timers_negative_status()
			VarsGlobal.GameInterface.update_hud_values(false)
		if area.injury == true and VarsGlobal.GameInterface.TimerNoNegStatusInjury.is_stopped() == true:
			VarsGlobal.GameInterface.apply_negative_status("INJURED")
			VarsGlobal.game_data["player_injured"] = true
			VarsGlobal.GameInterface.start_timers_negative_status()
			VarsGlobal.GameInterface.update_hud_values(false)


func _on_HurtBoxPlayer_body_entered(body: Node) -> void :
	if body.is_in_group("damage_floor"):
		get_parent().z_index -= 2
		if body.is_in_group("poison"):
			_apply_floor_damage(0)
		elif body.is_in_group("injure"):
			_apply_floor_damage(1)
		elif body.is_in_group("curse"):
			_apply_floor_damage(2)
		else:
			_apply_floor_damage()
		TimerFloorDamage.start()

func _on_HurtBoxPlayer_body_exited(body: Node) -> void :
	if body.is_in_group("damage_floor"):
		get_parent().z_index += 2
		TimerFloorDamage.stop()

func _on_TimerFloorDamage_timeout() -> void :
	_apply_floor_damage()
