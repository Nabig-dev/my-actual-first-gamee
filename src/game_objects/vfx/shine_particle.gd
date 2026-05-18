extends CPUParticles2D

export var auto_delete: bool = true

func _ready() -> void :
	emitting = true

func _on_Timer_timeout() -> void :
	if auto_delete == true:
		queue_free()
