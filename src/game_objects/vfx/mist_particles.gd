extends CPUParticles2D

export var auto_follow_player: bool = true

var follow_player: bool = false

func _ready() -> void :
	emitting = true

func _process(_delta: float) -> void :
	if follow_player == true:
		global_position = VarsGlobal.Player.global_position + Vector2(0, - 150)

func _on_Timer_timeout() -> void :
	if auto_follow_player == true:
		follow_player = true
