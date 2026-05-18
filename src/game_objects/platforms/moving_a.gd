extends Path2D



export (float, 0.1, 1) var playback_speed = 0.5

export var delay_start: float = 0.0

export var loop: bool = false

onready var AnimPlayer = $AnimationPlayer
onready var Path2DNode = $Path2D

func _ready() -> void :
	
	AnimPlayer.playback_speed = playback_speed
	
	Path2DNode.curve = curve
	
	if delay_start <= 0.0:
		_on_TimerDelay_timeout()
	else:
		$TimerDelay.start(delay_start)


func _on_TimerDelay_timeout() -> void :
	if curve != null:
		if loop:
			AnimPlayer.play("loop")
		else:
			AnimPlayer.play("ping_pong")
