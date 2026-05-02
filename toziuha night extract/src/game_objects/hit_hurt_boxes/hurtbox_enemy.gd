extends Area2D




signal defeated

signal damaged


signal defeated_by_weakness

var BloodSpurt = preload("res://src/game_objects/vfx/blood_spurt.tscn")

var CrystalSoul = preload("res://src/game_objects/drop_items/crystal_soul.tscn")

var ColorFlatShader = preload("res://src/gdshaders/flat_color.gdshader")

var BloodOrb = preload("res://src/game_objects/drop_items/blood.tscn")

export var identifier: String = "missingno"

export var is_weapon: bool

export var is_boss: bool

export var sprite_flash: NodePath

export (Array, String) var damage_sounds = ["enemy_damage_stab"]

export (Array, String) var death_sounds = []


export var blood_drop: int = 0

export var emit_defeated_signal: bool = true

export var add_to_death_count_on_defeat: bool = true


var hp_now: int = 0

var hp_max: int = 0


var def: int = 0


var exp_val: int = 0


var data_enemy: Dictionary



var health_multiplier: float = 1


var _last_area_cont_damage_entered = null


var SpriteFlashNode: Object = null


onready var DropNode = $Drop
onready var TimeRepeatDamage = $TimeRepeatDamage
onready var TimeContinuedDamage = $TimeContinuedDamage
onready var TimerFlashHit = $TimerFlashHit
onready var TimerAfterHit = $TimerAfterHit

func _ready() -> void :
	
	if VarsGlobal.game_data.has("enemy_hp_multiplier"):
		health_multiplier = VarsGlobal.game_data["enemy_hp_multiplier"]
	
	
	if sprite_flash.is_empty() == false:
		SpriteFlashNode = get_node(sprite_flash)
		
		SpriteFlashNode.material = ShaderMaterial.new()
		SpriteFlashNode.material.shader = ColorFlatShader
		SpriteFlashNode.material.set_shader_param("colour", Color("ffffff"))
	
	
	if is_weapon == false:
		data_enemy = CSVDBLoader.get_db("enemies")[identifier]
	else:
		data_enemy = CSVDBLoader.get_db("enemies_weapons")[identifier]
	
	if is_weapon == false:
		
		hp_now = int(data_enemy["hp"] * health_multiplier)
		hp_max = hp_now
		
		def = data_enemy["def"]
		exp_val = data_enemy["exp"]
	else:
		hp_now = 1
		hp_max = 1
		def = 0
		exp_val = 0

func set_enabled_hurtbox(val: bool = true) -> void :
	
	set_deferred("monitoring", val)
	set_deferred("monitorable", val)
	
	if val == false and is_in_group("enemy_hurtboxes") == true:
		
		remove_from_group("enemy_hurtboxes")
	
	elif is_in_group("enemy_hurtboxes"):
		add_to_group("enemy_hurtboxes")


func _on_HurtBoxEnemy_area_entered(area: Area2D) -> void :
	
	
	
	if (
		area.continuous_damage == 0.0
		and TimerAfterHit.is_stopped() == false
	):
		return
	TimerAfterHit.start(0.2)
	
	var damage_absorbed: bool = false
	
	var weapon_attrb_elemental: Array
	var is_critic: bool
	
	var current_set = VarsGlobal.game_data["player_current_set"]

	var damage: int = 0
	
	var damage_indicator_position: Vector2
	
	
	def = data_enemy["def"]
	
	
	var facing_to: int = VarsGlobal.GameScenario.get_facing_pointing_to(
		self, area
	)
	
	
	if area.use_player_position_for_hit_effect == true:
		damage_indicator_position = Vector2(
			global_position.x, 
			VarsGlobal.Player.PositionWeaponVertical.global_position.y
		)
	else:
		damage_indicator_position = Vector2(
			global_position.x, area.global_position.y
		) - Vector2(0, 12)

	
	if area.identifier == "kick":
		damage_indicator_position = damage_indicator_position + Vector2(0, 50)

	
	if area.continuous_damage != 0.0 and _last_area_cont_damage_entered == null:
		_last_area_cont_damage_entered = area
		TimeContinuedDamage.start(area.continuous_damage)
		
		TimeRepeatDamage.start()

	
	if area.identifier.begins_with("whip"):
		
		if VarsGlobal.game_data["player_ec_alloy_selected"][current_set] >= 0:
			
			var alloy_key = GVar.ALLOYS.keys()[
				VarsGlobal.game_data["player_ec_alloy_selected"][current_set] + 1
			]
			var alloy_data = CSVDBLoader.get_db("alloys_elements")[alloy_key]
			
			weapon_attrb_elemental = alloy_data["attrb_elemental"].split(",")
	else:
		
		if area.custom_attrb_elemental != "":
			weapon_attrb_elemental = area.custom_attrb_elemental.split(",")
		
		elif area.from_circuit_action != "":
			
			var ec_action_data = CSVDBLoader.get_db("elemental_circuits")[area.from_circuit_action]
			
			weapon_attrb_elemental = ec_action_data["attrb_elemental"].split(",")
	
	

	
	match area.identifier:
		
		"whip_a":
			damage = VarsGlobal.get_stat("atk")
		"whip_b":
			damage = int(VarsGlobal.get_stat("atk") * 1.2)
		"whip_c":
			damage = int(VarsGlobal.get_stat("atk") * 1.3)
		"whip_d":
			damage = int(VarsGlobal.get_stat("atk") * 1.6)
		
		
		"whip_m":
			damage = int(VarsGlobal.get_stat("atk") * 3)
			
			var increase: int = damage * 0.5
			damage = int(damage + increase)
			
			
			
			












		
		"whip_h":
			damage = int(VarsGlobal.get_stat("atk") * 5)
			
			var increase: int = damage * 0.7
			damage = damage + increase
			





			

			




		
		"slidekick", "kick":
			damage = VarsGlobal.get_stat("atk")
			if damage > 0:
				
				damage = damage / 4
		
		_:
			damage = VarsGlobal.get_stat("int")

	
	match area.from_circuit_action:
		"SCUTUM_ALLIGATIOS":
			damage = 1
		
		"PLUVIA_SANGRI", "PERMETRI_AERIA", "FRIGUS_PILAR":
			damage = int(VarsGlobal.get_stat("int") * (50 / 100.0))
			
		
		"RUBRUS_DRACO":
			
			var percent_buff: float = FuncsNumbers.get_percentage(
				VarsGlobal.game_data["player_bl_now"], 
				VarsGlobal.game_data["player_bl_max"]
			) * 1.5
			damage = VarsGlobal.get_stat("int")
			
			damage = int(damage * (percent_buff / 100.0 + 1.0))
			
			VarsGlobal.game_data["player_bl_now"] = FuncsNumbers.decrease_value(
				35, VarsGlobal.game_data["player_bl_now"]
			)
			VarsGlobal.GameInterface.update_hud_values()
	
	


	
	













































	
	if VarsGlobal.game_data["player_injured"] == true and damage > 0:
		
		damage = damage / 2
	
	
	var is_weak: bool
	var is_strong: bool
	
	
	
	var weak = data_enemy["weak"].split(",")
	var strong = data_enemy["strong"].split(",")
	var invulnerable = data_enemy["invulnerable"].split(",")
	var absorb = data_enemy["absorb"].split(",")
	
	for at in weapon_attrb_elemental:
		var attr: String = at.to_lower()
		if attr == "*":
			attr = ""
		
		
		if attr in weak:
			damage = int(damage * 1.5)
			
			is_weak = true
		
		if attr in strong:
			
			damage = int(damage / 2)
			is_strong = true
			Audio.play_sfx("ui_incorrect")
		
		if attr in invulnerable:
			damage = 0
		
		if attr in absorb:
			
			if damage > 0:
				hp_now += damage
				
				VarsGlobal.GameScenario.show_damage_number(
					damage, damage_indicator_position, "green"
				)
				damage_absorbed = true
			damage = 0
			Audio.play_sfx("damage_absorb")

	
	if damage > 0:
		
		randomize()
		var random_value = randf()
		is_critic = false
		
		
		if random_value <= 0.05:
			is_critic = true
			
			
			damage += damage * 0.3
		
		
		damage += area.extra_damage
	
	
	
	damage = int(
		FuncsNumbers.decrease_value(def, damage)
	)
	
	


	
	
	for s in damage_sounds:
		Audio.play_sfx(s)
	
	var equip_mid_ide: int = VarsGlobal.game_data["player_equip_2"][
		VarsGlobal.game_data["player_current_set"]
	]
	
	
	
	
	
	if (
		blood_drop > 0 and area.identifier in ["whip_a", "whip_c"]
		and ElementalCircuits.was_obtained(
			GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.BLOOD_CONTROL
		) == true
		and VarsGlobal.game_data["player_bl_now"] < VarsGlobal.game_data["player_bl_max"]
		and equip_mid_ide != GVar.EQUIPMENT.CAPEBLOOD
	):
		VarsGlobal.GameScenario.spawn_blood_drop(damage_indicator_position)
		VarsGlobal.game_data["player_bl_now"] = int(FuncsNumbers.add_value(
			blood_drop, 
			VarsGlobal.game_data["player_bl_now"], 
			VarsGlobal.game_data["player_bl_max"]
		))
		
		
		if (
			VarsGlobal.Player != null and 
			"AnimationPlayerSpriteVfx" in VarsGlobal.Player and 
			VarsGlobal.game_data["player_bl_now"] == VarsGlobal.game_data["player_bl_max"]
		):
			VarsGlobal.Player.AnimationPlayerSpriteVfx.play("blood_full")
			Audio.play_sfx("blood_full_a")
			Audio.play_sfx("blood_full_b")
		
		
		if VarsGlobal.GameInterface != null:
			VarsGlobal.GameInterface.update_hud_values()
	
	if damage_absorbed == false and is_weapon == false:
		
		if is_strong == true:
			VarsGlobal.GameScenario.show_damage_number(
				damage, damage_indicator_position, "blue", is_critic
			)
		else:
			VarsGlobal.GameScenario.show_damage_number(
				damage, damage_indicator_position, "neutral", is_critic
			)

	
	match area.identifier:
		"whip_a", "whip_b", "whip_c":
			VarsGlobal.GameScenario.show_hit(
				"hit2", facing_to, damage_indicator_position
			)
			VarsGlobal.GameScenario.show_hit_lines(
				"hit_low", facing_to, damage_indicator_position
			)
		"whip_d", "whip_m":
			VarsGlobal.GameScenario.show_hit(
				"hit2", facing_to, damage_indicator_position
			)
			VarsGlobal.GameScenario.show_hit_lines(
				"hit_mid", facing_to, damage_indicator_position
			)
		"whip_h":
			VarsGlobal.GameScenario.show_hit(
				"hit3", facing_to, damage_indicator_position
			)
			VarsGlobal.GameScenario.show_hit_lines(
				"hit_high", facing_to, damage_indicator_position
			)
		_:
			VarsGlobal.GameScenario.show_hit(
				"hit1", facing_to, damage_indicator_position
			)
			VarsGlobal.GameScenario.show_hit_lines(
				"hit_low", facing_to, damage_indicator_position
			)
	
	
	if blood_drop > 0:
		var ObjInstance = BloodSpurt.instance()
		ObjInstance.global_position = damage_indicator_position
		VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
	if is_weak == true:
		Audio.play_sfx("damage_weak")
		Audio.play_sfx("damage_weak2")
		VarsGlobal.GameScenario.show_hit(
			"weak", facing_to, damage_indicator_position
		)
	
	
	match area.identifier:
		"whip_a", "whip_b", "whip_c", "slidekick", "kick":
			VarsGlobal.GameScenario.CameraNode.start_shake(0.2, true, false)
			Gamepad.start_vibration(0, 0.3, 0.1, 0.2)
		"whip_d", "whip_m":
			VarsGlobal.GameScenario.CameraNode.start_shake(0.3, true, false)
			Gamepad.start_vibration(0, 0.8, 0.8, 0.3)
		"whip_h":
			VarsGlobal.GameScenario.CameraNode.start_shake(0.4, false, false)
			Gamepad.start_vibration(0, 0.9, 1.0, 0.7)
	
	
	hp_now = int(FuncsNumbers.decrease_value(damage, hp_now))
	
	
	emit_signal("damaged")
	
	
	if hp_now == 0:
		
		
		if add_to_death_count_on_defeat == true:
			if VarsGlobal.add_exp(exp_val) == true:
				VarsGlobal.GameInterface.show_levelup_reached()
		
		set_enabled_hurtbox(false)
		
		if DropNode != null and identifier.begins_with("boss") == false:
			
			DropNode.drops_list_from_db = data_enemy["drop"]
			DropNode.update_drop_list()
			DropNode.drop()

		
		
		
		if VarsGlobal.game_data["enemies_deaths"].has(identifier) == false:
			VarsGlobal.game_data["enemies_deaths"][identifier] = 0
		VarsGlobal.game_data["enemies_deaths"][identifier] += 1
		
		
		if emit_defeated_signal == true:
			if is_weak == true:
				emit_signal("defeated_by_weakness")
			
			
			emit_signal("defeated")
		
		if is_weapon == false and emit_defeated_signal == true:
			VarsGlobal.GameScenario.emit_signal("enemy_defeated", identifier)
		
		for s in death_sounds:
			Audio.play_sfx(s)
		
		if is_boss == true:
			
			VarsGlobal.GameScenario.show_hit_lines(
				"hit_high", facing_to, damage_indicator_position
			)
			VarsGlobal.GameScenario.show_hit_lines(
				"hit_high", facing_to, damage_indicator_position
			)
			VarsGlobal.GameScenario.show_hit_lines(
				"hit_high", facing_to, damage_indicator_position
			)
			VarsGlobal.GameScenario.CameraNode.start_shake(0.4, false, false)
			Gamepad.start_vibration(0, 0.9, 1.0, 0.7)
			
			
			var ObjInstance = CrystalSoul.instance()
			ObjInstance.global_position = VarsGlobal.GameScenario.CameraNode.get_center_limits()
			VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
		
		












		

	
	if SpriteFlashNode != null and damage > 0:
		SpriteFlashNode.material.set_shader_param("active", true)
		TimerFlashHit.start()

func _on_HurtboxEnemy_area_exited(area: Area2D) -> void :
	
	
	if area.continuous_damage != 0.0 and area == _last_area_cont_damage_entered:
		TimeRepeatDamage.stop()
		TimeContinuedDamage.stop()
		_on_TimeContinuedDamage_timeout()

func _on_TimeContinuedDamage_timeout() -> void :
	_last_area_cont_damage_entered = null

func _on_TimeRepeatDamage_timeout() -> void :
	if _last_area_cont_damage_entered != null:
		_on_HurtBoxEnemy_area_entered(_last_area_cont_damage_entered)



func _on_TimerFlashHit_timeout() -> void :
	SpriteFlashNode.material.set_shader_param("active", false)
