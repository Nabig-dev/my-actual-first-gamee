extends Control

export var time: float = 1

onready var TimerNode = $Timer
onready var Anim = $AnimationPlayer

func _ready() -> void :
	Anim.play("flash")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void :
	if anim_name == "flash":
		TimerNode.start(time)
		yield(TimerNode, "timeout")
		Anim.play("flash-out")
