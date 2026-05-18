extends KinematicBody2D

var velocity: = Vector2()

var gravity: int = 20

func _ready() -> void :
	Audio.play_sfx("impact_mineral3")
	randomize()
	$Rocks.frame = randi() % 4
	$AnimationPlayer.play("spin")

func _physics_process(delta) -> void :
	
	velocity.y += gravity * delta
	
	velocity = move_and_slide(velocity, Vector2.UP, true)

func _on_TimerAddGravity_timeout() -> void :
	gravity += 15

func _on_Timer_timeout() -> void :
	queue_free()

func _on_HurtboxEnemySimple_defeated() -> void :
	queue_free()
