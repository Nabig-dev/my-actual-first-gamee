extends KinematicBody2D

var FloorAtk = preload("res://src/game_objects/enemies_weapons/golum_floor_atk.tscn")

var velocity: = Vector2()

var gravity: int = 250

var _now_floor_attacks: int
var _max_floor_attacks: int = 6

onready var Enemy = $EnemyBase
onready var TimerNewAttack = $TimerNewAttack
onready var RayCastDetectPlayer = $Sprite / RayCastDetectPlayer
onready var HitboxArm = $Sprite / HitboxArm
onready var PositionFloorAtk = $Sprite / PositionFloorAtk
onready var TimerSpawnFloorAtk = $TimerSpawnFloorAtk
onready var VisibNotif = $VisibilityNotifierCameraArea

func _ready() -> void :
	Enemy.change_state("idle", true)

func _physics_process(delta) -> void :
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP, true)

func _prepare_next_attack() -> void :
	if Enemy.state == "idle":
		randomize()
		var attacks: Array = ["attack_a", "attack_b", "idle"]
		
		if VisibNotif.is_on_screen() == false:
			attacks = ["idle"]
		elif Enemy.get_player_distance() <= 100:
			attacks.erase("idle")
		else:
			attacks.erase("attack_a")
		
		var _next_anim: String = RNGTools.pick(attacks)
		Enemy.change_state(_next_anim)

func _play_woosh() -> void :
	Audio.play_sfx("woosh_whip_l")

func _spawn_floor_atk(reset: bool) -> void :
	if reset == true:
		PositionFloorAtk.position.x = 40
		_now_floor_attacks = 0
		
		VarsGlobal.GameScenario.CameraNode.start_shake(0.6, true, false)
		Gamepad.start_vibration(0, 0.8, 0.8, 0.5)
	
	
	if _now_floor_attacks == _max_floor_attacks:
		_now_floor_attacks = 0
		TimerSpawnFloorAtk.stop()
		return
	
	var floor_atk_instance = FloorAtk.instance()
	floor_atk_instance.connect(
		"stoped", self, "_on_FloorAtk_stoped"
	)
	floor_atk_instance.scale.x = Enemy.facing
	floor_atk_instance.global_position = PositionFloorAtk.global_position
	VarsGlobal.GameScenario.add_child(floor_atk_instance)
	
	PositionFloorAtk.position.x += 32
	_now_floor_attacks += 1

func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state == "idle":
		Enemy.change_direction("to_player")
		_prepare_next_attack()

func _on_HurtboxEnemy_defeated() -> void :
	HitboxArm.set_deferred("monitorable", false)
	TimerNewAttack.stop()
	TimerSpawnFloorAtk.stop()

func _on_TimerSpawnFloorAtk_timeout() -> void :
	_spawn_floor_atk(false)

func _on_EnemyBase_state_changed(state: String) -> void :
	if state == "idle":
		TimerNewAttack.start()

func _on_TimerNewAttack_timeout() -> void :
	_prepare_next_attack()

func _on_FloorAtk_stoped() -> void :
	_now_floor_attacks = _max_floor_attacks
