extends KinematicBody2D

var Boomerang = preload("res://src/game_objects/enemies_weapons/boomerang_sheal.tscn")
var Projectile = preload("res://src/game_objects/enemies_weapons/ice_projectile_sheal.tscn")
var IceBall = preload("res://src/game_objects/enemies_weapons/iceball_wall.tscn")
var IceRock = preload("res://src/game_objects/enemies_weapons/ice_rock_fall.tscn")
var IceFloor = preload("res://src/game_objects/enemies_weapons/ice_floor.tscn")

export var limit_pos_l: float
export var limit_pos_r: float

export var ice_floor: NodePath


var velocity: = Vector2()

var gravity: int = 250

var speed: int = 20

var battle_phase: int = 0
var _current_move_phase: int = 0

var _defeated: bool

var movements: Array = [
	
	[
		["projectile", "sphere"], 
		["fastatk"], 
		["projectile"], 
		["fastatk"], 
		["icefloor"]
	], 
	
	[
		["floor"], 
		["floorslash"], 
		["sphere"], 
		["projectile", "fastatk"], 
		["fastatk"]
	]
]

var _dashing: bool = false

onready var Enemy = $EnemyBase
onready var BossNode = $BossNode
onready var DetectWallFront = $Sprite / DetectWallFront
onready var BoomerangPos = $Sprite / PosBoomerang
onready var HurtboxEnemy = $HurtboxEnemy

func _ready() -> void :
	Enemy.change_state("idle", true)

func start_battle() -> void :
	
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	
	BossNode.show_title_boss()
	Audio.play_music("sheal_fight_theme", "high", 0)
	yield(get_tree().create_timer(1), "timeout")
	BossNode.start_battle()
	Enemy.change_state("idle")
	yield(get_tree().create_timer(3), "timeout")
	next_move()

func _physics_process(_delta: float) -> void :
	
	if _dashing == true:
		
		velocity.x = 300 * Enemy.facing
		velocity = move_and_slide(velocity)
		
	if DetectWallFront.is_colliding() == true:
		Enemy.change_direction("inverse")
		_dashing = false


func _snd_spell() -> void :
	Audio.play_sfx("spell_prepare")

func _icefloor() -> void :
	get_node(ice_floor).showfloor()

func spawn_icerocks() -> void :
	Audio.play_sfx("atk_charge_prepare")
	randomize()
	var dir: int = RNGTools.pick([1, - 1])
	var pos_to_spawn: = Vector2(limit_pos_l, global_position.y - 120)
	
	if dir == 1:
		while pos_to_spawn.x < limit_pos_r + 40:
			_spawn_icerock(pos_to_spawn)
			pos_to_spawn.x += 70
			yield(get_tree().create_timer(0.5), "timeout")
	
	else:
		pos_to_spawn.x = limit_pos_r
		while pos_to_spawn.x > limit_pos_l - 40:
			_spawn_icerock(pos_to_spawn)
			pos_to_spawn.x -= 70
			yield(get_tree().create_timer(0.5), "timeout")

func _spawn_icerock(pos: Vector2) -> void :


	var ObjInstance = IceRock.instance()
	ObjInstance.global_position = pos
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_icefloor(dir: int = 0) -> void :
	
	if get_tree().get_nodes_in_group("shealboomerang").size() > 0:
		return
	
	randomize()
	if dir == 0:
		dir = RNGTools.pick([1, - 1])
	
	var ObjInstance: RigidBody2D
	var pos_to_spawn: = Vector2(0, global_position.y)
	
	
	var Circuit: Node2D = get_node("%Circuit1").duplicate()
	
	if dir == 1:
		pos_to_spawn.x = limit_pos_l
	elif dir == - 1:
		pos_to_spawn.x = limit_pos_r
	
	Circuit.global_position = pos_to_spawn
	Circuit.scale = Vector2.ZERO
	Circuit.custom_color = Color("004cff")
	VarsGlobal.GameScenario.add_child(Circuit)
	
	var Tw: = create_tween()
	
	Tw.tween_property(
		Circuit, "scale", Vector2(1, 1), 1
	)
	yield(Tw, "finished")
	
	Audio.play_sfx("spell_prepare2")
	Circuit.queue_free()
	
	if dir == 1:
		while pos_to_spawn.x < limit_pos_r + 30:


			ObjInstance = IceFloor.instance()
			ObjInstance.global_position = pos_to_spawn
			VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
			pos_to_spawn.x += 30
			yield(get_tree().create_timer(0.2), "timeout")
	
	else:
		pos_to_spawn.x = limit_pos_r
		while pos_to_spawn.x > limit_pos_l - 30:


			ObjInstance = IceFloor.instance()
			ObjInstance.global_position = pos_to_spawn
			VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
			pos_to_spawn.x -= 30
			yield(get_tree().create_timer(0.2), "timeout")

func _spawn_iceball(pos: Vector2, dir: int, dir_y: int) -> void :
	if _defeated == true:
		return
	var ObjInstance = IceBall.instance()
	ObjInstance.global_position = pos
	ObjInstance.dir = dir
	ObjInstance.dir_y = dir_y
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _spawn_iceball_wall() -> void :
	
	
	_spawn_iceball(
		get_node("%CircuitHand").global_position + Vector2(0, - 5), 
		Enemy.facing, - 1
	)
	_spawn_iceball(
		get_node("%CircuitHand").global_position + Vector2(0, 5), 
		Enemy.facing, 1
	)
	_spawn_iceball(
		get_node("%CircuitHand").global_position, 
		Enemy.facing, 0
	)
	

func _spawn_boomerang() -> void :
	
	if _defeated == true or battle_phase == 0 or get_tree().get_nodes_in_group("shealboomerang").size() == 2:
		return
	
	var ObjInstance = Boomerang.instance()
	ObjInstance.dir = Enemy.facing
	ObjInstance.global_position = BoomerangPos.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _spawn_projectile_ice(randompos: bool = true, pos: Vector2 = Vector2.ZERO) -> void :
	if _defeated == true:
		return
	var ObjInstance = Projectile.instance()
	ObjInstance.dir = Enemy.facing
	if randompos == true:
		randomize()
		ObjInstance.global_position = RNGTools.pick(
			[get_node("%Circuit1"), get_node("%Circuit2")]
		).global_position
	else:
		ObjInstance.global_position = pos
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _spawn_projectile_circuit3() -> void :
	if _defeated == true:
		return
	_spawn_projectile_ice(
		false, 
		$Sprite / Circuits / Circuit3.global_position
	)

func _snd_sword_slash() -> void :
	Audio.play_sfx("sword_slash_slow4")

func _set_dash(val: bool) -> void :
	_dashing = val









func next_move() -> void :
	randomize()
	var _next_atk: String
	
	
	_next_atk = RNGTools.pick(movements[battle_phase][_current_move_phase])
	
	_current_move_phase += 1
	if _current_move_phase > 4:
		_current_move_phase = 0
	
	if battle_phase == 1:
		if _next_atk == "fastatk":
			spawn_icefloor(0)
		
		if _next_atk == "floorslash":
			spawn_icerocks()
			pass
	
	
	if _next_atk == "floor" and get_tree().get_nodes_in_group("player_freezer").size() == 1:
		_next_atk = "fastatk"
	
	Enemy.change_direction("to_player")
	Enemy.change_state(_next_atk)

func _on_attack_finished() -> void :
	
	Enemy.change_direction("to_player")
	
	if battle_phase == 0:
		Enemy.change_state("idle")
		yield(get_tree().create_timer(1), "timeout")
	
	elif battle_phase == 1:
		Enemy.change_state("idle")
		yield(get_tree().create_timer(1.5), "timeout")

	next_move()


func _on_HurtboxEnemy_damaged() -> void :
	
	if Enemy.state == "idle":
		Enemy.change_direction("to_player")
	
	var hp_percent: = FuncsNumbers.get_percentage(
		HurtboxEnemy.hp_now, HurtboxEnemy.hp_max
	)
	
	if hp_percent < 60 and battle_phase < 1:
		battle_phase = 1
		_current_move_phase = 0


func _on_HurtboxEnemy_defeated() -> void :
	_defeated = true
	VarsGlobal.Player.invencibility(2, false)
	if (
		Config.get_value(
			"difficulty", "desperation_attack", true)
	) == false:
		$AnimationPlayer.play("RESET")
		yield(get_tree(), "idle_frame")
		$AnimationPlayer.play("dead2")
	yield(get_tree(), "idle_frame")
	Audio.play_music("after_dirian_sheal")

func _on_dead_anim_end() -> void :
	
	BossNode.unlock_boss_doors()
