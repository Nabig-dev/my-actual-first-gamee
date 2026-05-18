extends RigidBody2D

var Explosion = preload("res://src/game_objects/enemies_weapons/bomb_a_explosion.tscn")

onready var Anim = $AnimationPlayer
onready var TimerPreExplode = $TimerPreExplode
onready var HurtBox = $HurtboxEnemySimple

export var dir: int = 0

var speed: float = 100

var _clang_sound: int

var _explosion_started: bool = false

func _ready() -> void :
	if dir != 0:
		mode = RigidBody2D.MODE_RIGID
		linear_velocity = Vector2(dir * speed, 0)
		$AnimationPlayer.stop()

func play_bip() -> void :
	Audio.play_sfx("bomb_bip")

func _on_TimerPreExplode_timeout() -> void :
	if _explosion_started == true:
		return
	_explosion_started = true
	var Expl = Explosion.instance()
	Expl.global_position = global_position
	VarsGlobal.GameScenario.call_deferred("add_child", Expl)
	
	queue_free()

func _on_HurtboxEnemySimple_defeated() -> void :

	
	create_tween().tween_property(Anim, "playback_speed", 5.0, 3)
	
	TimerPreExplode.start(3)
	Anim.play("pre_explode")

func _on_Area2DDetectPlayer_area_entered(_area: Area2D) -> void :
	if Anim.current_animation != "pre_explode":
		_on_HurtboxEnemySimple_defeated()
		HurtBox.queue_free()

func _on_BombA_body_shape_entered(_body_rid: RID, _body: Node, _body_shape_index: int, _local_shape_index: int) -> void :
	
	if _clang_sound > 3 or mode == RigidBody2D.MODE_STATIC:
		disconnect("body_shape_entered", self, "_on_BombA_body_shape_entered")
		return
	
	if Audio.sfx_is_playing("impact_shield_clang") == false:
		Audio.play_sfx("impact_shield_clang")
		_clang_sound += 1

func _on_Area2DDetectPlayerNear_area_entered(_area: Area2D) -> void :
	$TimerPreExplode.stop()
	_on_TimerPreExplode_timeout()
	queue_free()
