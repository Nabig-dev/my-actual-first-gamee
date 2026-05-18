extends KinematicBody2D

export var limit_l_position: NodePath
export var limit_r_position: NodePath

export var speed: int = 400
var velocity: = Vector2()

var _limit_l: Vector2
var _limit_r: Vector2

var _can_run: bool = false

onready var SpriteOriginal = $Sprite
onready var SpriteCopy = $Sprite / Sprite2
onready var Enemy = $EnemyBase
onready var VisibNotif = $VisibilityNotifier2D
onready var TimerChangedirCooldown = $TimerChangedirCooldown

func _ready() -> void :
	
	if (
		get_node_or_null(limit_l_position) != null
		and get_node_or_null(limit_r_position) != null
	):
		_limit_l = get_node(limit_l_position).global_position
		_limit_r = get_node(limit_r_position).global_position
		_can_run = true
	
	if _can_run == true:
		Enemy.change_state("idle", true)
		$GhostTrail.start_trail(0, 0.1)
		TimerChangedirCooldown.start()
		yield(TimerChangedirCooldown, "timeout")
		Enemy.change_state("run", true)
	else:
		Enemy.change_state("idle", true)

func change_dir() -> void :
	if Enemy.state == "run":
		speed = lerp(speed, 0, 0.3)
		Enemy.change_state("changedir")
		if VisibNotif.is_on_screen() == true:
			Audio.play_sfx("horse_snore")
		Audio.stop_sfx("ghost_galloping")
	

func _physics_process(_delta: float) -> void :
	
	if Enemy.state in ["run", "dead"]:
	
		velocity.x = speed * Enemy.facing
		
		if (
			(Enemy.facing == - 1 and global_position.x <= _limit_l.x)
			or (Enemy.facing == 1 and global_position.x >= _limit_r.x)
			and TimerChangedirCooldown.is_stopped() == true
		):
			TimerChangedirCooldown.start()
			change_dir()

	velocity = move_and_slide(velocity, Vector2.UP, true)

func _galloping_snd() -> void :
	
	Audio.play_sfx("ghost_galloping")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void :
	if anim_name == "changedir":
		Enemy.change_direction("inverse")
		Enemy.change_state("run")

func _on_AnimationPlayer_animation_started(anim_name: String) -> void :
	if anim_name == "run":
		speed = lerp(speed, 400, 0.3)

func _on_Sprite_frame_changed() -> void :
	SpriteCopy.frame = SpriteOriginal.frame

func _on_EnemyBase_enemy_defeated(_NodeEnemy) -> void :
	speed = 100
	Audio.stop_sfx("horse_snore")
	Audio.stop_sfx("ghost_galloping")

func _on_VisibilityNotifier2D_screen_entered() -> void :

	pass
