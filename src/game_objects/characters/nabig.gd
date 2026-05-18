extends KinematicBody2D

signal damaged
signal stats_changed
signal floor_exited

signal circuit_charge_started

signal circuit_charge_ended
signal dead

var DustJumpAir = preload("res://src/game_objects/vfx/dust_jump_air.tscn")
var DustJumpFloor = preload("res://src/game_objects/vfx/dust_jump_floor.tscn")
var DustLandingFloor = preload("res://src/game_objects/vfx/dust_landing_floor.tscn")
var DustSlideFloor = preload("res://src/game_objects/vfx/dust_slide_floor.tscn")

var whip_texture_default = preload("res://assets/sprites/whips/default.png")
var whip_texture_c = preload("res://assets/sprites/whips/c.png")
var whip_texture_h = preload("res://assets/sprites/whips/h.png")
var whip_texture_p = preload("res://assets/sprites/whips/p.png")
var whip_texture_ag = preload("res://assets/sprites/whips/ag.png")
var whip_texture_mg = preload("res://assets/sprites/whips/mg.png")
var whip_texture_n = preload("res://assets/sprites/whips/n.png")
var whip_texture_o = preload("res://assets/sprites/whips/o.png")
var whip_texture_xe = preload("res://assets/sprites/whips/xe.png")
var whip_particles_default = preload("res://assets/images/none.png")
var whip_particles_p = preload("res://assets/sprites/vfx/fire_particle.png")
var whip_particles_n = preload("res://assets/sprites/vfx/ice_particle.png")

var IronOxidePowder = preload("res://src/game_objects/weapons/iron_oxide_powder.tscn")
var NaExplosion = preload("res://src/game_objects/weapons/na_explosion.tscn")

const SLOPE_THRESHOLD: = deg2rad(46)

const SNAP_LENGTH: = 8

var near_circuit: bool = false

var state: String = "idle"

var prev_state: String = "idle"

var velocity: = Vector2(0, 0)

var direction: = Vector2(0, 0)

var facing: = 1

const acceleration: float = 1.0
const friction: float = 1.0

var speed_max = 125

var run_vel_multiplier: = 1.0

var stop_on_slope: = false

var fall_multiplier: = 20.0

var jump_velocity: = 287.5

var gravity: = 525.0

var gravity_enabled: = true

var anim_state_machine: AnimationNodeStateMachinePlayback

var anim_current: String

var _floor_normal: = Vector2.UP

var _snap_direction: = Vector2.DOWN

var _snap_vector: = _snap_direction * SNAP_LENGTH

var enabled_input: = true

var _jump_pressed_on_floor: = false

var _num_jumps: = 0

var _max_jumps: = 2

var _was_on_floor: = true

var _last_velocity_y: = 0.0

var _character_ready: = false

var _last_dirx_on_wallslide: = 0

var _knockback_intensity: = - 1

var _aeria_gravity: float = 0.9

var _circuit_oneshot_to_use: int = GVar.EC_ACTION.NONE

var _melee_whip: bool

var _charge_status: String = ""

var _pasive_circuit_enabled = false

var onwall = false

var physics_param: String = "normal"

var is_freezed: bool

onready var BodyNode = $BodyNode

onready var BodySprite = $BodyNode / Sprite
onready var BodySpriteOutline = $BodyNode / Sprite / SpriteOutline

onready var HurtBox = $HurtBoxPlayer

onready var TimerReady = $Timers / TimerReady
onready var TimerReady2 = $Timers / TimerReady2
onready var AutoCrouchTime = $Timers / AutoCrouch
onready var DashTime = $Timers / DashTime
onready var CoyoteTime = $Timers / CoyoteTime
onready var ForwardPressedTime = $Timers / ForwardPressedTime
onready var TimerAfterHurtCrouch = $Timers / TimerAfterHurtCrouch
onready var TimerAfterDamage = $Timers / TimerAfterDamage
onready var CoolDownAirKick = $Timers / CoolDownAirKick
onready var TimeInvencibility = $Timers / TimeInvencibility
onready var TimerMoveMelee = $Timers / TimerMoveMelee

onready var AnimCollisions = $AnimCollisions

onready var AnimPlayer = $AnimationPlayer
onready var AnimTree = $AnimationTree

onready var AnimAtkCharge = $BodyNode / VFXAtkCharge / AnimAtkCharge

onready var AnimationPlayerSpriteVfx = $AnimationPlayerSpriteVfx

onready var AnimResetCols = $AnimDeactivateHBCols

onready var GhostTrail = $BodyNode / GhostTrail
onready var GhostTrailWhip = $BodyNode / GhostTrailWhip
onready var GhostTrailWhipSpecial = $BodyNode / GhostTrailWhipSpecial
onready var GhostTrailWhipCrush = $BodyNode / GhostTrailWhipCrush

onready var RayCastCrouchRoof = $BodyNode / RayCastCrouchRoof
onready var RayCastCrouchRoof2 = $BodyNode / RayCastCrouchRoof2

onready var RayCastOnewayFloor = $BodyNode / RayCastOnewayFloor
onready var RayCastOnewayFloor2 = $BodyNode / RayCastOnewayFloor2

onready var RayCastFrontWall = $BodyNode / RayCastFrontWall
onready var RayCastFrontWall2 = $BodyNode / RayCastFrontWall2

onready var PositionWeaponVertical = $BodyNode / PositionWeaponVertical

onready var BottomSpriteBodyPosition = $BodyNode / BottomSpriteBodyPosition

onready var CircleWhipH = $BodyNode / CircleWhipH
onready var LineGlowWhipH = $BodyNode / LineGlowWhipH

onready var Particles2DWallSlide = $BodyNode / Particles2DWallSlide

onready var Particles2DBloodHurt = $BodyNode / Particles2DBloodHurt
onready var Particles2DWhipBlood = $BodyNode / Particles2DWhipBlood

onready var Particles2DBubbles = $BodyNode / Particles2DBubbles

onready var ParticlesCharge = $BodyNode / ParticlesCharge

onready var PositionHandSwing = $BodyNode / PositionHandSwing

onready var TimerActionCircuit = $Timers / TimerActionCircuit
onready var TimerIdle = $Timers / TimerIdle

onready var Position2DCircuit = $BodyNode / Position2DCircuit
onready var TweenCircuit = $TweenCircuit
onready var ElementalCircuitAction = $BodyNode / ElementalCircuitAction

onready var TimerECACtionCooldown = $Timers / TimerECACtionCooldown

onready var TimerCheckAtkCharge = $Timers / TimerCheckAtkCharge

onready var TimerRecoverFromHurtOnWater = $Timers / TimerRecoverFromHurtOnWater

onready var WhipSprite = $BodyNode / Whip
onready var WhipSpriteEspecial = $BodyNode / WhipEspecial
onready var ParticlesWhip = $BodyNode / ParticlesWhip

onready var PositionEndWhipL = $BodyNode / PositionEndWhipL
onready var Position2DScutum = $BodyNode / Position2DScutum

onready var AnimSpeedCircuit = $BodyNode / SpeedEffect / AnimSpeedCircuit

onready var AetherisGladioSpawner = $BodyNode / AetherisGladioSpawner

func _ready() -> void :
	
	VarsGlobal.Player = self
	
	
	AnimResetCols.play("reset")
	
	GhostTrail.enabled = Config.get_value("gameplay", "player_afterimage", true)
	GhostTrailWhip.enabled = Config.get_value("gameplay", "player_afterimage", true)
	GhostTrailWhipSpecial.enabled = Config.get_value("gameplay", "player_afterimage", true)
	GhostTrailWhipCrush.enabled = Config.get_value("gameplay", "player_afterimage", true)
	
	
	anim_state_machine = $AnimationTree.get("parameters/playback")
	
	
	VarsGlobal.GameScenario.get_node("CommandInputDetect").connect(
		"command_executed", self, "execute_command"
	)
	
	
	facing = VarsGlobal.game_data["player_facing"]
	_set_body_scale_x(facing)
	
	_stop_circuit_action_charge()
	
	AnimTree.active = true
	
	ElementalCircuitAction.visible = true
	
	
	BodySpriteOutline.hframes = BodySprite.hframes
	BodySpriteOutline.vframes = BodySprite.vframes
		
	
	TimerReady.start()
	yield(TimerReady, "timeout")
	_character_ready = true
	
	VarsGlobal.GameInterface.connect(
		"alloy_changed", self, "_update_whip_texture"
	)
	VarsGlobal.GameInterface.connect(
		"set_changed", self, "_update_whip_texture"
	)
	_update_whip_texture()
	
	
func _physics_process(delta: float) -> void :
	
	if is_freezed == true:
		return
	
	BodySpriteOutline.modulate = BodySprite.modulate
	
	onwall = _is_player_pushing_solid()
	
	
	if is_on_floor() == false and velocity.y * (_floor_normal.y * - 1) > 100:
		ParticlesWhip.emitting = false
	
	
	if velocity.y > 0:
		_last_velocity_y = velocity.y
	
	anim_current = anim_state_machine.get_current_node()
	
	_was_on_floor = is_on_floor()
	
	
	
	if is_on_floor() and (
		get_floor_velocity().x != 0 or get_floor_velocity().y != 0
	):
		stop_on_slope = false
	else:
		stop_on_slope = true
	
	
	if _character_ready:
		_get_input()
	
	_jump_physics()
		
	
	
	
	_attempt_correction(7.5, delta)
	
	
	
	
	if (
		_character_ready and gravity_enabled
		and CoyoteTime.is_stopped()
		and state != "swing"
	):
		
		velocity.y -= (gravity * _floor_normal.y) * delta
		
		
		if state == "wallslide":
			Gamepad.start_vibration(0, 0.1, 0.1, 0.1)
			velocity.y = velocity.y * 0.7
			
			if Particles2DWallSlide.emitting == false:
				Particles2DWallSlide.emitting = true
		
		

		
		if anim_current == "dodge_air":
			velocity.y = 0
		
		if state == "circuit-charge":
			velocity.y = 0
			velocity.x = 0
	
	
	velocity = move_and_slide_with_snap(
		velocity, _snap_vector, _floor_normal, 
		stop_on_slope, 4, SLOPE_THRESHOLD
	)

	
	
	
	if (
		not is_on_floor() and _was_on_floor and state in ["run", "changedir"]
		
	):
		CoyoteTime.start()
		velocity.y = 0
	
	
	_fix_state()

	
	_player_touched_floor()
	
	
	
	
	if velocity.y > 600 and is_on_floor() == false:
		velocity.y = 600
	
	

func execute_command(command_name: String) -> void :
	if enabled_input == false:
		return
	match command_name:
		"hadouken":
			whipCrush()
		"whip_spin":
			whipSpin()
		"k_code":
			if get_tree().get_nodes_in_group("quick_text").size() == 0:
				Audio.play_sfx("k")
				VarsGlobal.GameInterface.show_quick_text(
					"I am the morning sun, come to vanquish this horrible night!", self
				)

func change_state(
	new_state: String, force_change: bool = false, travel_anim: bool = true
) -> void :
	
	
	if state == "dead" and new_state != "dead":
		return

	var animation_name = new_state
	
	if new_state != state or force_change == true:
		
		TimerIdle.start()

		
		AnimResetCols.play("reset")
		
		
		if near_circuit == true:
			emit_signal("circuit_charge_ended")
		
		if BodySprite.modulate == Color.pink:
			BodySprite.modulate = Color.white
		
		
		
		WhipSprite.visible = true
		WhipSpriteEspecial.visible = true
		WhipSprite.frame = 0
		WhipSpriteEspecial.frame = 0
		$BodyNode / DustSlideFloorSmall.visible = true
		$BodyNode / Crush.modulate.a = 0
		
		ParticlesWhip.emitting = false

		
		Particles2DBloodHurt.emitting = false
		Particles2DWhipBlood.emitting = false
		
		Particles2DWallSlide.emitting = false
		
		ParticlesCharge.emitting = false
		ParticlesCharge.modulate = Color("ff7b00")
		ParticlesCharge.speed_scale = 1
		
		CircleWhipH.visible = false
		LineGlowWhipH.visible = false
		
		AnimAtkCharge.play("RESET")
		
		
		prev_state = state
		state = new_state
		
		match state:

			"idle":
				animation_name = "idle-guard"
			
			"pos-crouch":
				state = "crouch"
			
			"attack_power-a", "attack_power-b", "attack_power-c", "attack_power-d", "attack_power-spin", "attack_power-h", "attack_power-charge", "attack_power-m":
				
				
				

				
				

				
				state = "attack"
			
			"throw":
				if is_on_floor() == false:
					animation_name = "throw-air"
				elif prev_state == "crouch" and is_on_floor() == true:
					animation_name = "throw-crouch"
				elif is_on_floor() == true:
					animation_name = "throw"
				state = "attack"

			"attack_power-crouch", "throw-crouch":
				state = "attack-crouch"
			
			"jump":
				
				if (
					(_num_jumps > 1 and _jump_pressed_on_floor)
					or prev_state == "wallslide"
				):
					animation_name = "jump-up-2"
					
					var jump_air_instance = DustJumpAir.instance()
					jump_air_instance.scale.y = BodyNode.scale.y
					
					if BodyNode.scale.y == 1:
						jump_air_instance.global_position = global_position - Vector2(0, 50)
					else:
						jump_air_instance.global_position = global_position
					
					VarsGlobal.GameScenario.add_child(jump_air_instance)

				
				
				elif direction.x != 0 and abs(velocity.x) > 20.0:
					animation_name = "jump-diag"
				
				else:
					animation_name = "jump-up"
			
			"air-kick":
				if direction.x != 0:
					animation_name = "air-kick-diag"
				else:
					animation_name = "air-kick-down"
			
			"backdash", "dodge":
				if is_on_floor() == true:
					_spawn_slide_dust()
				state = "dash"
			
			"circuit-charge":
				animation_name = "circuit"
			
			"hurt":
				if _player_can_stand() == false:
					animation_name = "pos-crouch"
		
		if travel_anim:
			anim_state_machine.travel(animation_name)
		else:
			anim_state_machine.start(animation_name)
			
		Audio.stop_sfx("ec_charging")
		
		
		match state:
			"crouch", "attack-crouch", "slide":
				_change_collision("crouch")
			"idle", "fall", "sit", "mark", "hurt":
				_change_collision("stand")

		
		if state in ["slide", "crouch"] and get_floor_velocity() == Vector2.ZERO:
			GhostTrail.start_trail(0.5, 0.08)
		elif state in ["dash"]:
			if animation_name == "dodge":
				GhostTrail.start_trail(0.5, 0.1)
			elif animation_name == "backdash":
				GhostTrail.start_trail(0.3, 0.1)
			elif state in ["air-kick"]:
				GhostTrail.start_trail(0.5, 0.01)
			else:
				GhostTrail.start_trail()
		else:
			GhostTrail.stop_trail()
			GhostTrailWhip.stop_trail()
			GhostTrailWhipSpecial.stop_trail()
			GhostTrailWhipCrush.stop_trail()

func move(dir: Vector2 = Vector2.ZERO) -> void :
	
	var equip_mid_ide: int = VarsGlobal.game_data["player_equip_2"][
		VarsGlobal.game_data["player_current_set"]
	]
	
	var equip_bottom_ide: int = VarsGlobal.game_data["player_equip_3"][
		VarsGlobal.game_data["player_current_set"]
	]
	
	if equip_bottom_ide == GVar.EQUIPMENT.HERMES_BOOTS and enabled_input == true:
		if physics_param == "normal":
			speed_max = 140
		else:
			speed_max = 90
	elif equip_bottom_ide == GVar.EQUIPMENT.WEIGHT_BOOTS and enabled_input == true:
		if physics_param == "normal":
			speed_max = 90
		else:
			speed_max = 60
	elif physics_param == "normal":
		speed_max = 125
	elif physics_param == "water":
		speed_max = 75
	
	
	if (
		equip_mid_ide == GVar.EQUIPMENT.SWIMSUIT
		and physics_param == "water"
		and enabled_input == true
	):
		speed_max = speed_max * 1.7
	
	
	if dir.x != 0:
		
		if anim_current == "attack_power-charge":
			facing = int(dir.x)
			_set_body_scale_x(facing)
			return
		
		
		if state in ["attack", "attack-crouch"] and is_on_floor():
			velocity.x = 0
			return
		
		
		elif state != "crouch":
			
			if is_on_floor():

				velocity.x = dir.x * (speed_max * run_vel_multiplier)
			
			else:
				velocity.x = lerp(
					velocity.x, dir.x * (speed_max * run_vel_multiplier), 0.1
				)
		
		
		if (
			facing != dir.x
			and anim_state_machine.get_current_node() != "changedir"
		):
			_change_sprite_facing(int(dir.x))

		direction = dir

func stop_move() -> void :
	
	
	
	velocity.x = 0
	direction.x = 0
	DashTime.stop()

func whip_attack(wtype: String = "attack_power-a") -> void :
	
	
	
	
	
	
	if (
		state != "attack" and state != "attack-crouch"
		and anim_current.begins_with("attack_power") == false
	):
		
		if is_on_floor():
			velocity.x = 0
		
		VarsGlobal.GameScenario.cancel_quick_menu_use()
		
		
		
		if (
			Input.is_action_pressed("ui_up")
			and ElementalCircuits.was_obtained(
				GVar.EC_MODE.ABILITY, 
				GVar.EC_ABILITY.BLADE_WHIP
			) == true
			and is_on_floor() == true
		):
			_charge_status = ""
			Audio.play_sfx("atk_charge_prepare")
			Audio.play_sfx("whip_chain_m")
			change_state("attack_power-charge", false, false)
			if VarsGlobal.game_data["player_bl_now"] >= 20:
				TimerCheckAtkCharge.start(0.3)
			else:
				TimerCheckAtkCharge.start(0.5)
			return

		change_state(wtype, false, false)

	
	elif state == "attack" and ElementalCircuits.was_obtained(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.CHAINED_ATTACK
	) == true and Input.is_action_pressed("ui_down") == false:
		var percentage_timeline: int = int(
			(
				anim_state_machine.get_current_play_position()
				/ anim_state_machine.get_current_length()
			) * 100
		)
		
		
		if anim_current == "attack_power-a" and percentage_timeline >= 35:
			_melee_whip = true
			
			return
		elif anim_current == "attack_power-b" and percentage_timeline >= 20:
			_melee_whip = true
			
			return
		elif anim_current == "attack_power-c" and percentage_timeline >= 20:
			_melee_whip = true
			
			return
		elif anim_current == "attack_power-d":
			_melee_whip = true
			
			return

	
	else:
		_melee_whip = false

func whip_spawn_subitem() -> void :
	pass

func play_action_sound(atk_name: String) -> void :
	match atk_name:
		"whip-crack":
			Audio.play_sfx("whip_crack_rnd")
		"whip-wosh-chain":
			Audio.play_sfx("whip_wosh_rnd")
			Audio.play_sfx("whip_chain_rnd")
			
			Audio.play_voice("xandria_atk")
		"attack_power-spin-air":
			Audio.play_sfx("whip_chain_m")
		"attack_power-l", "attack_power-crouch":
			Audio.stop_sfx("woosh_jump")
			Audio.stop_sfx("woosh_jump2")
			Audio.play_sfx("whip_chain_l")
			Audio.play_sfx("woosh_knife")
		"whip-m":
			Audio.play_sfx("whip_chain_m")
			Audio.play_sfx("woosh_whip_m")
			
			Audio.play_voice("xandria_atk")
		"attack_power-h":
			Audio.play_sfx("whip_chain_h")
			Audio.play_sfx("woosh_whip_m")
			Audio.play_voice("xandria_shout")
		"backdash":
			Audio.play_sfx("floor_backdash")
			Audio.play_sfx("woosh_knife")
		_:
			Audio.play_sfx(atk_name)

func crouch() -> void :
	
	if Input.is_action_pressed("quickmenu"):
		return
	change_state("crouch", false, false)
	stop_move()

func jump(weakness: float = 1.0, change_st: bool = true, add_jump_count: bool = true) -> void :
	
	
	if is_on_floor() or CoyoteTime.is_stopped() == false:
		_jump_pressed_on_floor = true
	
	
	velocity.y = 0
	
	
	_snap_vector = Vector2.ZERO

	if change_st:
		change_state("jump", false, false)

	
	velocity.y += (jump_velocity / weakness) * _floor_normal.y

	
	
	
	
	
	
	
	if is_on_floor() and get_floor_velocity() == Vector2.ZERO:
		var jump_dust_floor = DustJumpFloor.instance()
		jump_dust_floor.global_position = BottomSpriteBodyPosition.global_position
		jump_dust_floor.scale.y = BodyNode.scale.y
		VarsGlobal.GameScenario.add_child(jump_dust_floor)
	
	if add_jump_count and is_on_floor() or CoyoteTime.is_stopped() == false:
		_num_jumps += 1
	
	
	
	elif add_jump_count:
		_num_jumps = _max_jumps
	
	
	if _num_jumps > 1 and change_st:
		change_state("jump", true, false)
	
	
	if _num_jumps == 1:
		Audio.play_sfx("woosh_jump")
	else:
		Audio.play_sfx("woosh_jump2")
	
	CoyoteTime.stop()

func air_kick() -> void :
	if VarsGlobal.game_data["player_sp_now"] < 20:
		return
	VarsGlobal.game_data["player_sp_now"] = int(FuncsNumbers.decrease_value(
		20, VarsGlobal.game_data["player_sp_now"]
	))
	emit_signal("stats_changed")
	VarsGlobal.GameInterface.update_stamina_stats()
	
	
	if CoolDownAirKick.is_stopped() == false:
		return
	CoolDownAirKick.start(0.6)
	
	change_state("air-kick", false, false)
	
	velocity.y = 0
	velocity.y += (jump_velocity * 1.5) * (_floor_normal.y * - 1)
	
	if direction.x != 0:
		velocity.x = (speed_max * 3) * direction.x
	play_action_sound("woosh_airkick")

func slide() -> void :
	if VarsGlobal.game_data["player_sp_now"] < 15:
		return
	TimerMoveMelee.stop()
	VarsGlobal.game_data["player_sp_now"] = int(FuncsNumbers.decrease_value(
		15, VarsGlobal.game_data["player_sp_now"]
	))
	emit_signal("stats_changed")
	VarsGlobal.GameInterface.update_stamina_stats()
	
	change_state("slide", false, false)
	velocity.x = (speed_max * 1.8) * facing
	DashTime.start(0.4)
	Gamepad.start_vibration(0, 0.2, 0.1, 0.3)
	
	VarsGlobal.GameScenario.cancel_quick_menu_use()
	

func dodge() -> void :
	if VarsGlobal.game_data["player_sp_now"] < 30:
		return

	if state.ends_with("crouch"):
		return

	velocity.x = 0
	TimerMoveMelee.stop()
	VarsGlobal.game_data["player_sp_now"] = int(FuncsNumbers.decrease_value(
		30, VarsGlobal.game_data["player_sp_now"]
	))
	emit_signal("stats_changed")
	VarsGlobal.GameInterface.update_stamina_stats()
	
	BodySprite.modulate.a = 1
	
	change_state("dodge", false, false)
	
	Audio.play_sfx("woosh_whip_m")
	
	velocity.x = (speed_max * 1.2) * facing
	Audio.play_voice("xandria_move")
	invencibility(0.5, false)
	DashTime.start(0.57)
	
	VarsGlobal.GameScenario.cancel_quick_menu_use()

func dash() -> void :
	if (
		VarsGlobal.game_data["player_sp_now"] < 40
		or state.ends_with("crouch")
		or is_on_floor() == true
	):
		return

	velocity = Vector2.ZERO
	TimerMoveMelee.stop()
	VarsGlobal.game_data["player_sp_now"] = int(FuncsNumbers.decrease_value(
		40, VarsGlobal.game_data["player_sp_now"]
	))
	emit_signal("stats_changed")
	VarsGlobal.GameInterface.update_stamina_stats()
	
	BodySprite.modulate.a = 1
	
	change_state("dodge", false, false)
	anim_state_machine.start("dodge_air")
	Audio.play_sfx("woosh_whip_m")
	Audio.play_sfx("dash_air")
	velocity.x = (speed_max * 2) * facing
	invencibility(0.3, false)
	DashTime.start(0.5)
	Gamepad.start_vibration(0, 0.6, 0.7, 0.3)
	VarsGlobal.GameScenario.cancel_quick_menu_use()

func backdash() -> void :
	if VarsGlobal.game_data["player_sp_now"] < 15 or state.ends_with("crouch"):
		return
	velocity.x = 0
	TimerMoveMelee.stop()
	VarsGlobal.game_data["player_sp_now"] = int(FuncsNumbers.decrease_value(
		10, VarsGlobal.game_data["player_sp_now"]
	))
	emit_signal("stats_changed")
	
	VarsGlobal.GameInterface.update_stamina_stats()
	stop_move()
	velocity.x = (speed_max * 1.1) * (facing * - 1)
	
	change_state("backdash", false, false)
	
	DashTime.start(0.48)
	Gamepad.start_vibration(0, 0.2, 0.1, 0.3)
	play_action_sound("backdash")
	invencibility(0.2, false)
	
	VarsGlobal.GameScenario.cancel_quick_menu_use()

func drop_from_floor() -> void :
	if _floor_normal.y == - 1:
		position.y = position.y + 11
	else:
		position.y = position.y - 11

func hurt(knockback_intensity: int, damage_area: Object) -> void :
	
	if enabled_input == false:
		return
	
	BodySprite.modulate = Color.white
	
	emit_signal("damaged")
	emit_signal("stats_changed")
	Input.action_release("ui_up")
	velocity.x = 0
	_stop_circuit_action_charge()
	TimerMoveMelee.stop()
	VarsGlobal.GameScenario.cancel_quick_menu_use()
	if state != "dead":
		invencibility()
		var knockback_dir = VarsGlobal.GameScenario.get_facing_pointing_to(
			self, damage_area
		)
		knockback(knockback_intensity, knockback_dir)
	else:
		Gamepad.start_vibration(0, 1.0, 1.0, 3.0)

	if physics_param == "water":
		TimerRecoverFromHurtOnWater.start()
	elif _player_can_stand() == true:
		TimerAfterDamage.start()

func invencibility(time_inv: float = 1.7, modulate_sprite: bool = true) -> void :
	if modulate_sprite:
		BodySprite.modulate.a = 0.5
	HurtBox.set_deferred("monitoring", false)
	TimeInvencibility.start(time_inv)

func endgame() -> void :
	
	
	if state == "dead":
		return
	
	emit_signal("dead")
	
	change_state("dead", true, false)
	
	Audio.play_sfx("impact_player_hurt")
	Audio.play_voice("xandria_death_large")
	
	BodySprite.modulate.a = 1.0
	BodySpriteOutline.visible = false
	
	set_process(false)
	set_physics_process(false)
	
	
	AnimResetCols.play("reset")
				
	
	Particles2DBloodHurt.emitting = true
	Particles2DBloodHurt.lifetime = 10
	Particles2DBloodHurt.lifetime_randomness = 1
	
	
	var TwDeath = get_tree().create_tween()
	TwDeath.tween_property(self, "position", position + Vector2(0, - 100), 10)
	
	
	modulate = Color("ff0000")

func knockback(intensity: int = 1, dir: int = 1) -> void :
	
	var equip_bottom_ide: int = VarsGlobal.game_data["player_equip_3"][
		VarsGlobal.game_data["player_current_set"]
	]
	
	
	if (
		equip_bottom_ide == GVar.EQUIPMENT.WEIGHT_BOOTS
		and intensity in [0, 2, 3]
	):
		intensity = 2
		pass
	
	if intensity == 0:
		Audio.play_sfx("impact_player_hurt2")
		Audio.play_voice("xandria_death_medium")
	else:
		Audio.play_sfx("impact_player_hurt")
		Audio.play_voice("xandria_damage")
	
	
	DashTime.stop()
	velocity = Vector2.ZERO
	
	
	if _player_can_stand() == false:
		
		
		TimerAfterHurtCrouch.start()
		change_state("pos-crouch", true, false)
		return
	
	
	elif is_freezed == false:
		
		facing = dir * - 1
		VarsGlobal.game_data["player_facing"] = facing
		_set_body_scale_x(dir * - 1)
	
	
	
	_knockback_intensity = intensity

	
	
	if Input.is_action_pressed("ui_down"):
		Input.action_release("ui_down")

	change_state("hurt", true, false)

	
	_snap_vector = Vector2.ZERO
	
	
	
	match intensity:
		0:
			_shake_camera(0.5, true, false)
			Gamepad.start_vibration(0, 1.0, 1.0, 0.8)
			GhostTrail.start_trail()
		1:
			_shake_camera(0.4, true, false)
			Gamepad.start_vibration(0, 0.3, 0.0, 0.3)
		2:
			_shake_camera(0.6, true, false)
			Gamepad.start_vibration(0, 0.4, 0.1, 0.3)
		3:
			
			_shake_camera(0.6, true, false)
			Gamepad.start_vibration(0, 0.8, 0.8, 0.6)
			GhostTrail.start_trail(5.0, 0.1)
	
	
	velocity.x = 0
	
	
	match intensity:
		0:
			velocity.y = 250 * _floor_normal.y
			velocity.x = 500 * dir
		1:
			velocity.y = 75 * _floor_normal.y
			velocity.x = 25 * dir
		2:
			velocity.y = 150 * _floor_normal.y
			velocity.x = 75 * dir
		3:
			velocity.y = 200 * _floor_normal.y
			velocity.x = 100 * dir

func invert_gravity() -> void :
	
	
	if _player_can_stand() == false:
		Audio.play_sfx("ui_not_enough_mana")
		return
	
	velocity.y = 0
	
	if _floor_normal == Vector2.UP:
		_floor_normal = Vector2.DOWN
		_snap_direction = Vector2.UP
		BodyNode.scale.y = - 1
	
	else:
		_floor_normal = Vector2.UP
		_snap_direction = Vector2.DOWN
		BodyNode.scale.y = 1

func auto_crouch(secs: float = 0.5):
	
	

	velocity.x = 0
	Gamepad.start_vibration(0, 0.2, 0.5, 0.3)
	
	AutoCrouchTime.wait_time = secs
	AutoCrouchTime.start()
	change_state("crouch", false, false)
	yield(AutoCrouchTime, "timeout")
	TimerAfterDamage.stop()
	
	if (
		Input.is_action_pressed("ui_down") == false
		and is_on_floor() == true
		and _player_can_stand() == true
	):
		change_state("idle")

func set_enabled_input(enable: bool = true) -> void :
	Input.action_release("ui_down")
	enabled_input = enable
	VarsGlobal.GameInterface.set_visible_vgamepad(enable)

func reset_num_jumps() -> void :
	_num_jumps = 0

func change_physics_params(param: String = "normal") -> void :

	
	if state == "slide":
		return
	
	physics_param = param
	match param:
		"water":
	
			
			velocity.y = 0
			velocity.x = 0
			
			
			
			fall_multiplier = 2.5
			jump_velocity = 225
			gravity = 200
			Particles2DBubbles.emitting = true
			
			if state in ["air-kick", "wallslide"]:
				change_state("fall", true, false)
			
		
		_:
			
			
			fall_multiplier = 20
			jump_velocity = 287.5
			gravity = 525
			Particles2DBubbles.emitting = false

func whipCrush() -> void :
	if (
		_player_can_stand()
		and ElementalCircuits.was_obtained(
			GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.WHIP_CRUSH
		)
	):
		
		if VarsGlobal.game_data["player_bl_now"] < VarsGlobal.game_data["player_bl_max"]:
			Audio.play_sfx("ui_not_enough_mana")
			return
		whip_attack("attack_power-h")
		
		VarsGlobal.game_data["player_bl_now"] = 0
		
		if VarsGlobal.GameInterface != null:
			VarsGlobal.GameInterface.update_hud_values()

func whipSpin() -> void :
	pass

func _move_char_melee(_move: int = 500) -> void :
	return

func _blood_cost_apply(cost: int = 10) -> bool:
	var bl_now: int = VarsGlobal.game_data["player_bl_now"]
	var bl_spend: int = cost
	if bl_now >= bl_spend:
		VarsGlobal.game_data["player_bl_now"] = FuncsNumbers.decrease_value(
			bl_spend, VarsGlobal.game_data["player_bl_now"]
		)
		emit_signal("stats_changed")
		return true
	return false

func _update_whip_texture() -> void :
	_enable_circuit_effect(false)
	ParticlesWhip.emitting = false
	yield(get_tree(), "idle_frame")
	var alloy_equiped: int = VarsGlobal.game_data["player_ec_alloy_selected"][
		VarsGlobal.game_data["player_current_set"]
	]
	
	ParticlesWhip.texture = whip_particles_default
	
	match alloy_equiped:
		GVar.ALLOYS.C:
			WhipSprite.texture = whip_texture_c
		GVar.ALLOYS.H:
			WhipSprite.texture = whip_texture_h
		GVar.ALLOYS.P:
			WhipSprite.texture = whip_texture_p
			ParticlesWhip.texture = whip_particles_p
		GVar.ALLOYS.AG:
			WhipSprite.texture = whip_texture_ag
		GVar.ALLOYS.MG:
			WhipSprite.texture = whip_texture_mg
		GVar.ALLOYS.N:
			WhipSprite.texture = whip_texture_n
			ParticlesWhip.texture = whip_particles_n
		GVar.ALLOYS.O:
			WhipSprite.texture = whip_texture_o
		GVar.ALLOYS.XE:
			WhipSprite.texture = whip_texture_xe
		
		
		_:
			
			WhipSprite.texture = whip_texture_default
			ParticlesWhip.texture = whip_particles_default
	

func _start_circuit_action_charge() -> void :

	VarsGlobal.GameScenario.cancel_quick_menu_use()

	
	var activation_time: int = ElementalCircuits.get_circuit_action_time(
		VarsGlobal.game_data["player_ec_action_selected"][VarsGlobal.game_data["player_current_set"]]
	)
	
	ElementalCircuitAction.modulate.a = 1
	
	
	ElementalCircuitAction.action = VarsGlobal.game_data["player_ec_action_selected"][VarsGlobal.game_data["player_current_set"]]
	
	
	ElementalCircuitAction.global_position = Position2DCircuit.global_position
	
	ElementalCircuitAction.AnimPlayer.play("idle")

	

	
	
	if is_on_floor():
		stop_move()
	
	
	TimerActionCircuit.wait_time = activation_time
	TimerActionCircuit.start()

	
	TweenCircuit.interpolate_property(
		ElementalCircuitAction, "scale", 
		Vector2(0, 0), Vector2(1, 1), activation_time
	)
	TweenCircuit.start()

	
	state = "circuit-charge"
	
	
	
	
	if is_on_floor() == true:
		anim_state_machine.travel("circuit")
	else:
		anim_state_machine.travel("circuit-air")

	ElementalCircuitAction.start_vibration()
	Audio.play_sfx("ec_charging", false)

func spawn_action_circuit(pos_spawn: Vector2 = PositionWeaponVertical.global_position) -> void :

	if _circuit_oneshot_to_use == GVar.EC_ACTION.NONE:
		return
	
	
	ElementalCircuitAction.action = - 1

	
	ElementalCircuitAction.global_position = pos_spawn

	ElementalCircuitAction.AnimPlayer.play("idle")
	
	ElementalCircuitAction.AnimPlayer.stop(true)
	ElementalCircuitAction.scale = Vector2(1, 1)
	
	ElementalCircuits.spawn_action_circuit(
		_circuit_oneshot_to_use, PositionWeaponVertical.global_position
	)
	
	Audio.stop_sfx("ec_charging")
	Audio.play_voice("xandria_atk")
	Audio.play_sfx("ec_shoot")
	Audio.play_sfx("woosh_jump")
	
	ElementalCircuitAction.AnimPlayer.play("show_fast")
	
	VarsGlobal.GameScenario.cancel_quick_menu_use()

func _enable_circuit_effect(enable: bool = true) -> void :
	var current_circuit: int = VarsGlobal.game_data["player_ec_action_selected"][VarsGlobal.game_data["player_current_set"]]
	
	if enable == true:
		
		var mana_cost: int = ElementalCircuits.get_circuit_mp_cost(
			GVar.EC_MODE.ACTION, current_circuit
		)
		
		
		if VarsGlobal.game_data["player_mp_now"] < mana_cost:
			Audio.play_sfx("ui_incorrect")
			_pasive_circuit_enabled = false
			return
		
		Audio.play_sfx("ec_pasive_activate")
		
		Gamepad.start_vibration(0, 0.2, 0.1, 0.3)
		
		
		ElementalCircuits.apply_mana_cost(
			GVar.EC_MODE.ACTION, current_circuit
		)
	
		match current_circuit:
			GVar.EC_ACTION.RAPIS_MOTUS:
				run_vel_multiplier = 3
				AnimSpeedCircuit.play("active")
			GVar.EC_ACTION.AETHERIS_GLADIO:
				AetherisGladioSpawner.start(1, facing)
				_enable_circuit_effect(false)
				return
			
			
	
	else:
		match current_circuit:
			GVar.EC_ACTION.RAPIS_MOTUS:
				
				run_vel_multiplier = 1
				stop_move()
				
		if AnimSpeedCircuit.current_animation == "active":
			AnimSpeedCircuit.play("inactive")
		
	_pasive_circuit_enabled = enable

func _stop_circuit_action_charge() -> void :

	ElementalCircuitAction.stop_vibration()
	Audio.stop_sfx("ec_charging")
	TweenCircuit.remove_all()
	TimerActionCircuit.stop()
	ElementalCircuitAction.modulate = Color("ffffff")
	ElementalCircuitAction.scale = Vector2(0, 0)
	
	
	if state == "circuit-charge":
		if _player_can_stand() == false:
			change_state("crouch", true, false)
		elif is_on_floor():
			change_state("idle")
		else:
			change_state("fall")

func _spawn_slide_dust() -> void :
	
	var slide_dust = DustSlideFloor.instance()
	slide_dust.scale = BodyNode.scale
	slide_dust.node_emitter = self
	slide_dust.node_target = BottomSpriteBodyPosition
	if state == "dodge":
		slide_dust.scale.x = BodyNode.scale.x * - 1
	VarsGlobal.GameScenario.add_child(slide_dust)

func _is_player_pushing_solid() -> bool:
	
	
	var pushed_body = null
	
	
	
	if (
		is_on_floor() == false and 
		(RayCastFrontWall.is_colliding() or RayCastFrontWall2.is_colliding())
	):
		
		
		pushed_body = RayCastFrontWall
		
		if pushed_body == null:
			pushed_body = RayCastFrontWall2
		
		
		
		if (
			(pushed_body.global_position.x > global_position.x and direction.x == 1)
			or (pushed_body.global_position.x < global_position.x and direction.x == - 1)
		):
			return true
	
	return false

func _is_player_on_oneway_floor() -> bool:
	if RayCastOnewayFloor.is_colliding() or RayCastOnewayFloor2.is_colliding():
		return true
	return false

func _player_can_stand() -> bool:
	if (
		RayCastCrouchRoof.is_colliding() == true
		or RayCastCrouchRoof.is_colliding() == true
	):
		return false
	else:
		return true

func _get_input() -> void :

	if (
		enabled_input == false
		or state in ["air-kick", "slide"]
		or anim_current in ["dodge"]
		or TimerAfterDamage.is_stopped() == false
		or TimerRecoverFromHurtOnWater.is_stopped() == false
		or DebugMenu.using_console == true
		or AutoCrouchTime.is_stopped() == false
	):
		return
		
	if anim_current == "attack_power-charge" and Input.is_action_just_released("attack"):
		if _charge_status == "charged-blood":
			change_state("attack_power-m", true, false)
		elif _charge_status == "charged":
			change_state("attack_power-d", true, false)
		else:
			change_state("attack_power-a", true, false)
		_charge_status = ""
		AnimAtkCharge.play("RESET")
		return
	
	
	
	if (
		Input.is_action_pressed("ui_up")
		and state != "circuit" and state != "circuit-charge"
		and is_on_floor()
		and near_circuit == true
		and direction.x == 0
	):
		stop_move()
		change_state("circuit", true, true)
	
	
	if Input.is_action_just_released("ui_up") and state == "circuit":
		change_state("idle")
	
	
	if Input.is_action_just_released("circuit") and state == "circuit-charge":
		_stop_circuit_action_charge()
	
	
	if state in ["circuit", "circuit-charge"]:
		return
	
	
	if (
		(
			Input.is_action_just_pressed("ui_left")
			or Input.is_action_just_pressed("ui_right")
		)
		and _is_forward_dir_pressed()
	):
		ForwardPressedTime.start()
	
	
	
	
	if (
		direction.x != _last_dirx_on_wallslide
		and _is_player_pushing_solid()
		and state == "fall"
		and ElementalCircuits.was_obtained(
			GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.WALL_SLIDE
		)
		and physics_param == "normal"
	):
		_last_dirx_on_wallslide = int(direction.x)
		_num_jumps = 0
		velocity.y = 0
		change_state("wallslide", false, false)
	
	
	
	
	
	if (
		state != "dash" and 
		Input.is_action_pressed("ui_left")
		and not Input.is_action_pressed("ui_right")
	):
		move(Vector2.LEFT)
	elif (
		state != "dash" and 
		Input.is_action_pressed("ui_right")
		and not Input.is_action_pressed("ui_left")
	):
		move(Vector2.RIGHT)
	elif (
		anim_current in [
			"attack_power-a", "attack_power-b", "attack_power-c", "attack_power-d", 
			"attack_power-m"
		]
		and is_on_floor() == true
	):
		pass
	
	
	
	

		
	
	elif state != "dash":
		stop_move()
	
	
	if (
		InputBuffer.is_action_press_buffered("backdash")
		and Input.is_action_just_pressed("attack") == false
		and state != "crouch" and state != "dash"
		and _player_can_stand()
		and Input.is_action_pressed("quickmenu") == false
		and anim_current != "pos-backdash"
	):

		
		
		if (
			is_on_floor() == true and 
			_is_forward_dir_pressed() and 
			ElementalCircuits.was_obtained(
				GVar.EC_MODE.ABILITY, 
				GVar.EC_ABILITY.DODGE
			)
		):
			dodge()
		
		elif (
			is_on_floor() == false
			and ElementalCircuits.was_obtained(
				GVar.EC_MODE.ABILITY, 
				GVar.EC_ABILITY.AERIAL_DASH
			) == true
		):
			dash()
		elif is_on_floor() == true:
			backdash()

	
	
	if Input.is_action_just_pressed("attack"):

		if (
			(Input.is_action_pressed("ui_down") or _player_can_stand() == false)
			and is_on_floor() and state != "attack"
		):
			whip_attack("attack_power-crouch")
		
		else:
			whip_attack("attack_power-a")

	
	
	if state in ["attack", "attack-crouch", "circuit", "circuit-charge"]:
		return

	
	if (
		is_on_floor() == false
		and Input.is_action_pressed("ui_down")
		and InputBuffer.is_action_press_buffered("jump")
		and _num_jumps > 1
		and ElementalCircuits.was_obtained(
			GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.AIR_KICK
		)
	):
		air_kick()

	
	if (
		
		Input.is_action_just_pressed("jump") and 
		state != "slide" and 
		state != "crouch" and 
		state != "air-kick" and 
		_num_jumps < _max_jumps
		and _player_can_stand()
	):
		
		if (
			is_on_floor() and Input.is_action_pressed("ui_down")
		):
			pass
		else:
			
			if physics_param == "water":
				_num_jumps = 0
				change_state("fall", true, false)
				jump(1.0, true, false)
			
			elif (
				_num_jumps == 0 or 
				ElementalCircuits.was_obtained(
					GVar.EC_MODE.ABILITY, 
					GVar.EC_ABILITY.DOUBLE_JUMP
				)
			):
				jump()

	
	else:
		
		_snap_vector = _snap_direction * SNAP_LENGTH

	
	if (
		state != "crouch"
		and state != "attack" and state != "attack-crouch"
		and Input.is_action_pressed("ui_down")
		and is_on_floor()
		and VarsGlobal.GameInterface.changing_subweapon == false
	):
		crouch()
		velocity.x = 0
	
	if (
		Input.is_action_just_released("ui_down") and state == "crouch"
		and _player_can_stand() == true
	):
		change_state("idle")

	
	if anim_current == "backdash":
		return
	
	
	if (
		Input.is_action_just_pressed("circuit")
		
		and state != "circuit"
		and state != "circuit-charge"
		and state != "slide"
		and state != "attack"
		and TimerECACtionCooldown.is_stopped()
		and Input.is_action_pressed("quickmenu") == false
	):
		
		

		
		_circuit_oneshot_to_use = GVar.EC_ACTION.NONE
		
		var current_circuit: int = VarsGlobal.game_data["player_ec_action_selected"][VarsGlobal.game_data["player_current_set"]]

		
		if ElementalCircuits.action_circuit_requeriment_is_ok(
				VarsGlobal.game_data["player_ec_action_selected"][VarsGlobal.game_data["player_current_set"]]
		) == false or current_circuit == - 1:
			Audio.play_sfx("ui_not_enough_mana")
			return
		
		
		var activation_time: int = ElementalCircuits.get_circuit_action_time(
			current_circuit
		)
		
		
		if activation_time > 0 and (state == "crouch" or is_on_floor() == false):
			return
		
		TimerECACtionCooldown.start()

		if activation_time > 0:
			_start_circuit_action_charge()
		elif activation_time == 0:
			_circuit_oneshot_to_use = current_circuit
			change_state("throw", false, false)
		elif activation_time < 0:
			_enable_circuit_effect()
	
	
	if Input.is_action_just_released("circuit"):
		var current_circuit: int = VarsGlobal.game_data["player_ec_action_selected"][VarsGlobal.game_data["player_current_set"]]
		if current_circuit == - 1:
			return
		
		var activation_time: int = ElementalCircuits.get_circuit_action_time(
			current_circuit
		)
		
		if current_circuit >= 0 and activation_time < 0:
			_enable_circuit_effect(false)
	
	
	if (
		state == "crouch" and Input.is_action_just_pressed("jump")
		and Input.is_action_pressed("ui_down")
	):
		
		if _is_player_on_oneway_floor():
			drop_from_floor()
		
		elif ElementalCircuits.was_obtained(
			GVar.EC_MODE.ABILITY, 
			GVar.EC_ABILITY.SLIDE
		):
			slide()

func _jump_physics() -> void :
	
	
	if velocity.y > 0:
		velocity += (
			Vector2.UP * ( - 0.5) * (fall_multiplier)
		) * (_floor_normal.y * - 1)
	
	
	
	
	if (
		enabled_input == true and 
		state != "air-kick" and 
		Input.is_action_just_released("jump")
		and velocity.y < 0
	):
		velocity.y = lerp(velocity.y, 0, 0.6)

func _fix_state() -> void :
	
	
	if (
		_pasive_circuit_enabled == true
		and Input.is_action_pressed("circuit") == false
	):
		_enable_circuit_effect(false)
	
	if state in [
		"dead", "sit", 
		"mark", 
		"suffocation", "endgame-floor", "depress", 
		"changedir", "hurt", "swing", "circuit", "circuit-charge"
	]:
		return
		
	
	if state in ["attack", "attack-crouch"]:
		if velocity.x != 0 and is_on_floor():
			velocity.x = 0
		return
	
	
	if BodyNode.scale.x != facing and anim_current != "changedir":
		BodyNode.scale.x = facing
	
	
	if _player_can_stand() == false:
		return

	if state == "wallslide" and _is_player_pushing_solid() == false:
		change_state("idle", true, false)
		
	
	if state == "idle" and is_on_floor() and anim_current == "backdash" and velocity.x == 0:
		change_state("idle", true)
		
	
	if state == "idle" and anim_current == "run":
		change_state("idle", true, false)

	
	
	if state in ["crouch", "slide", "dash"]:
		if is_on_floor() == false:
			_return_to_fall_from_dash_state()
		return
	
	
	if state == "air-kick" and is_on_floor() and abs(_last_velocity_y) > 700:
		velocity.x = 0
		auto_crouch()
		return

	
	
	
	if is_on_floor() and state != "idle" and velocity.x == 0:
		change_state("idle")
	
	
	
	if (
		not is_on_floor() and velocity.y * (_floor_normal.y * - 1) > 0
		and state != "fall" and state != "air-kick" and state != "wallslide"
	):
		velocity.y = 0
		change_state("fall")
	
	
	if is_on_floor() and direction.x != 0 and abs(velocity.x) != 0 and state != "run":
		change_state("run")

func _attempt_correction(amount: float, delta: float) -> void :
	if velocity.y < 0 and test_move(global_transform, 
	Vector2(0, velocity.y * delta)):
		for i in range(1, amount * 2 + 1):
			for j in [ - 1.0, 1.0]:
				if not test_move(global_transform.translated(Vector2(i * j / 2, 0)), 
				Vector2(0, velocity.y * delta)):
					translate(Vector2(i * j / 2, 0))
					if velocity.x * j < 0: velocity.x = 0
					return

func _change_collision(col_type: String):
	
	if col_type != "stand" and BodyNode.scale.y == - 1:
		col_type = col_type + "-inventory_manager"
	
	AnimCollisions.play(col_type)

func _change_sprite_facing(dir_x: int = 1) -> void :
	
	
	if state in ["attack", "attack-crouch"] or anim_current in ["slide", "throw", "throw-air"]:
		return
	
	
	if anim_current in ["jump-diag", "jump-up"]:
		anim_state_machine.travel("fall")
	
	
	
	
	if is_on_floor() and state != "crouch":
		change_state("changedir", true, false)
	else:
		_set_body_scale_x(dir_x)
	
	facing = dir_x
	VarsGlobal.game_data["player_facing"] = facing
	
	_enable_circuit_effect(false)

func _set_body_scale_x(dir_x: int = 0) -> void :
	if dir_x == 0:
		BodyNode.scale.x = facing
	else:
		
		BodyNode.scale.x = dir_x

func _player_touched_floor():
	if _character_ready and is_on_floor() and not _was_on_floor:

		_aeria_gravity = 0.2
	
		if TimerReady2.is_stopped() == true:
			Audio.play_sfx("floor_foot")
		
		
		match _knockback_intensity:
			0:
				auto_crouch(1.1)
			3:
				auto_crouch(0.6)
			2:
				auto_crouch(0.4)
			_:
				TimerAfterDamage.stop()
		
		
		if _knockback_intensity in [0, 1, 2, 3]:
			velocity = Vector2.ZERO
		
		_knockback_intensity = - 1
		
		
		_last_dirx_on_wallslide = 0

		
		
		
		
		
		
		if anim_current in [
			"attack_power-spin-air", "attack_power-a"
		]:
			change_state("idle", true, false)

		
		elif anim_current in ["attack_power-air"]:
			anim_state_machine.travel("attack_power-a")
			
		
		
		elif anim_current in ["throw-air"]:
			anim_state_machine.travel("throw")

		_num_jumps = 0
		_jump_pressed_on_floor = false
		
		
		if abs(_last_velocity_y) > 550:
			stop_move()
			auto_crouch(0.6)
		
		
		if abs(_last_velocity_y) > 250:
			var landing_dust = DustLandingFloor.instance()
			landing_dust.scale.y = BodyNode.scale.y
			landing_dust.global_position = BottomSpriteBodyPosition.global_position
			if abs(_last_velocity_y) > 550:
				landing_dust.anim_name = "show_1"
			else:
				landing_dust.anim_name = "show_0"
			VarsGlobal.GameScenario.add_child(landing_dust)
		
		
		if state == "hurt":
			
			change_state("idle")

func _return_to_fall_from_dash_state() -> void :
	
	
	if state == "dash" and DashTime.is_stopped() == false:
		return
	
	
	AnimResetCols.play("reset")
	
	anim_state_machine.start("pre-fall")
	state = "fall"
	_change_collision("stand")
	DashTime.stop()

func _is_forward_dir_pressed() -> bool:
	var forward_pressed: = false
	if (
		Input.is_action_pressed("ui_left") and facing == - 1
		or Input.is_action_pressed("ui_right") and facing == 1
	):
		forward_pressed = true
	return forward_pressed

func _shake_camera(
	amount: float = 1.0, add_trauma: bool = false, 
	ignore_shake_conf: bool = true
) -> void :
	VarsGlobal.GameScenario.CameraNode.start_shake(
		amount, add_trauma, ignore_shake_conf
	)

func _shake_on_atk_h() -> void :
	_shake_camera(0.7, true, true)
	Gamepad.start_vibration(0, 0.9, 1.0, 0.8)
	Audio.play_sfx("explosion_light")
	VarsGlobal.GameScenario.show_hit_lines(
		"hit_mid", 1, Particles2DWhipBlood.global_position
	)

func _shake_on_atk_m_melee() -> void :
	_shake_camera(0.3, true, true)
	Gamepad.start_vibration(0, 0.8, 0.5, 0.3)
	Audio.play_sfx("explosion_light")

func _atk_charge_rumble() -> void :
	Gamepad.start_vibration(0, 0.7, 0.7, 0.1)
	if Audio.sfx_is_playing("ec_blood_whip") == false:
		Audio.play_sfx("ec_blood_whip")

func _on_changedir_anim_finished() -> void :
	if state == "changedir" and direction.x == 0:
		change_state("idle")
	else:
		state = "idle"

func _on_attack_anim_finished(next_anim: String = "") -> void :
	
	
	if (
		_melee_whip == true and next_anim != ""
		and state != "dash" and state != "hurt"
	):

		_melee_whip = false
		state = "idle"
		change_state(next_anim, false, false)
		return
	
	if is_on_floor():
		if (
			(Input.is_action_pressed("ui_down") or _player_can_stand() == false)
			and anim_current in ["attack_power-crouch", "pos-crouch"]
		):
			state = "crouch"
		else:
			change_state("idle")
	else:
		change_state("fall")

func _on_DashTime_timeout() -> void :

	if state in ["attack", "attack-crouch", "jump"]:
		return
	
	
	if (
		(Input.is_action_pressed("ui_down") or _player_can_stand() == false)
		and is_on_floor()
	):
		velocity.x = 0
	
	if (
		state == "slide"
		and (Input.is_action_pressed("ui_down") or _player_can_stand() == false)
	):
		
		state = "crouch"
	
	elif state == "dash" and is_on_floor() == false:
		_return_to_fall_from_dash_state()
	
	elif _player_can_stand() == true:
		change_state("idle")

func _on_HBAirKick_area_entered(_area: Area2D) -> void :
	
	
	velocity.x = 0
	jump()
	anim_state_machine.start("jump-up")
	_num_jumps = _max_jumps - 1

func _on_Area2DFloorExit_body_exited(_body: Node) -> void :
	emit_signal("floor_exited")

func _on_TimerAfterHurtCrouch_timeout() -> void :
	state = "crouch"
	enabled_input = true
	_knockback_intensity = - 1

func _on_Area2DBackWall_body_entered(_body: Node) -> void :
	if state == "hurt" and _knockback_intensity == 0:
		Audio.play_sfx("impact_body_wall")
		VarsGlobal.GameScenario.show_hit(
			"hit2", 1, BodyNode.global_position
		)
		_shake_camera(0.8, true, false)
		Gamepad.start_vibration(0, 1.0, 1.0, 0.5)

func _on_TimeInvencibility_timeout() -> void :
	if BodySprite.modulate.a != 1.0:
		BodySprite.modulate.a = 1.0
	HurtBox.set_deferred("monitoring", true)

func _on_TimerActionCircuit_timeout() -> void :
	Audio.stop_sfx("ec_charging")
	Audio.play_sfx("ec_shoot")
	TimerECACtionCooldown.start()
	if state != "crouch":
		change_state("idle", true)
	ElementalCircuitAction.AnimPlayer.play("absorbed")
	
	ElementalCircuits.spawn_action_circuit(
		VarsGlobal.game_data["player_ec_action_selected"][VarsGlobal.game_data["player_current_set"]], 
		Position2DCircuit.global_position
	)

func _on_ElementalCircuitAction_absorbed_anim_end() -> void :
	_stop_circuit_action_charge()

func _on_TimerRecoverFromHurtOnWater_timeout() -> void :
	
	if state == "hurt":
		
		change_state("idle")

func _on_Whip_texture_changed() -> void :
	_update_whip_texture()

func _on_TimerIdle_timeout() -> void :
	if state == "idle":
		anim_state_machine.start("idle")

func _on_TimerCheckAkCharge_timeout() -> void :
	
	if anim_current != "attack_power-charge":
		return

	AnimAtkCharge.play("blood_charged")
	
	ParticlesCharge.emitting = true
	
	if VarsGlobal.game_data["player_bl_now"] >= 50:
		Audio.play_sfx("atk_blood_completed")
		_charge_status = "charged-blood"
		VarsGlobal.game_data["player_bl_now"] = int(
			FuncsNumbers.decrease_value(
			50, VarsGlobal.game_data["player_bl_now"]
		)
		)
		emit_signal("stats_changed")
		BodySprite.modulate = Color.pink
		ParticlesCharge.modulate = Color.red
		ParticlesCharge.speed_scale = 3

		
	else:
		Audio.play_sfx("atk_charge_completed")
		_charge_status = "charged"

func _on_Sprite_frame_changed() -> void :
	BodySpriteOutline.frame = BodySprite.frame
