extends KinematicBody2D

var NoMaskSprite = preload("res://assets/sprites/enemies/boss_eva_nomask.png")

var Knife = preload("res://src/game_objects/enemies_weapons/eva_knife.tscn")
var GasFront = preload("res://src/game_objects/enemies_weapons/gas_front_eva.tscn")
var GasColumn = preload("res://src/game_objects/enemies_weapons/gas_column_eva.tscn")
var GasBall = preload("res://src/game_objects/enemies_weapons/gas_ball_eva.tscn")
var PlasmBall = preload("res://src/game_objects/enemies_weapons/eva_plasm_ball.tscn")
var AcidShoot = preload("res://src/game_objects/enemies_weapons/acid_shoot.tscn")
var AcidCircle = preload("res://src/game_objects/enemies_weapons/eva_circuit_acid_circle.tscn")

export var ZombieSpawner: NodePath


var velocity: = Vector2()

var gravity: int = 250

var speed: int = 50

var _dashing: bool
var _2nd_phase: bool
var _defeated: bool

onready var Enemy = $EnemyBase
onready var BossNode = $BossNode
onready var TimerNextMove = $TimerNextMove
onready var Position2DHandThrow = $Sprite / Position2DHandThrow
onready var AnimPlayer = $AnimationPlayer
onready var HurtboxEnemy = $HurtboxEnemy
onready var TimerSpawnRain = $TimerSpawnRain

func _ready() -> void :
	Enemy.change_state("idle", true)
	











func _physics_process(delta) -> void :
	
	if _dashing == true:
		
		match Enemy.state:
			"walk":
				velocity.x = (speed) * Enemy.facing
			"walkreverse":
				velocity.x = (speed) * (Enemy.facing * - 1)
			"fastatk":
				velocity.x = (speed * 8) * Enemy.facing
			_:
				velocity.x = 0

	if _dashing == false or Enemy.state in ["idle", "stand", "dead"]:
		velocity.x = 0
	




	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP, true)

func set_dash(val: bool) -> void :
	_dashing = val


func start_battle() -> void :
	Audio.play_voice("eva_laugh")
	Enemy.change_state("idle", true)
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	
	BossNode.show_title_boss()
	Audio.play_music("eva_fight_theme", "high", 0)
	yield(get_tree().create_timer(1), "timeout")

	BossNode.start_battle()
	
	Enemy.change_state("idle")
	TimerNextMove.start(0.5)
	yield(TimerNextMove, "timeout")
	if _2nd_phase == true: return
	
	next_move()


func next_move() -> void :

	if Enemy.state == "dead":
		return
	
	randomize()
	
	if _2nd_phase == false:
		
		speed = 50
	
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(1)
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state("walk")
		TimerNextMove.start(rand_range(2, 3))
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["gasfront", "gascolumn", "fastatk"]))
		yield(AnimPlayer, "animation_finished")
		if _2nd_phase == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state("walk")
		TimerNextMove.start(rand_range(1, 2))
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["gasball", "gascolumn", "throw"]))
		yield(AnimPlayer, "animation_finished")
		if _2nd_phase == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(3)
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return
		
		$GasFloor.activate()

		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(2)
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return
		
		speed = 25

		Enemy.change_direction("to_player")
		Enemy.change_state("walk")
		TimerNextMove.start(2)
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return
		
		$GasFloor.deactivate()
		
		speed = 50
		
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(2)
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["gasball", "gascolumn", "throw"]))
		yield(AnimPlayer, "animation_finished")
		if _2nd_phase == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(1)
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return
		
		next_move()
	
	else:
		
		speed = 80
	
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(1)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["gasfront", "gascolumn", "fastatk"]))
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("teleport")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("fastatk")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return
		
		get_node(ZombieSpawner).active = true

		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(4)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("circuits")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return
		
		get_node(ZombieSpawner).active = false
		_spawn_gascolumn()

		Enemy.change_direction("to_player")
		Enemy.change_state("walk")
		TimerNextMove.start(rand_range(1, 2))
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(1)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["gasball", "gascolumn", "throw"]))
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("teleport")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state("acidrain")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(5)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		$GasFloor.activate()
		speed = 50
		
		Enemy.change_direction("to_player")
		Enemy.change_state("walk")
		TimerNextMove.start(2)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		speed = 80
		
		$GasFloor.deactivate()
		
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(2)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		_spawn_gascolumn()

		Enemy.change_direction("to_player")
		Enemy.change_state("walk")
		TimerNextMove.start(2)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		_spawn_acidcircle()
		
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(3)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		next_move()

func snd_teleport_in() -> void :
	$lasershort.play()
	$vlad_spawn_start.play()
func snd_teleport_out() -> void :
	$lasershort3.play()
	$vlad_spawn_end.play()

func _move_to_x_player() -> void :
	global_position.x = Enemy.get_player_position().x

func _clear_atk() -> void :
	get_node(ZombieSpawner).active = false
	$GasFloor.deactivate()
	TimerSpawnRain.stop()
	$Sprite / ParticlesAcidUp.emitting = false
	get_tree().call_group("atk_eva", "queue_free")
	$GasFloor.deactivate()

func _snd(snd: String) -> void :
	Audio.play_sfx(snd)
func _play_snd_charge() -> void :
	Audio.play_sfx("ec_charging_enemy")
func _stop_snd_charge() -> void :
	Audio.stop_sfx("ec_charging_enemy")

func _start_rain(limit: int = 6, inbetween: float = 0.4) -> void :
	var current: int = 0
	while current < limit:
		_spawn_acidrain()
		current += 1
		TimerSpawnRain.start(inbetween)
		yield(TimerSpawnRain, "timeout")

func _spawn_acidcircuit() -> void :
	randomize()
	var ObjInstance = AcidShoot.instance()
	var Circuits: Array = $Sprite / Circuits.get_children()
	Circuits.shuffle()
	
	ObjInstance.global_position = Circuits[0].global_position
	ObjInstance.collide = false
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _spawn_acidshoot() -> void :
	var ObjInstance = AcidShoot.instance()
	ObjInstance.global_position = global_position - Vector2(0, 100)
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _spawn_acidcircle() -> void :
	Enemy.change_direction("to_player")
	var ObjInstance = AcidCircle.instance()
	ObjInstance.dir = Enemy.facing
	ObjInstance.global_position = global_position - Vector2(0, 100)
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
func _spawn_acidrain() -> void :
	randomize()
	var rand_x: float = rand_range( - 50, 50)
	var ObjInstance = AcidShoot.instance()
	ObjInstance.global_position = Vector2(
		Enemy.get_player_position().x + rand_x, 
		global_position.y - 200
	)
	ObjInstance.auto_target = false
	ObjInstance.target_position = Vector2(
		ObjInstance.global_position.x, 
		global_position.y + 100
	)
	ObjInstance.collide = true
	ObjInstance.speed = 800
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _spawn_gascolumn() -> void :
	randomize()
	var position_spawn: Vector2 = global_position
	var ObjInstance = GasColumn.instance()
	position_spawn.x = VarsGlobal.Player.global_position.x
	
	position_spawn.x += rand_range( - 30, 30)
	ObjInstance.time_active = 5
	ObjInstance.global_position = position_spawn
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _spawn_gasfront() -> void :
	var ObjInstance = GasFront.instance()
	ObjInstance.dir = Enemy.facing
	ObjInstance.global_position = Position2DHandThrow.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _spawn_gasball() -> void :
	var ObjInstance = GasBall.instance()
	ObjInstance.dir = Enemy.facing
	ObjInstance.global_position = Position2DHandThrow.global_position - Vector2(0, 10)
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _spawn_plasmball() -> void :
	var ObjInstance = PlasmBall.instance()
	
	if _2nd_phase == true:
		ObjInstance.bounce = 1
	ObjInstance.dir = Enemy.facing
	ObjInstance.global_position = $Sprite / EvaPlasmball.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _changesprite() -> void :
	$Sprite.texture = NoMaskSprite

func _on_DetectWallFront_object_entered(_Obj) -> void :
	if Enemy.state in ["walk", "idle"]:
		Enemy.change_direction("inverse")


func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state in ["walk", "idle"]:
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
		
		Audio.stop_music()
		
		VarsGlobal.GameInterface.show_flash()
		Enemy.change_state("idle", true)
		Enemy.state = "dead"
		_2nd_phase = true
		
		_clear_atk()

		VarsGlobal.GameInterface.can_pause = false
		VarsGlobal.Player.set_enabled_input(false)
		VarsGlobal.Player.stop_move()
		
		Engine.set_time_scale(0.5)
		
		AnimPlayer.play("lostmask")
		Audio.play_music("before_isaac_eva")
		VarsGlobal.GameInterface.start_dialog("eva-phase2-1")
		yield(VarsGlobal.GameInterface, "dialog_ended")
		
		Engine.set_time_scale(1)
		
		yield(get_tree().create_timer(5), "timeout")
		
		
		
		
		VarsGlobal.GameInterface.start_dialog("eva-phase2-2")
		yield(VarsGlobal.GameInterface, "dialog_ended")
		
		VarsGlobal.GameScenario.get_node("RainLayer").start_rain()
		yield(get_tree().create_timer(3), "timeout")
		
		
		VarsGlobal.GameInterface.start_dialog("eva-phase2-3")
		yield(VarsGlobal.GameInterface, "dialog_ended")
		
		yield(get_tree().create_timer(1), "timeout")
	
		VarsGlobal.GameInterface.can_pause = true
		VarsGlobal.Player.set_enabled_input(true)
		Audio.play_music("eva_fight_theme2")
		Enemy.state = "idle"
		VarsGlobal.GameInterface.show_flash()
		$Sprite / SpriteMask.visible = false
		next_move()

func _on_AreaDetectPlayerFacing_area_exited(_area: Area2D) -> void :
	if Enemy.state in ["walk", "idle"]:
		Enemy.change_direction("to_player")


func _on_EnemyBase_state_changed(_state) -> void :
	_stop_snd_charge()


func _on_Eva_tree_exiting() -> void :
	_stop_snd_charge()


func _on_HurtboxEnemy_defeated() -> void :
	_defeated = true
	_clear_atk()
