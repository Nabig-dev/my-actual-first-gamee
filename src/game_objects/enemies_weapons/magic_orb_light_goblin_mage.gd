extends KinematicBody2D

var dir: int = 1
var target_position: Vector2
var speed: float = 50
var velocity: Vector2

func _ready() -> void :
	
	target_position = VarsGlobal.Player.global_position
	target_position.y -= 20
	velocity = position.direction_to(target_position).normalized() * speed
	
	$AnimationPlayer.play("start")

	$GhostTrail.start_trail(0, 0.1)
	$GhostTrail2.start_trail(0, 0.1)

	var Tw: = create_tween().set_loops()
	
	
	Tw.tween_property(self, "rotation_degrees", 360 * dir, 3).from_current()
	
	Tw = create_tween()
	
	Tw.tween_property(
		$Orb1, "position:x", - 100, 2
	)
	
	Tw = create_tween()
	
	Tw.tween_property(
		$Orb2, "position:x", 100, 2
	)
	
	Tw = create_tween()
	
	Tw.tween_property(
		$Orb1 / Flare, "scale", Vector2(1.2, 1.2), 1
	)
	
	Tw = create_tween()
	
	Tw.tween_property(
		$Orb2 / Flare, "scale", Vector2(1.2, 1.2), 1
	)

func _physics_process(delta: float):
	
	move_and_collide(velocity * delta)

func _on_Orb1_frame_changed() -> void :
	$Orb2.frame = $Orb1.frame

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void :
	if anim_name == "start":
		$AnimationPlayer.play("loop")

func _on_TimerActive_timeout() -> void :
	
	var Tw = create_tween()
	
	
	Tw.tween_property(
		$Orb1 / Flare, "scale", Vector2(0, 0), 1
	)
	
	Tw = create_tween()
	
	Tw.tween_property(
		$Orb2 / Flare, "scale", Vector2(0, 0), 1
	)
	
	$AnimationPlayer.play("end")
