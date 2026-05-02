extends Area2D


signal defeated

signal damaged

var ColorFlatShader = preload("res://src/gdshaders/flat_color.gdshader")

export var sprite_flash: NodePath


export (Array, String) var hitboxes = ["all"]



export var max_hits: int = 0

export (Array, String) var damage_sounds = ["enemy_damage_stab"]

export (Array, String) var death_sounds = []


var _last_area_cont_damage_entered = null


var SpriteFlashNode: Object = null

onready var TimeRepeatDamage = $TimeRepeatDamage
onready var TimeContinuedDamage = $TimeContinuedDamage
onready var TimerFlashHit = $TimerFlashHit

func _ready() -> void :
	
	
	if sprite_flash.is_empty() == false:
		SpriteFlashNode = get_node(sprite_flash)
		
		SpriteFlashNode.material = ShaderMaterial.new()
		SpriteFlashNode.material.shader = ColorFlatShader
		SpriteFlashNode.material.set_shader_param("colour", Color("ffffff"))


func play_death_sfx() -> void :
	for s in death_sounds:
		if s.empty() == false:
			Audio.play_sfx(s)

func set_enabled_hurtbox(val: bool = true) -> void :
	
	set_deferred("monitoring", val)
	set_deferred("monitorable", val)
	
	if val == false:
		
		
		remove_from_group("enemy_hurtboxes")
	
	elif is_in_group("enemy_hurtboxes"):
		add_to_group("enemy_hurtboxes")


func _on_HurtBoxEnemy_area_entered(area: Area2D) -> void :

	var damage_indicator_position: Vector2
	
	
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

	
	match area.identifier:
		"whip_h":
			VarsGlobal.GameScenario.show_hit(
				"hit3", facing_to, damage_indicator_position
			)
			VarsGlobal.GameScenario.show_hit_lines(
				"hit_high", facing_to, damage_indicator_position
			)
		"whip_d", "whip_m":
			VarsGlobal.GameScenario.show_hit(
				"hit2", facing_to, damage_indicator_position
			)
			VarsGlobal.GameScenario.show_hit_lines(
				"hit_mid", facing_to, damage_indicator_position
			)
		_:
			VarsGlobal.GameScenario.show_hit(
				"hit1", facing_to, damage_indicator_position
			)
			VarsGlobal.GameScenario.show_hit_lines(
				"hit_low", facing_to, damage_indicator_position
			)
	
	
	match area.identifier:
		"whip_a", "whip_b", "whip_c", "slidekick", "kick":
			VarsGlobal.GameScenario.CameraNode.start_shake(0.2, true, false)
			Gamepad.start_vibration(0, 0.3, 0.2, 0.3)
		"whip_d", "whip_m":
			VarsGlobal.GameScenario.CameraNode.start_shake(0.3, true, false)
			Gamepad.start_vibration(0, 0.8, 0.8, 0.5)
		"whip_h":
			VarsGlobal.GameScenario.CameraNode.start_shake(0.4, false, false)
			Gamepad.start_vibration(0, 0.9, 1.0, 0.7)
	
	
	if area.identifier in hitboxes or hitboxes[0] == "all":
		
		
		emit_signal("damaged")
		
		
		for s in damage_sounds:
			if s.empty() == false:
				Audio.play_sfx(s)
		
		
		if max_hits > 0:
			max_hits -= 1
	
		
		if max_hits == 0:
			set_enabled_hurtbox(false)
			play_death_sfx()
			
			emit_signal("defeated")
	else:
		Audio.play_sfx("ui_incorrect")

	
	if SpriteFlashNode != null:
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
		emit_signal("area_entered", _last_area_cont_damage_entered)



func _on_TimerFlashHit_timeout() -> void :
	SpriteFlashNode.material.set_shader_param("active", false)
