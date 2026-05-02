extends Sprite

var _tw_duration: = 0.5
onready var Tw = $Tween
onready var TimerChangeFrame = $TimerChangeFrame

var SpriteOriginal: Sprite

func _ready() -> void :
	Tw.interpolate_property(
		self, "self_modulate", Color(1, 1, 1, 0.7), Color(1, 1, 1, 0), _tw_duration
	)
	Tw.start()

func _on_frame_changed() -> void :
	TimerChangeFrame.start(0.09)
	yield(TimerChangeFrame, "timeout")
	frame = SpriteOriginal.frame

func _on_Tween_tween_completed(_object: Object, _key: NodePath) -> void :
	call_deferred("queue_free")
