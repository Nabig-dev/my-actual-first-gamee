extends Node2D

onready var Anim = $AnimationPlayer

func _ready() -> void :
	$Caloris.play("default")
	Anim.play("show")

func _on_TimerActive_timeout() -> void :
	Anim.play("hide")
