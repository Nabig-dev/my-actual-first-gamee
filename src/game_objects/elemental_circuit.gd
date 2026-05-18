tool 

extends Node2D

signal absorbed
signal absorbed_anim_end

export (GVar.EC_MODE) var circuit_mode = GVar.EC_MODE.ACTION setget _update_mode
export (GVar.EC_ACTION) var action = GVar.EC_ACTION.NONE setget _update_action_icon
export (GVar.EC_ABILITY) var ability = GVar.EC_ABILITY.NONE setget _update_ability_icon

var subweapon = GVar.EC_SUBWEAPON.NONE setget _update_subweapon_icon

export var custom_color: = Color("ffffff") setget _update_color

export var is_for_ui: bool

export var delete_if_absorbed_anim_ends: bool = true

export var speed_anim: float = 0.5

var entered_player: bool

var start_anim: String = "idle"

var _absorbing: bool

onready var AnimPlayer = $AnimationPlayer
onready var TimerStartAbsorb = $TimerStartAbsorb
onready var TimerAbsorb = $TimerAbsorb
onready var TimerVibration = $TimerVibration

func _ready() -> void :
	if Engine.is_editor_hint() == true:
		return
	
	if is_for_ui == true:
		$AreaDetectPlayer.queue_free()
	
	set_speed_anim(speed_anim)
	$AnimationPlayer.play(start_anim)
	
	
	if ElementalCircuits.was_obtained(circuit_mode, _get_selected_circuit()) == true:
		queue_free()

func set_speed_anim(spe: float = 0.5) -> void :
	$AnimationPlayer.playback_speed = spe
	speed_anim = spe

	

func start_vibration() -> void :
	_on_TimerVibration_timeout()
	TimerVibration.start()
func stop_vibration() -> void :
	Input.stop_joy_vibration(0)
	TimerVibration.stop()

func _connect_body_signals(body: Node) -> void :
	if body.has_signal("circuit_charge_started") == false:
		return
	if body.is_connected(
		"circuit_charge_started", self, "_on_circuit_start_absorb"
	) == false:
		
		body.connect(
			"circuit_charge_started", self, "_on_circuit_start_absorb"
		)
		
		body.connect(
			"circuit_charge_ended", self, "_on_circuit_end_absorb"
		)

func _on_circuit_start_absorb() -> void :
	TimerStartAbsorb.start()

func _on_circuit_end_absorb() -> void :
	TimerStartAbsorb.stop()
	_on_absorb_Circuit_Canceled()

func _get_selected_circuit() -> int:
	var returned_circuit: int = 0
	match circuit_mode:
		GVar.EC_MODE.ACTION:
			returned_circuit = action
		GVar.EC_MODE.ABILITY:
			returned_circuit = ability
		GVar.EC_MODE.SUBWEAPON:
			returned_circuit = subweapon
	return returned_circuit

func _update_action_icon(ico: int = action) -> void :
	action = ico
	
	if ico == - 1:
		$Icons / Action.visible = false
		return
	
	if circuit_mode == GVar.EC_MODE.ACTION:
		$Icons / Action.visible = true
	
	$Icons / Action.frame = ico

func _update_ability_icon(ico: int = ability) -> void :
	ability = ico
	if ico == - 1:
		$Icons / Ability.visible = false
		return
	
	if circuit_mode == GVar.EC_MODE.ABILITY:
		$Icons / Ability.visible = true
	
	$Icons / Ability.frame = ico

func _update_subweapon_icon(ico: int = subweapon) -> void :
	subweapon = ico
	
	if ico == - 1:
		$Icons / Subweapon.visible = false
		return
	
	if circuit_mode == GVar.EC_MODE.SUBWEAPON:
		$Icons / Subweapon.visible = true
	
	$Icons / Subweapon.frame = ico

func _update_mode(mod: int = circuit_mode) -> void :
	circuit_mode = mod
	
	
	if circuit_mode == 2:
		circuit_mode = 0
	
	_hide_icons()
	
	match circuit_mode:
		GVar.EC_MODE.ACTION:
			_update_color("004cff")
			_set_outline_color("002478")
			_update_action_icon()
		GVar.EC_MODE.SUBWEAPON:
			_update_color("9d14ac")
			_set_outline_color("5f1d62")
			_update_ability_icon()
		GVar.EC_MODE.ABILITY:
			_update_color("cb1111")
			_set_outline_color("780000")
			_update_subweapon_icon()
		_:
			_update_color("565656")
			_set_outline_color("000000")

func _update_color(modu: Color) -> void :
	
	custom_color = modu
	
	var node_to_modulate: Object
	
	for n in ["TriangleDown", "TriangleUp", "Shine", "TriangleFront"]:
		node_to_modulate = get_node_or_null(n)
		if node_to_modulate != null:
			node_to_modulate.modulate = modu
	
	if get_node_or_null("Light2D") != null:
		$Light2D.color = modu

func _set_outline_color(mod: Color) -> void :
	if get_node_or_null("Icons") != null:
		for i in $Icons.get_children():
			i.material = i.material.duplicate()
			i.material.set_shader_param("line_color", mod)

func _hide_icons() -> void :
	if get_node_or_null("Icons") != null:
		for i in $Icons.get_children():
			i.visible = false

func _on_AreaDetectPlayer_body_entered(body: Node) -> void :
	if "near_circuit" in body and is_for_ui == false:
		_connect_body_signals(body)
		body.near_circuit = true
		entered_player = true

func _on_AreaDetectPlayer_body_exited(body: Node) -> void :
	if "near_circuit" in body and is_for_ui == false:
		if _absorbing == true:
			VarsGlobal.Player.change_state("idle")
			_on_absorb_Circuit_Canceled()
		body.near_circuit = false
		entered_player = false

func _on_TimerConnectPlayerSignals_timeout() -> void :
	if (
		VarsGlobal.Player.has_signal("circuit_absorb_started")
		and VarsGlobal.Player.has_signal("circuit_absorb_canceled")
		and is_for_ui == false
		and Engine.is_editor_hint() == false
	):
		
		VarsGlobal.Player.connect("damaged", self, "_on_absorb_Circuit_Canceled", [], 1)

func _on_absorb_Circuit_Started() -> void :
	if (
		entered_player == true and _absorbing == false
		and VarsGlobal.Player.state != "circuit-charge"
	):
		start_vibration()
		Audio.play_sfx("ec_absorbing", true, 0.5)
		_absorbing = true
		AnimPlayer.playback_speed = 2.0
		TimerAbsorb.start()
		$TweenIconScale.interpolate_property(
			$Icons, "scale", Vector2(1, 1), Vector2(0, 0), 
			TimerAbsorb.wait_time
		)
		$TweenIconScale.start()
	
func _on_absorb_Circuit_Canceled() -> void :
	if _absorbing == true:
		stop_vibration()
		Audio.stop_sfx("ec_absorbing")
		_absorbing = false
		AnimPlayer.playback_speed = 0.5
		TimerAbsorb.stop()
		
		$TweenIconScale.stop_all()
		$TweenIconScale.reset_all()

func _on_TimerAbsorb_timeout() -> void :
	
	if _absorbing == false:
		return
	
	
	var was_obtained: bool = ElementalCircuits.was_obtained(
		circuit_mode, _get_selected_circuit()
	)
	
	stop_vibration()
	
	AnimPlayer.playback_speed = 0.5
	
	AnimPlayer.play("absorbed")
	Audio.stop_sfx("ec_absorbing")
	Audio.play_sfx("ec_absorbed")
	
	$AreaDetectPlayer.queue_free()
	
	
	if circuit_mode == GVar.EC_MODE.CUSTOM or was_obtained == true:
		VarsGlobal.game_data["player_mp_now"] = VarsGlobal.game_data["player_mp_max"]
		VarsGlobal.GameInterface.update_hud_values()
		return
		

	
	
	ElementalCircuits.obtain(circuit_mode, _get_selected_circuit())
	
	VarsGlobal.GameScenario.emit_signal("circuit_obtained")
	emit_signal("absorbed")
	
	
	VarsGlobal.GameInterface.update_hud_values(false)

	

func _on_ElementalCircuit_tree_exiting() -> void :
	if Engine.is_editor_hint() == false:
		Audio.stop_sfx("ec_absorbing")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void :
	
	if Engine.is_editor_hint() == true:
		return
	
	if anim_name == "absorbed":
		emit_signal("absorbed_anim_end")
		if delete_if_absorbed_anim_ends == true:
			queue_free()

func _on_TimerVibration_timeout() -> void :
	Gamepad.start_vibration(0, 0.9, 1.0, 0.8)

func _on_TimerStartAbsorb_timeout() -> void :
	if Input.is_action_pressed("ui_up"):
			_on_absorb_Circuit_Started()

func _on_ElementalCircuit_absorbed() -> void :
	Input.action_release("ui_up")
	VarsGlobal.GameInterface.show_circuit_desc(
		_get_selected_circuit(), 
		circuit_mode
	)
