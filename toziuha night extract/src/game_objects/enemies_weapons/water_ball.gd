extends KinematicBody2D

var speed: int = 30
var velocity: Vector2

var offsetpos_y: float = 0
var offsetpos_x: float = 0

var _destroyed: bool

func _ready() -> void :
	Audio.play_sfx("light_flash2")
	$AnimationPlayer.play("show")

func _physics_process(_delta: float) -> void :
		
	
	velocity = Vector2.ZERO
	
	velocity = global_position.direction_to(
		VarsGlobal.Player.global_position + Vector2(0, - 45) + Vector2(offsetpos_x, offsetpos_y)
	) * speed
	
	velocity = move_and_slide(velocity)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void :
	if anim_name == "show":
		if _destroyed == false:
			$AnimationPlayer.play("fly")
		else:
			queue_free()

func _on_HurtboxEnemySimple_defeated() -> void :
	if _destroyed == true:
		return
	_destroyed = true
	set_physics_process(false)
	$AnimationPlayer.play_backwards("show")



func _on_TimerChangeSpeed_timeout() -> void :
	
	var tween_to: float = 0
	
	if speed >= 100:
		tween_to = 0
	else:
		tween_to = 100
	
	create_tween().tween_property(
		self, "speed", tween_to, $TimerChangeSpeed.wait_time
	)


func _on_HurtboxEnemySimple_damaged() -> void :
	velocity = Vector2.ZERO


func _on_HitboxEnemy_area_entered(_area):
	if _destroyed == true:
		return
	yield($TimerAutoQueue, "timeout")
	_on_HurtboxEnemySimple_defeated()


func _on_Area2DDetectPlayer_area_entered(_area: Area2D) -> void :
	_on_HurtboxEnemySimple_defeated()
