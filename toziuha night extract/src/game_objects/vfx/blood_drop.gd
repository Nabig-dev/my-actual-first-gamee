extends CPUParticles2D

onready var TimerFree = $TimerFree

func _ready() -> void :
	emitting = true

func _on_Timer_timeout() -> void :
	emitting = false
	TimerFree.start()
	yield(TimerFree, "timeout")
	queue_free()
