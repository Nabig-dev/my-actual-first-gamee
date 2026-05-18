extends KinematicBody2D



var Plasma = preload("res://src/game_objects/enemies_weapons/elisia_plasm.tscn")
var Sphaera = preload("res://src/game_objects/enemies_weapons/elisia_sphaera.tscn")
var Cristal = preload("res://src/game_objects/enemies_weapons/elisia_cristal.tscn")
var Wisp = preload("res://src/game_objects/enemies_weapons/wisp.tscn")
var FireballBalor = preload("res://src/game_objects/enemies_weapons/fireball_balor.tscn")
var Thunder = preload("res://src/game_objects/enemies_weapons/thunder_elisia_ray.tscn")

signal defeated

export var scenario_center_x: int
export var electro_arrow_l: NodePath
export var electro_arrow_r: NodePath


var velocity: = Vector2()

var gravity: int = 600

var speed: int = 30

var _dashing: bool
var _2nd_phase: bool

var _spawned_wisp: bool
var _defeated: bool

onready var Enemy = $EnemyBase
onready var BossNode = $BossNode
onready var HurtboxEnemy = $HurtboxEnemy
onready var TimerNextMove = $TimerNextMove
onready var AnimPlayer = $AnimationPlayer
onready var DetectWallBack = $Sprite / DetectWallBack
onready var DetectWallFront = $Sprite / DetectWallFront

func _ready() -> void :
	Enemy.change_state("idle", true)
	
	

func _physics_process(delta) -> void :
	
	if _dashing == true:
		
		match Enemy.state:
			"walk":
				velocity.x = (speed * 2) * Enemy.facing
			"walkreverse":
				velocity.x = (speed) * (Enemy.facing * - 1)
			"fastatk":
				velocity.x = (speed * 4) * Enemy.facing
			_:
				velocity.x = 0

	if _dashing == false or Enemy.state in ["idle", "stand", "dead"]:
		velocity.x = 0
	
	if Enemy.state == "walk" and DetectWallFront.is_colliding():
		Enemy.change_direction("inverse")
	elif Enemy.state == "walkreverse" and DetectWallBack.is_colliding():
		Enemy.change_state("walk")

	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP, true)







func snd(val: String) -> void :
	Audio.play_sfx(val)

func start_battle() -> void :
	Enemy.change_state("idle", true)
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	
	BossNode.show_title_boss()
	Audio.play_music("elisia_boss_theme", "high", 0)
	yield(get_tree().create_timer(1), "timeout")

	BossNode.start_battle()
	
	Enemy.change_state("idle")
	TimerNextMove.start(2)
	yield(TimerNextMove, "timeout")
	if _2nd_phase == true: return
	
	next_move()

func next_move() -> void :

	if Enemy.state == "dead":
		return
	
	var current_plasma: int = get_tree().get_nodes_in_group("elisia_plasma").size()
	var max_plasma: int = 1
	
	
	randomize()
	
	if _2nd_phase == false:
	
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(0.5)
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["walk", "walkreverse"]))
		TimerNextMove.start(rand_range(1.5, 2.5))
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["bolt", "floor"]))
		yield(AnimPlayer, "animation_finished")
		if _2nd_phase == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["walk", "walkreverse"]))
		TimerNextMove.start(3)
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["plasma", "fastatk", "sphaera"]))
		if (
			Enemy.state == "plasma" and current_plasma > max_plasma
			or 
			get_tree().get_nodes_in_group("elisia_wisp").size() > 0
		):
			Enemy.change_state("fastatk")
			
		yield(AnimPlayer, "animation_finished")
		if _2nd_phase == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(3)
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return
		
		if randi() % 2 == 1 or _spawned_wisp == true:
			_spawned_wisp = false
			Enemy.change_direction("to_player")
			Enemy.change_state("cristal")
			yield(AnimPlayer, "animation_finished")
			if _2nd_phase == true: return
		else:
			spawn_wisp()

		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["walkreverse"]))
		TimerNextMove.start(3)
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return
		
		next_move()
	
	else:
		
		Enemy.change_direction("to_player")
		Enemy.change_state("idle", true)
		TimerNextMove.start(rand_range(0.5, 1))
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["walk", "walkreverse"]))
		TimerNextMove.start(2)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["bolt", "fastatk"]))
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(1)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("plasma")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("walkreverse")
		TimerNextMove.start(1)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("plasma")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("walkreverse")
		TimerNextMove.start(3)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("sphaera")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(1)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		if randi() % 2 == 1 or _spawned_wisp == true:
			_spawned_wisp = false
			Enemy.change_direction("to_player")
			Enemy.change_state("cristal")
			yield(AnimPlayer, "animation_finished")
			if _defeated == true: return
		else:
			spawn_wisp()

		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["walkreverse"]))
		TimerNextMove.start(2)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("floor")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["walk", "walkreverse"]))
		TimerNextMove.start(5)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("fastatk")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["walk", "walkreverse"]))
		TimerNextMove.start(3)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		next_move()

func set_dash(val: bool) -> void :
	_dashing = val

func jump() -> void :
	if is_on_floor() == true:
		velocity.y = - 150

func startarrow(dir: int = 0) -> void :
	if dir == 0:
		dir = Enemy.facing
	if dir == 1:
		get_node(electro_arrow_r).startmove()
	else:
		get_node(electro_arrow_l).startmove()

func spawn_fireball() -> void :
	Audio.play_sfx("shoot_projectile")
	var ObjInstance = FireballBalor.instance()
	ObjInstance.global_position = $Sprite / PositionStaffOrb.global_position
	ObjInstance.dir = Enemy.facing
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	if _2nd_phase == true:
		spawn_thunder()

func spawn_thunder(time_to_start: float = 0.5) -> void :
	if _defeated == true:
		return
	var ObjInstance = Thunder.instance()
	ObjInstance.global_position = Vector2(
		Enemy.get_player_position().x, 
		global_position.y
	)
	ObjInstance.time_to_start = time_to_start
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	

func spawn_plasma() -> void :
	if _defeated == true or VarsGlobal.GameScenario.boss_battle_active == false:
		return
	var ObjInstance = Plasma.instance()
	ObjInstance.global_position = $Sprite / PositionStaffOrb.global_position

	if Enemy.state == "plasma":
		if Enemy.facing == 1:
			ObjInstance.angle_degrees = - 320
		else:
			ObjInstance.angle_degrees = 140
	
	ObjInstance.connect("destroyed_by_player", self, "_on_plasma_destroyed")
	
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_sphaera() -> void :
	if _defeated == true:
		return
	var ObjInstance = Sphaera.instance()
	ObjInstance.global_position = $Sprite / PositionStaffOrb.global_position
	ObjInstance.dir = Enemy.facing
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_cristal(pos: Vector2, time_active: float) -> void :
	if _defeated == true:
		return
	var ObjInstance = Cristal.instance()
	ObjInstance.global_position = pos
	ObjInstance.time_to_start = time_active
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_wisp() -> void :
	if _defeated == true:
		return
	if get_tree().get_nodes_in_group("elisia_wisp").size() > 0:
		return
	_spawned_wisp = true
	var ObjInstance = Wisp.instance()
	ObjInstance.global_position = Vector2(
		scenario_center_x, global_position.y - 100
	)
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)


func clear_weapons() -> void :
	get_tree().call_group("elisia_plasma", "queue_free")
	get_tree().call_group("elisia_sphaera", "queue_free")
	get_tree().call_group("elisia_cristal", "queue_free")
	get_tree().call_group("elisia_wisp", "queue_free")
	get_node(electro_arrow_l).stopmove()
	get_node(electro_arrow_r).stopmove()

func start_thunders() -> void :
	if _2nd_phase == false:
		spawn_thunder(0.5)
	else:
		spawn_thunder(0.5)
		spawn_thunder(1)
		spawn_thunder(1.5)
		spawn_thunder(2)
		spawn_thunder(3)

func start_cristals() -> void :
	randomize()
	var pos_to_spawn: Vector2 = global_position - Vector2(0, 150)
	pos_to_spawn.x = scenario_center_x
	
	var positions_x: Array = [0, 80, - 80]
	var times_start: Array = [1, 1.5, 2]
	
	
	
	
	
	positions_x.shuffle()
	times_start.shuffle()
	
	for n in range(positions_x.size()):
		spawn_cristal(
			pos_to_spawn + Vector2(positions_x[n], 0), 
			times_start[n]
		)

func _rumble() -> void :
	Audio.play_sfx("explosion_light2")
	VarsGlobal.GameScenario.CameraNode.start_shake(0.4, false, false)
	Gamepad.start_vibration(0, 0.4, 0.4, 0.5)

func _on_DetectWallBack_object_entered(_Obj) -> void :
	if Enemy.state == "walkinverse":
		Enemy.change_state("walk")
func _on_DetectWallFront_object_entered(_Obj) -> void :
	if Enemy.state == "walk":
		Enemy.change_direction("inverse")


func _on_AreaDetectPlayerFacing_area_exited(_area: Area2D) -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")
	elif Enemy.state == "walkreverse":
		Enemy.change_state("walk")


func _on_HurtboxEnemy_damaged() -> void :
	
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")
		Enemy.change_state("walkreverse")
	if Enemy.state == "walkreverse":
		Enemy.change_direction("to_player")
	
	var hp_percent: = FuncsNumbers.get_percentage(
		HurtboxEnemy.hp_now, HurtboxEnemy.hp_max
	)
	
	if (
		hp_percent <= 50
		and HurtboxEnemy.hp_now > 0
		and VarsGlobal.game_data["player_hp_now"] > 0
		and _2nd_phase == false
	):
		VarsGlobal.GameInterface.show_flash()
		Enemy.change_state("idle", true)
		Enemy.state = "dead"
		_2nd_phase = true
		clear_weapons()
		TimerNextMove.stop()
		AnimPlayer.play("RESET")
		yield(get_tree(), "idle_frame")
		
		AnimPlayer.play("two_a")
		yield(AnimPlayer, "animation_finished")
		Enemy.state = "idle"
		next_move()

func _on_plasma_destroyed() -> void :
	if Enemy.state == "idle":
		Enemy.change_direction("to_player")
		Enemy.change_state("walk")


func _on_HurtboxEnemy_defeated() -> void :
	_defeated = true
	clear_weapons()
	emit_signal("defeated")

func _on_defeated_anim_finished() -> void :
	BossNode.unlock_boss_doors()
