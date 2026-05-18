extends KinematicBody2D

signal damaged
signal stats_changed

signal floor_exited
signal dead

var ShineParticle = preload("res://src/game_objects/vfx/shine_particle.tscn")

const SLOPE_THRESHOLD: = deg2rad(46)

const SNAP_LENGTH: = 8

var state: String = "idle"

var prev_state: String = "idle"

var velocity: = Vector2(0, 0)

var direction: = Vector2(0, 0)

var facing: = 1

const acceleration: float = 1.0
const friction: float = 1.0

var speed_max = 90

var stop_on_slope: = false

var fall_multiplier: = 15.0

var jump_velocity: = 190

var gravity: = 350

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

var physics_param: String = "normal"

var is_freezed: bool

onready var BodyNode = $Sprite
onready var HurtBox = $HurtBoxPlayer
onready var TimerReady = $Timers / TimerReady
onready var TimerReady2 = $Timers / TimerReady2
onready var AutoCrouchTime = $Timers / AutoCrouch
onready var CoyoteTime = $Timers / CoyoteTime
onready var DashTime = $Timers / DashTime
onready var ForwardPressedTime = $Timers / ForwardPressedTime
onready var TimerAfterHurtCrouch = $Timers / TimerAfterHurtCrouch
onready var TimerRecoverFromHurtOnWater = $Timers / TimerRecoverFromHurtOnWater
onready var TimerAfterDamage = $Timers / TimerAfterDamage
onready var TimeInvencibility = $Timers / TimeInvencibility

onready var AnimCollisions = $AnimCollision

onready var AnimPlayer = $AnimationPlayer
onready var AnimTree = $AnimationTree

onready var GhostTrail = $Sprite / GhostTrail

onready var RayCastCrouchRoof = $Sprite / RayCastCrouchRoof

onready var RayCastOnewayFloor = $Sprite / RayCastOnewayFloor
onready var RayCastOnewayFloor2 = $Sprite / RayCastOnewayFloor2

onready var Position2DFoot = $Sprite / Position2DFoot

onready var Particles2DBubbles = $Sprite / AreaDetectWater2 / Particles2DBubbles

onready var Particles2DBloodHurt = $Sprite / Particles2DBloodHurt

func _ready() -> void :
	VarsGlobal.Player = self
	
	
	
	
	GhostTrail.enabled = Config.get_value("gameplay", "player_afterimage", true)
	
	
	anim_state_machine = $AnimationTree.get("parameters/playback")
	
	
	facing = VarsGlobal.game_data["player_facing"]
	_set_body_scale_x(facing)
	
	
	TimerReady.start()
	yield(TimerReady, "timeout")
	_character_ready = true

func _physics_process(delta: float) -> void :
	
	if is_freezed == true:
		return
	
	
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
		_character_ready == true
		and CoyoteTime.is_stopped()
	):
		
		velocity.y -= (gravity * _floor_normal.y) * delta
		
		if state == "dodge":
			velocity.y = velocity.y / 2
	
	
	velocity = move_and_slide_with_snap(
		velocity, _snap_vector, _floor_normal, 
		stop_on_slope, 4, SLOPE_THRESHOLD
	)

	
	
	
	if (
		not is_on_floor() and _was_on_floor and state in ["run"]
	):
		CoyoteTime.start()
		velocity.y = 0
	
	
	_fix_state()

	
	_player_touched_floor()

	
	
	if velocity.y > 600 and is_on_floor() == false:
		velocity.y = 600

func change_state(
	new_state: String, force_change: bool = false, travel_anim: bool = true
) -> void :
	
	
	if state == "dead" and new_state != "dead":
		return

	var animation_name = new_state
	
	if new_state != state or force_change == true:

		
		

		
		Particles2DBloodHurt.emitting = false
		
		
		prev_state = state
		state = new_state
		
		match state:

			
			"jump":
				
				if (
					_num_jumps > 1 and _jump_pressed_on_floor
				):
					animation_name = "jump2"

				
				
				elif direction.x != 0 and abs(velocity.x) > 20.0:
					animation_name = "jump_diag"
				
				else:
					animation_name = "jump_up"
			
			"dodge":
				state = "dash"
			
			"hurt":
				if _player_can_stand() == false:
					animation_name = "crouch"
		
		if travel_anim:
			anim_state_machine.travel(animation_name)
		else:
			anim_state_machine.start(animation_name)
		
		
		match state:
			"crouch", "attack-crouch", "slide":
				AnimCollisions.play("crouch")
			"idle", "fall":
				AnimCollisions.play("stand")

		
		if state in ["slide"] and get_floor_velocity() == Vector2.ZERO:
			GhostTrail.start_trail(0.5, 0.08)
		elif state in ["dash"]:
			if animation_name == "dodge":
				GhostTrail.start_trail(0.5, 0.1)
			else:
				GhostTrail.start_trail()
		else:
			GhostTrail.stop_trail()
	

func change_physics_params(param: String = "normal") -> void :

	physics_param = param
	match param:
		"water":
	
			
			velocity.y = 0
			
			speed_max = 60
			
			fall_multiplier = 2.5
			jump_velocity = 225
			gravity = 200
			Particles2DBubbles.emitting = true
		
		
		_:
			speed_max = 90
			
			fall_multiplier = 15
			jump_velocity = 190
			gravity = 350
			Particles2DBubbles.emitting = false

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

func _jump_physics() -> void :
	
	
	if velocity.y > 0:
		velocity += (
			Vector2.UP * ( - 0.5) * (fall_multiplier)
		) * (_floor_normal.y * - 1)
	
	
	
	
	if (
		enabled_input == true and 
		Input.is_action_just_released("jump")
		and velocity.y < 0
	):
		velocity.y = lerp(velocity.y, 0, 0.6)

func set_enabled_input(enable: bool = true) -> void :
	enabled_input = enable
	VarsGlobal.GameInterface.set_visible_vgamepad(enable)

func _get_input() -> void :

	if (
		enabled_input == false
		or state in ["slide", "dash"]
		or anim_current in ["dodge"]
		or TimerAfterDamage.is_stopped() == false
		or TimerRecoverFromHurtOnWater.is_stopped() == false
		or DebugMenu.using_console == true
		and AutoCrouchTime.is_stopped() == true
	):
		return
	
	
	
	
	
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
	elif state != "dash":
		stop_move()

	
	if (
		InputBuffer.is_action_press_buffered("backdash")
		and state != "crouch" and state != "dash"
		and _player_can_stand()
		and Input.is_action_pressed("jump") == false
	):

		
		
		if (
			
			_is_forward_dir_pressed() and 
			ElementalCircuits.was_obtained(
				GVar.EC_MODE.ABILITY, 
				GVar.EC_ABILITY.DODGE
			)
		):
			dodge()

	
	
	if (
		InputBuffer.is_action_press_buffered("jump") and 
		state != "slide" and 
		state != "crouch" and 
		_num_jumps < _max_jumps
		and _player_can_stand()
	):
		
		if is_on_floor() and Input.is_action_pressed("ui_down"):
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
		and state != "dash"
		and state != "slide"
		and anim_current != "dodge"
		and Input.is_action_pressed("ui_down")
		and is_on_floor()
	):
		crouch()
		velocity.x = 0
	
	if (
		Input.is_action_just_released("ui_down") and state == "crouch"
		and _player_can_stand() == true
	):
		change_state("idle")
	
	
	if (
		state == "crouch" and Input.is_action_just_pressed("jump")
		and Input.is_action_pressed("ui_down") == true
	):

		if _is_player_on_oneway_floor():
			drop_from_floor()

		elif ElementalCircuits.was_obtained(
			GVar.EC_MODE.ABILITY, 
			GVar.EC_ABILITY.SLIDE
		):
			slide()

func crouch() -> void :
	change_state("crouch", false, false)
	stop_move()

func auto_crouch(secs: float = 0.5):
	
	Gamepad.start_vibration(0, 0.2, 0.5, 0.3)

	AutoCrouchTime.wait_time = secs
	AutoCrouchTime.start()
	change_state("crouch", false, false)
	yield(AutoCrouchTime, "timeout")
	TimerAfterDamage.stop()

	if (
		Input.is_action_pressed("ui_down") == false and is_on_floor() == true
		and _player_can_stand() == true
	):
		change_state("idle")

func move(dir: Vector2 = Vector2.ZERO) -> void :
	
	
	if dir.x != 0:
		
		
		if state != "crouch":
			
			if is_on_floor():
				velocity.x = lerp(
					velocity.x, dir.x * speed_max, acceleration
				)
				
			
			else:
				velocity.x = lerp(
					velocity.x, dir.x * speed_max, 0.1
				)
		
		
		if (
			facing != dir.x
			and anim_state_machine.get_current_node() != "changedir"
		):
			_change_sprite_facing(int(dir.x))

		direction = dir

func stop_move() -> void :
	velocity.x = lerp(velocity.x, 0, friction)
	direction.x = 0

func dodge() -> void :
	if VarsGlobal.game_data["player_sp_now"] < 30:
		return

	if state.ends_with("crouch"):
		return

	velocity.x = 0
	VarsGlobal.game_data["player_sp_now"] = int(FuncsNumbers.decrease_value(
		30, VarsGlobal.game_data["player_sp_now"]
	))
	emit_signal("stats_changed")
	VarsGlobal.GameInterface.update_stamina_stats()
	
	BodyNode.modulate.a = 1
	
	change_state("dodge", false, false)
	
	Audio.play_sfx("woosh_whip_m")
	Audio.play_voice("smol_xandria_dodge")
	
	velocity.x = (speed_max * 1.7) * facing
	invencibility(0.4, false)
	DashTime.start(0.4)

	VarsGlobal.GameScenario.cancel_quick_menu_use()

func slide() -> void :
	if VarsGlobal.game_data["player_sp_now"] < 15:
		return
	VarsGlobal.game_data["player_sp_now"] = int(FuncsNumbers.decrease_value(
		15, VarsGlobal.game_data["player_sp_now"]
	))
	emit_signal("stats_changed")
	VarsGlobal.GameInterface.update_stamina_stats()
	change_state("slide", false, false)
	velocity.x = (speed_max * 1.8) * facing
	DashTime.start(0.3)
	Gamepad.start_vibration(0, 0.2, 0.1, 0.3)
	Audio.play_sfx("floor_slide2")
	Audio.play_voice("smol_xandria_slide")
	VarsGlobal.GameScenario.cancel_quick_menu_use()

func drop_from_floor() -> void :
	if _floor_normal.y == - 1:
		position.y = position.y + 11
	else:
		position.y = position.y - 11

func hurt(knockback_intensity: int, damage_area: Object) -> void :
	emit_signal("damaged")
	emit_signal("stats_changed")

	velocity.x = 0
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
	else:
		TimerAfterDamage.start()

func knockback(intensity: int = 1, dir: int = 1) -> void :

	if intensity == 0:
		Audio.play_sfx("impact_player_hurt2")
		Audio.play_voice("smol_xandria_death")
	else:
		Audio.play_sfx("impact_player_hurt")
		Audio.play_voice("smol_xandria_hurt")
	
	
	DashTime.stop()
	velocity = Vector2.ZERO
	
	if is_freezed == false:
		
		facing = dir * - 1
		VarsGlobal.game_data["player_facing"] = facing
		_set_body_scale_x(dir * - 1)
	
	
	if _player_can_stand() == false:
		
		
		TimerAfterHurtCrouch.start()
		return
	
	_knockback_intensity = intensity

	
	
	if Input.is_action_pressed("ui_down"):
		Input.action_release("ui_down")

	change_state("hurt", true, false)

	
	_snap_vector = Vector2.ZERO
	
	
	
	match intensity:
		0:
			
			Gamepad.start_vibration(0, 1.0, 1.0, 0.8)
			GhostTrail.start_trail()
		1:
			
			Gamepad.start_vibration(0, 0.3, 0.0, 0.3)
		2:
			
			Gamepad.start_vibration(0, 0.4, 0.1, 0.3)
		3:
			
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

func endgame() -> void :
	
	
	if state == "dead":
		return
	
	emit_signal("dead")
	change_state("dead", true, false)
	
	Audio.play_sfx("impact_player_hurt")
	Audio.play_voice("smol_xandria_death")
	
	BodyNode.modulate.a = 1.0
	
	set_process(false)
	set_physics_process(false)
	
	
	
				
	
	Particles2DBloodHurt.emitting = true
	Particles2DBloodHurt.lifetime = 10
	Particles2DBloodHurt.lifetime_randomness = 1
	
	
	var TwDeath = get_tree().create_tween()
	TwDeath.tween_property(self, "position", position + Vector2(0, - 100), 10)
	
	
	modulate = Color("ff0000")

func invencibility(time_inv: float = 2.0, modulate_sprite: bool = true) -> void :
	if modulate_sprite:
		BodyNode.modulate.a = 0.5
	HurtBox.set_deferred("monitoring", false)
	TimeInvencibility.start(time_inv)

func _change_sprite_facing(dir_x: int = 1) -> void :
	
	
	if anim_current in ["slide"]:
		return
	
	
	if anim_current in ["jump_diag", "jump_up"]:
		anim_state_machine.travel("fall")
	
	_set_body_scale_x(dir_x)
	
	facing = dir_x
	VarsGlobal.game_data["player_facing"] = facing

func _set_body_scale_x(dir_x: int = 0) -> void :
	if dir_x == 0:
		BodyNode.scale.x = facing
	else:
		
		BodyNode.scale.x = dir_x

func jump(weakness: float = 1.0, change_st: bool = true, add_jump_count: bool = true) -> void :
	
	
	if is_on_floor() or CoyoteTime.is_stopped() == false:
		_jump_pressed_on_floor = true
	
	
	velocity.y = 0
	
	
	_snap_vector = Vector2.ZERO

	if change_st:
		change_state("jump", false, false)

	
	velocity.y += (jump_velocity / weakness) * _floor_normal.y
	
	if add_jump_count and is_on_floor() or CoyoteTime.is_stopped() == false:
		_num_jumps += 1
	
	
	
	elif add_jump_count:
		_num_jumps = _max_jumps
	
	
	if _num_jumps > 1 and change_st:
		change_state("jump", true, false)
	
	
	Audio.play_voice("smol_xandria_jump")
	Audio.play_sfx("woosh_jump3")
	if _num_jumps > 1:
		
		Audio.play_sfx("shine_jump")
		Audio.play_sfx("shine_jump2")
		
		var ObjInstance = ShineParticle.instance()
		ObjInstance.global_position = Position2DFoot.global_position
		VarsGlobal.GameScenario.add_child(ObjInstance)
	
	CoyoteTime.stop()

func _player_touched_floor():
	if _character_ready and is_on_floor() and not _was_on_floor:
		
		if TimerReady2.is_stopped() == true:
			Audio.play_sfx("floor_foot_sand")
		
		
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

		_num_jumps = 0
		_jump_pressed_on_floor = false
		
		
		if abs(_last_velocity_y) > 350:
			stop_move()
			auto_crouch(0.6)
		

		
		
		if state == "hurt":
			change_state("idle")

func _player_can_stand() -> bool:
	return not RayCastCrouchRoof.is_colliding()

func _fix_state() -> void :
	
	if state in [
		"dodge", 
		"dead", 
		"endgame-floor", 
		"hurt"
	]:
		return
	
	
	if _player_can_stand() == false:
		return
		
	
	if state == "idle" and anim_current == "run":
		change_state("idle", true, false)

	
	
	if state in ["crouch", "slide", "dash"]:
		if is_on_floor() == false:
			_return_to_fall_from_dash_state()
		return

	
	
	if is_on_floor() and state != "idle" and velocity.x == 0:
		change_state("idle")
	
	
	
	if (
		not is_on_floor() and velocity.y * (_floor_normal.y * - 1) > 0
		and state != "fall"
	):
		change_state("fall")
	
	
	if is_on_floor() and direction.x != 0 and abs(velocity.x) != 0 and state != "run":
		change_state("run")

func _return_to_fall_from_dash_state() -> void :
	
	
	if state == "dash" and DashTime.is_stopped() == false:
		return
	
	
	
	
	anim_state_machine.start("pre_fall")
	state = "fall"
	AnimCollisions.play("stand")
	DashTime.stop()

func _on_DashTime_timeout() -> void :

	if state in ["jump"]:
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
	
	elif _player_can_stand():
		change_state("idle")

func _on_TimeInvencibility_timeout() -> void :
	if BodyNode.modulate.a != 1.0:
		BodyNode.modulate.a = 1.0
	HurtBox.set_deferred("monitoring", true)

func _is_player_on_oneway_floor() -> bool:
	if RayCastOnewayFloor.is_colliding() or RayCastOnewayFloor2.is_colliding():
		return true
	return false

func _is_forward_dir_pressed() -> bool:
	var forward_pressed: = false
	if (
		Input.is_action_pressed("ui_left") and facing == - 1
		or Input.is_action_pressed("ui_right") and facing == 1
	):
		forward_pressed = true
	return forward_pressed

func _on_TimerRecoverFromHurtOnWater_timeout() -> void :
	
	if state == "hurt":
		change_state("idle")

func _on_TimerAfterHurtCrouch_timeout() -> void :
	state = "crouch"
	enabled_input = true
	_knockback_intensity = - 1
