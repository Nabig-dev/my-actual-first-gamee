extends Node2D

var _active: bool = false

onready var AnchorActive = $AnchorActive
onready var Chain = $Line2D
onready var StartPendulum = $StartPendulum
onready var EndPendulum = $EndPendulum

onready var AnimPlayer = $AnimationPlayer
onready var TimerJumpCoolDown = $TimerJumpCoolDown
var dir: int = 0

var _reached_limit: bool = false

var _group_name: String

var _update_player_pos_on_process: bool

func _ready() -> void :
	
	_group_name = "swing_chain_" + str(get_instance_id())
	$AreaPendulumDisable.add_to_group(_group_name)
	$EndPendulum / AreaPendulum.add_to_group(_group_name)

	stop_swing(true)
	AnimPlayer.play("inactive")

func _process(_delta: float) -> void :
	
	if _active == false:
		return
	
	
	
	if StartPendulum.angular_velocity > 0.04:
		if VarsGlobal.Player.facing == 1:
			VarsGlobal.Player.anim_state_machine.travel("swing-front")
		else:
			VarsGlobal.Player.anim_state_machine.travel("swing-back")
	elif StartPendulum.angular_velocity < - 0.04:
		if VarsGlobal.Player.facing == 1:
			VarsGlobal.Player.anim_state_machine.travel("swing-back")
		else:
			VarsGlobal.Player.anim_state_machine.travel("swing-front")
	else:
		VarsGlobal.Player.anim_state_machine.travel("swing")
	
	
	Chain.points[1] = EndPendulum.position
	
	
	if Input.is_action_pressed("attack") == false:
		stop_swing()
	
	if _update_player_pos_on_process == true:
		_update_player_position()
	
	
	if Input.is_action_pressed("ui_up") and _reached_limit == false:
		if Audio.sfx_is_playing("whip_chain_l") == false:
			Audio.play_sfx("whip_chain_l")
		StartPendulum.modify_length( - 1)
	elif Input.is_action_pressed("ui_down") and _reached_limit == false:
		if Audio.sfx_is_playing("whip_chain_l") == false:
			Audio.play_sfx("whip_chain_l")
		StartPendulum.modify_length(1)
	
	if _reached_limit == true:
		return

	
	if Input.is_action_just_pressed("ui_left"):
		StartPendulum.kick( - 1)
	elif Input.is_action_just_pressed("ui_right"):
		StartPendulum.kick(1)

func start_swing() -> void :
	
	
	
	
	EndPendulum.global_position = VarsGlobal.Player.global_position
	
	VarsGlobal.Player.anim_state_machine.start("swing")
	
	StartPendulum.set_active_pendulum(true)
	yield(get_tree(), "idle_frame")
	StartPendulum.set_physics_process(false)
	
	_active = true
	
	if is_instance_valid(VarsGlobal.Player):
		
		VarsGlobal.Player.change_state("swing", true, false)
		VarsGlobal.Player.set_enabled_input(false)
		VarsGlobal.Player.gravity_enabled = false
		VarsGlobal.Player.velocity = Vector2.ZERO
		yield(get_tree(), "idle_frame")
		$Tween.interpolate_property(
			VarsGlobal.Player, "global_position", 
			VarsGlobal.Player.global_position, 
			EndPendulum.global_position - Vector2(0, - 47.5), 0.1
		)
		$Tween.start()
	

func stop_swing(force: bool = false) -> void :
	
	if _active == false and force == false:
		return
	
	_active = false
	_update_player_pos_on_process = false
	AnchorActive.visible = false
	
	StartPendulum.set_active_pendulum(false)
	Chain.visible = false
	
	if is_instance_valid(VarsGlobal.Player):
		
		VarsGlobal.Player.set_enabled_input(true)
		VarsGlobal.Player.gravity_enabled = true
		_update_player_position()
		if TimerJumpCoolDown.is_stopped() == true:
			TimerJumpCoolDown.start(0.8)
			VarsGlobal.Player.velocity = Vector2(0, - 275)
			VarsGlobal.Player.reset_num_jumps()
		else:
			VarsGlobal.Player.velocity = Vector2(0, - 10)

		Audio.play_voice("xandria_move")
		
		VarsGlobal.Player.change_state("jump", true, false)
		
		$Tween.stop_all()
		
		VarsGlobal.Player.velocity.x += StartPendulum.angular_velocity

	
	

func _update_player_position() -> void :
	
	VarsGlobal.Player.global_position = (
		EndPendulum.global_position - Vector2(0, - 47.5)
	)

func _on_AreaDetectChain_area_entered(area: Area2D) -> void :

	VarsGlobal.GameScenario.show_hit_lines(
		"hit_low", 1, global_position
	)
	if (
		area.identifier.begins_with("whip") and _active == false
		and ElementalCircuits.was_obtained(
			GVar.EC_MODE.ABILITY, 
			GVar.EC_ABILITY.SWING
		)
	):
		start_swing()
	else:
		Audio.play_sfx("ui_incorrect")

func _on_AreaPendulumDisable_area_entered(area: Area2D) -> void :
	if area.get_groups().has(_group_name) == false:
		return
	_reached_limit = true
	StartPendulum.angular_acceleration = StartPendulum.angular_acceleration / 2
	StartPendulum.angular_velocity = StartPendulum.angular_velocity / 2

func _on_AreaPendulumDisable_area_exited(area: Area2D) -> void :
	if area.get_groups().has(_group_name) == false:
		return
	_reached_limit = false

func _on_Tween_tween_completed(_object: Object, _key: NodePath) -> void :
	if _active == true:
		_update_player_pos_on_process = true
		StartPendulum.set_physics_process(true)
		Chain.visible = true

func _on_TimerConnectSignals_timeout() -> void :
	
	if is_instance_valid(VarsGlobal.Player) and VarsGlobal.Player.has_signal("damaged"):
		VarsGlobal.Player.connect("damaged", self, "stop_swing")
