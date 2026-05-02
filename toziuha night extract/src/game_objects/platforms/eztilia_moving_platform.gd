extends KinematicBody2D

export var speed: float = 200
export var direction: Vector2 = Vector2(0, 0)

func _physics_process(delta: float) -> void :
	var motion = direction.normalized() * (speed * 4) * delta
	
	move_and_slide(motion)
