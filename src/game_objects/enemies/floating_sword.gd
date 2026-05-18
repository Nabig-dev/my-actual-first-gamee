extends KinematicBody2D

signal defeated

export (int, 8, 11) var frame = 8
export var origin_pos: NodePath

var is_active: bool

var origin_following: bool = true
var targeting: bool
var moving: bool

var target_position: Vector2
var speed: float = 300
var velocity: Vector2

var _OriginPosition2D: Position2D

onready var Spr = $Sprite
onready var Spr2 = $Sprite / Sprite2
onready var Enemy = $EnemyBase
onready var TimerStartChase = $TimerStartChase
onready var GhostTrail = $GhostTrail

func _ready() -> void :
	Spr2.material = Spr2.material.duplicate()
	Spr2.material.set_shader_param("line_thickness", 0)
	Spr.rotation_degrees = 90
	Spr.frame = frame
	Spr2.frame = frame
	Enemy.change_state("fly")
	
	_OriginPosition2D = get_node(origin_pos)

func _physics_process(delta: float) -> void :
	
	if targeting == true:
		target_position = Enemy.get_player_position(Vector2(0, - 20))
		look_at_target()
	
	elif moving == true:
		if global_position.distance_to(target_position) < 10:
			moving = false
			_moved_to_target()

	if origin_following == true:
		if global_position.distance_to(_OriginPosition2D.global_position) < 10:
			global_position = _OriginPosition2D.global_position
		else:
			velocity = global_position.direction_to(_OriginPosition2D.global_position).normalized() * speed
	
	if Enemy.state == "dead":
		velocity.y += 200 * delta
	
	
	move_and_collide(velocity * delta)

func start_chase() -> void :
	if is_active == false and Enemy.state != "dead":
		Audio.play_sfx("floating_sword_prepared")
		Spr2.material.set_shader_param("line_thickness", 1)
		is_active = true
		targeting = true
		TimerStartChase.start(1.5)

func move_to_target() -> void :
	GhostTrail.start_trail()
	origin_following = false
	targeting = false
	velocity = global_position.direction_to(target_position).normalized() * speed
	moving = true
	Audio.play_sfx("woosh_attack")

func look_at_target() -> void :
	var angle = global_position.angle_to_point(target_position)
	Spr.rotation_degrees = rad2deg(angle)

func _moved_to_target() -> void :
	
	var Tw: SceneTreeTween = get_tree().create_tween()
	
	velocity = Vector2.ZERO

	
	Tw.tween_property(
		Spr, "rotation_degrees", Spr.rotation_degrees + 360.0, 1
	)
	yield(Tw, "finished")
	
	Tw = create_tween()

	
	Tw.tween_property(
		Spr, "rotation_degrees", 90, 0.5
	)

	origin_following = true
	is_active = false
	Spr2.material.set_shader_param("line_thickness", 0)
	
	yield(Tw, "finished")
	GhostTrail.stop_trail()

func _on_TimerStartChase_timeout() -> void :
	move_to_target()

func _on_HurtboxEnemy_defeated() -> void :
	Spr2.material.set_shader_param("line_thickness", 0)
	velocity = Vector2.ZERO
	TimerStartChase.stop()
	is_active = false
	origin_following = false
	targeting = false
	emit_signal("defeated")
