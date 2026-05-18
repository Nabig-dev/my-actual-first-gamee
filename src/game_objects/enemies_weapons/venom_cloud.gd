extends KinematicBody2D

var velocity: = Vector2()

var gravity: int = 50
var speed: float = 1000
var time_active: float = 5
var dir: int = 1

func _ready() -> void :
	$TimerActive.start(time_active)
	Audio.play_sfx("gas_release")
	$CPUParticles2D.emitting = true
	$HitboxEnemy / CollisionShape2D.disabled = true
	
	if global_position.x > VarsGlobal.Player.global_position.x:
		dir = - 1
	else:
		dir = 1

func _physics_process(delta) -> void :
	velocity.y += gravity * delta
	velocity.x = (dir * speed) * delta
	velocity = move_and_slide_with_snap(
		velocity, Vector2.DOWN * 8, Vector2.UP, true
	)

func _on_TimerStart_timeout() -> void :
	$HitboxEnemy / CollisionShape2D.disabled = false
	$HurtboxEnemySimple / CollisionShape2D.disabled = false

func _on_TimerActive_timeout() -> void :
	$HitboxEnemy / CollisionShape2D.set_deferred("disabled", true)
	$HurtboxEnemySimple / CollisionShape2D.set_deferred("disabled", true)
	$CPUParticles2D.emitting = false
	$TimerEnd.start(3)

func _on_TimerEnd_timeout() -> void :
	queue_free()

func _on_HurtboxEnemySimple_defeated() -> void :
	_on_TimerActive_timeout()
