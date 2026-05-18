extends RigidBody2D

var FireBall = preload("res://src/game_objects/enemies_weapons/simple_fireball.tscn")

onready var Enemy = $EnemyBase
onready var PosFireball = $Vyrlith / PosFireball
onready var TimerNextMove = $TimerNextMove
onready var VisibNotif = $VisibilityNotifier2D

var _hits_received: int

func _ready() -> void :
	Enemy.change_state("idle", true)

func spawn_fireball(angle_variation: float = 0) -> void :
	randomize()
	var ObjInstance = FireBall.instance()
	ObjInstance.dir = Enemy.facing
	if angle_variation != 0:
		ObjInstance.angle_degrees = angle_variation
	else:
		ObjInstance.angle_degrees = rand_range( - 10, 10)
	ObjInstance.global_position = PosFireball.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	Audio.play_sfx("spell_shoot4")

func _teleport() -> void :
	if Enemy.state != "teleport":
		return
	global_position = Enemy.get_player_position()

func _snd_teleportstart() -> void :
	Audio.play_sfx("spell_prepare3")

func _on_teleport_end() -> void :
	_on_TimerNextMove_timeout()

func _on_EnemyBase_state_changed(_state: String) -> void :

	pass

func _on_TimerNextMove_timeout() -> void :
	var states: Array = [
		"fireball", "fireball", "teleport", "firewall"
	]
	var next_state: String = RNGTools.pick(states)
	if Enemy.prev_state == "teleport":
		states.erase("teleport")
	randomize()
	if VisibNotif.is_on_screen() == true and Enemy.state != next_state and Enemy.state != "teleport":
		Enemy.change_direction("to_player")
		Enemy.change_state(next_state)
	else:
		TimerNextMove.start(0.5)
	randomize()
	TimerNextMove.start(rand_range(3, 5))

func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state in ["idle"]:
		Enemy.change_direction("to_player")
	_hits_received += 1
	if _hits_received == 3:
		_hits_received = 0
		if Enemy.state == "idle":
			Enemy.change_state("teleport")
	

func _on_TimerCheckFreezeState_timeout() -> void :
	if $AnimationPlayer.is_playing() == false:
		Enemy.change_state("idle", true)
		_on_TimerNextMove_timeout()
