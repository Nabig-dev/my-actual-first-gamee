extends KinematicBody2D

signal battle_ended
signal tweened_to_position

var AuraExplosion = preload("res://src/game_objects/enemies_weapons/explosion_aura_alessandro.tscn")
var TornadoHorizontal = preload("res://src/game_objects/enemies_weapons/tornado_horizontal.tscn")
var TornadoVertical = preload("res://src/game_objects/enemies_weapons/tornado_vertical.tscn")
var FlashBang = preload("res://src/game_objects/enemies_weapons/flash_bang.tscn")
var Bolt = preload("res://src/game_objects/enemies_weapons/bolt_aeria.tscn")

export var AreaFly: NodePath
export var Thermit: NodePath

var _defeated: bool

onready var Enemy = $EnemyBase
onready var BossNode = $BossNode
onready var PositionAura = $PositionAura
onready var PositionBolt = $Sprite / PositionBolt
onready var GhostTrail = $GhostTrail
onready var HurtboxEnemy = $Sprite / HurtboxEnemy
onready var CollisionHitbox = $Sprite / HitboxEnemy / CollisionShape2D

var Tw: SceneTreeTween

var fly_limits: Dictionary

var ThermitFloor: Object = null

var position_floor: Vector2

var battle_phase: int = 0

var _current_move_phase: int = 0

var _final_phase_reached: bool = false

var movements: Array = [
	
	[
		["bolt"], ["tornado_h"], ["bolt"]
	], 
	
	[
		["bolt"], ["tornado_v"], ["tornado_h"]
	], 
	
	[
		["explosion"], ["tornado_v", "bolt"], ["tornado_v"]
	], 
	
	[
		["bolt", "tornado_h"], ["tornado_v"], ["explosion"]
	]
]

func _ready() -> void :
	
	ThermitFloor = get_node_or_null(Thermit)
	
	position_floor = global_position
	
	var _area_fly = get_node_or_null(AreaFly)
	if _area_fly is ColorRect:
		_area_fly.visible = false
		var begin: Vector2 = _area_fly.get_begin()
		var end: Vector2 = _area_fly.get_end()
		fly_limits = {
			"l": int(begin.x), 
			"t": int(begin.y), 
			"r": int(end.x), 
			"b": int(end.y), 
		}
	
	Enemy.change_state("idle", true)

func start_battle() -> void :
	
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	
	BossNode.show_title_boss()
	Audio.play_music("alessandro_fight_theme", "high", 0)
	yield(get_tree().create_timer(1), "timeout")
	
	$AnimFly.play("flying")
	
	move_to_pos(
		Vector2(global_position.x, fly_limits["t"]), 1.5
	)
	yield(self, "tweened_to_position")
	
	BossNode.start_battle()
	next_move()

func next_move(skip_move: bool = false) -> void :
	randomize()
	Enemy.change_state("idle")
	Audio.stop_sfx("ec_charging_enemy")
	
	var _next_move: String = RNGTools.pick(movements[battle_phase][_current_move_phase])
	
	if skip_move == false:
		move_to_pos()
		yield(self, "tweened_to_position")
		if _defeated == true: return
	
	
	if battle_phase == 3:
		yield(get_tree().create_timer(1), "timeout")
		if _defeated == true: return
	
	if (
		_next_move == "tornado_v" and 
		get_tree().get_nodes_in_group("tornado_v").size() > 0
	):
		_next_move = RNGTools.pick(["bolt", "tornado_h"])
	
	if _defeated == true: return
	Enemy.change_state(_next_move)
	
	_current_move_phase += 1
	if _current_move_phase > 2:
		_current_move_phase = 0

func move_to_pos(
	pos: = Vector2.ZERO, 
	duration: int = 0
) -> void :
	
	Enemy.change_state("fly_up", true)
	
	var new_pos = pos
	
	
	if pos == Vector2.ZERO:
		randomize()
		var _x = rand_range(fly_limits["l"], fly_limits["r"])
		var _y = rand_range(fly_limits["t"], fly_limits["b"])
		new_pos = Vector2(_x, _y)
	
	var duration_move: float = duration
	Tw = get_tree().create_tween()
	var distance = global_position.distance_to(new_pos)
	
	if duration_move == 0:
		if distance > 100:
			duration_move = 2
		elif distance > 30:
			duration_move = 1
		else:
			duration_move = 0.5
	
	CollisionHitbox.disabled = true
	
	
	
	Tw.set_trans(Tween.TRANS_CUBIC)
	
	Tw.tween_property(
		self, "global_position", new_pos, duration_move
	)

	GhostTrail.start_trail(0, 0.08)
	Enemy.change_direction("to_player")
	
	yield(Tw, "finished")
	
	CollisionHitbox.disabled = false
	
	GhostTrail.stop_trail()
	Enemy.change_direction("to_player")
	
	Enemy.change_state("idle")

	emit_signal("tweened_to_position")

func spawn_aura_explosion() -> void :
	Audio.play_sfx("spell_shoot3")
	Gamepad.start_vibration(0, 0.3, 0.0, 0.3)
	VarsGlobal.GameScenario.CameraNode.start_shake(
		0.4, true, true
	)
	var ObjInstance = AuraExplosion.instance()
	ObjInstance.position = PositionAura.position
	ObjInstance.play()
	call_deferred("add_child", ObjInstance)

func spawn_bolt() -> void :
	Audio.play_sfx("spell_shoot")
	var ObjInstance = Bolt.instance()
	ObjInstance.global_position = PositionBolt.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_flashbang() -> void :
	pass

func spawn_tornado_h() -> void :
	Audio.play_sfx("spell_shoot")
	Audio.stop_sfx("ec_charging_enemy")
	var ObjInstance = TornadoHorizontal.instance()
	ObjInstance.dir = Enemy.facing
	ObjInstance.global_position = $Sprite / PositionTornadoH.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
func spawn_tornado_v() -> void :
	
	
	for t in get_tree().get_nodes_in_group("tornado_v"):
		t.dissapear()
	
	randomize()
	var ObjInstance = TornadoVertical.instance()
	ObjInstance.global_position = Vector2(
		rand_range(fly_limits["l"], fly_limits["r"]), 
		fly_limits["b"] + 16
	)
	
	if battle_phase != 3:
		ObjInstance.time_active = 2
	
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _explosion_pre_snd() -> void :
	Audio.play_sfx("spell_prepare2")

func _tornado_h_snd() -> void :
	Audio.play_sfx("woosh_attack")

func _tween_to(new_pos: Vector2, duration: float) -> void :
	Tw = get_tree().create_tween()
	
	Tw.set_trans(Tween.TRANS_CUBIC)
	
	Tw.tween_property(
		self, "global_position", new_pos, duration
	)

func _fall_to_floor() -> void :
	pass

func _vibration() -> void :
	VarsGlobal.GameScenario.CameraNode.start_shake(0.4, false, false)
	Gamepad.start_vibration(0, 0.4, 0.4, 0.5)

func _clear_atks() -> void :
	Audio.stop_sfx("ec_charging_enemy")
	ThermitFloor.can_spawn = false
	ThermitFloor.visible = false
	$TimerSecondAttack.stop()
	
	
	for f in get_tree().get_nodes_in_group("flashbang"):
		f.queue_free()
	
	
	for t in get_tree().get_nodes_in_group("tornado_v"):
		t.dissapear()
	
	for t in get_tree().get_processed_tweens():
		if t.is_running() == true:
			t.stop()

func _on_HurtboxEnemy_damaged() -> void :
	
	

	
	
	if Enemy.state in ["idle", "fly_up"]:
		Enemy.change_direction("to_player")
	
	if _final_phase_reached == true:
		return
	
	var hp_percent: = FuncsNumbers.get_percentage(
		HurtboxEnemy.hp_now, HurtboxEnemy.hp_max
	)
	
	if hp_percent >= 60 and hp_percent < 80 and battle_phase < 1:
		battle_phase = 1
		_current_move_phase = 0
		
	
	elif hp_percent < 60 and battle_phase < 2:
		battle_phase = 2
		_current_move_phase = 0
		
	
	
	
	elif (
		hp_percent <= 40
		and HurtboxEnemy.hp_now > 0
		and VarsGlobal.game_data["player_hp_now"] > 0
	):
		_final_phase_reached = true
		battle_phase = 3
		_clear_atks()
		
		VarsGlobal.Player.set_enabled_input(false)
		VarsGlobal.Player.stop_move()
		Enemy.change_state("idle", true)

		VarsGlobal.GameInterface.start_dialog("alessandro_thermit")
		yield(VarsGlobal.GameInterface, "dialog_ended")
		
		VarsGlobal.GameInterface.can_pause = false
		
		
		
		
		Enemy.change_state("fly_up")
		var hp_to_recover: int = 7
		
		
		
		for _n in range(7):
			Audio.play_sfx("ui_item_use")
			$Sprite / HurtboxEnemy.hp_now += hp_to_recover
			VarsGlobal.GameScenario.show_damage_number(
				hp_to_recover, HurtboxEnemy.global_position, "green"
			)
			BossNode._on_enemy_damaged()
			yield(get_tree().create_timer(0.3), "timeout")
		
		VarsGlobal.GameInterface.can_pause = true
		VarsGlobal.Player.set_enabled_input(true)
		ThermitFloor.can_spawn = true
		ThermitFloor.visible = true
		$TimerSecondAttack.start(0.5)
		next_move()

func _on_AnimationPlayer_animation_started(anim_name: String) -> void :
	match anim_name:
		"bolt":
			Audio.play_sfx("spell_prepare")
		"tornado_h":
			Audio.play_sfx("ec_charging_enemy")
			_tween_to(
				Vector2(global_position.x, fly_limits["b"]), 1.2
			)
	if anim_name != "tornado_h":
		Audio.stop_sfx("ec_charging_enemy")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void :
	if anim_name in ["dead", "dead2"]:
		Audio.stop_music("all", 2.0)
		$AnimFly.stop()
		$AnimationPlayer.stop(true)
		
		emit_signal("battle_ended")
		Audio.stop_music("all", 1.0)

func _on_Alessandro1_tree_exiting() -> void :
	Audio.stop_sfx("ec_charging_enemy")

func _on_HurtboxEnemy_defeated() -> void :
	
	_defeated = true
	if (
		Config.get_value(
			"difficulty", "desperation_attack", true)
	) == true:
		Enemy.change_state("dead", true)
	else:
		Enemy.change_state("dead2", true)
	
	$AnimFly.stop(true)
	_clear_atks()
	
func _on_TimerSecondAttack_timeout() -> void :
	randomize()
	if ThermitFloor.is_active == false:
		ThermitFloor.spawn(RNGTools.pick([1, - 1]))
	
	

	$TimerSecondAttack.start(rand_range(2, 3))

func _on_TimerSpawnVerticalBolt_timeout() -> void :
	
	_vibration()
	
	randomize()
	
	Audio.play_sfx("spell_shoot")
	
	var ObjInstance = Bolt.instance()
	
	ObjInstance.auto_target = false
	
	
	ObjInstance.global_position = Vector2(
		Enemy.get_player_position().x + rand_range( - 30, 30), 
		fly_limits["t"] - 100
	)
	
	
	ObjInstance.target_position = Vector2(
		ObjInstance.global_position.x, 
		ObjInstance.global_position.y + 300
	)
	
	ObjInstance.speed = 200

	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
