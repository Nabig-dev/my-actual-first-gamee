extends RigidBody2D

var Projectile = preload("res://src/game_objects/enemies_weapons/thalgrimm_projectile.tscn")

onready var Enemy = $EnemyBase
onready var TimerAtk = $TimerAtk
onready var Visibility = $VisibilityNotifierCameraArea

func _ready() -> void :
	Enemy.change_state("idle", true)

func spawn_magic() -> void :
	Audio.play_sfx("spell_shoot")
	var ObjInstance = Projectile.instance()
	ObjInstance.dir = Enemy.facing
	ObjInstance.global_position = $Thalgrimm / Projectile.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func prepare_snd() -> void :
	Audio.play_sfx("spell_prepare")

func _on_EnemyBase_state_changed(state) -> void :
	if state == "idle":
		randomize()
		TimerAtk.start(
			rand_range(1.5, 2)
		)

func _on_TimerAtk_timeout() -> void :
	
	if Enemy.state == "dead":
		return
	
	if Visibility.is_on_screen() == true:
		Enemy.change_direction("to_player")
		Enemy.change_state("attack")
	else:
		TimerAtk.start(1)
