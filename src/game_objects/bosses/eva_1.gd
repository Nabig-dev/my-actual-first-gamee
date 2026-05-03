extends KinematicBody2D

signal battle_ended

var Knife = preload("res://src/game_objects/enemies_weapons/eva_knife.tscn")
var GasFront = preload("res://src/game_objects/enemies_weapons/gas_front_eva.tscn")
var GasColumn = preload("res://src/game_objects/enemies_weapons/gas_column_eva.tscn")


var velocity: = Vector2()

var gravity: int = 250

var speed: int = 50

var active: bool

var attacks = [
	"throw", "gasfront", 
	"walk"
]

var attacks_done_count: int = 0

onready var Position2DHandThrow = $Sprite / Position2DHandThrow
onready var Enemy = $EnemyBase
onready var TimerNewAtk = $TimerNewAtk

onready var KnifeEva = $Sprite / KnifeEva

func start_battle() -> void :
	Audio.play_voice("eva_laugh")
	active = true
	$BossNode.start_battle()
	$BossNode.show_title_boss()
	Enemy.change_state("idle", true)
	TimerNewAtk.start(2)

func _physics_process(delta) -> void :
	
	if Enemy.state == "walk":
		velocity.x = speed * Enemy.facing
	else:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	if (is_on_floor() and Enemy.state == "walk") and is_on_wall():
		Enemy.change_direction("inverse")

func _play_charge() -> void :
	Audio.play_sfx("ec_charging_enemy")
func _stop_charge() -> void :
	Audio.stop_sfx("ec_charging_enemy")


func _spawn_knife() -> void :
	_spawn_knifes( - 100, - 20)
	_spawn_knifes()
	_spawn_knifes(100, 20)

func _spawn_knifes(vel_y: float = 0.0, rot: float = 0.0) -> void :
	var ObjInstance = Knife.instance()
	ObjInstance.dir = Enemy.facing
	ObjInstance.global_position = Position2DHandThrow.global_position
	ObjInstance.linear_velocity.y = vel_y
	ObjInstance.rotation_degrees = rot * Enemy.facing
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _spawn_gasfront() -> void :
	var ObjInstance = GasFront.instance()
	ObjInstance.dir = Enemy.facing
	ObjInstance.global_position = Position2DHandThrow.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
func _spawn_gascolumn() -> void :
	var position_spawn: Vector2 = global_position
	var ObjInstance = GasColumn.instance()
	position_spawn.x = VarsGlobal.Player.global_position.x
	ObjInstance.global_position = position_spawn
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _prepare_next_atk() -> void :
	if Enemy.state == "dead" or active == false:
		return
	
	var _next_atk: String = RNGTools.pick(attacks)
	
	attacks_done_count += 1
	
	
	if attacks_done_count == 4 and Enemy.state != "walk":
		_next_atk = "walk"
		attacks_done_count = 0
	
	elif Enemy.state == "walk" or Enemy.get_player_distance() > 100:
		_next_atk = RNGTools.pick(["throw", "gascolumn"])

	
	Enemy.change_direction("to_player")
	Enemy.change_state(_next_atk, false)

func _on_EnemyBase_state_changed(state) -> void :
	
	if state in ["idle", "walk"]:
		Audio.stop_sfx("ec_charging_enemy")
		TimerNewAtk.start(2)
	elif state == "throw":
		TimerNewAtk.start(3)

	Enemy.change_direction("to_player")

func _on_TimerNewAtk_timeout() -> void :
	_prepare_next_atk()


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void :
	KnifeEva.visible = false


func _on_HurtboxEnemy_damaged() -> void :
	
	if $HurtboxEnemy.hp_now <= ($HurtboxEnemy.hp_max / 2):
		Audio.stop_sfx("ec_charging_enemy")
		VarsGlobal.GameInterface.get_node("%BossBar").hide_bar()
		KnifeEva.visible = false
		$Sprite / PreGas.emitting = false
		get_tree().call_group("eva_gas", "queue_free")
		Enemy.change_state("idle")
		yield(get_tree(), "idle_frame")
		$HurtboxEnemy.set_enabled_hurtbox(false)
		$Sprite.frame = 0
		active = false
		emit_signal("battle_ended")
		return
	
	
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")
	


func _on_Eva_tree_exiting() -> void :
	_stop_charge()
