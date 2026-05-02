extends RigidBody2D


var Rock = preload("res://src/game_objects/enemies_weapons/rock_ogre.tscn")

onready var Enemy = $EnemyBase
onready var VisibleNotif = $VisibilityNotifierCameraArea

func _ready() -> void :
	Enemy.change_state("idle", true)

func throw() -> void :
	Audio.play_sfx("woosh_throw")
	var ObjInstance = Rock.instance()
	ObjInstance.global_position = $OgreRock / PositionRockThrow.global_position
	ObjInstance.dir = Enemy.facing
	ObjInstance.target_position = VarsGlobal.Player.global_position - Vector2(0, 30)
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _on_TimerThrow_timeout() -> void :
	if Enemy.state == "idle" and VisibleNotif.is_on_screen():
		Enemy.change_direction("to_player")
		Enemy.change_state("throw")
	randomize()
	$TimerThrow.start(rand_range(1, 1.5))

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void :
	if anim_name == "recover":
		_on_TimerThrow_timeout()
