extends Node2D

onready var SphaeraA = $Spin / Sphaera1
onready var SphaeraB = $Spin / Sphaera2

var dir: int = 1

var _speed: float = 50

func _ready() -> void :

	if dir == - 1:
		$AnimationPlayer.play("spin")
	else:
		$AnimationPlayer.play_backwards("spin")

	$AnimationPlayer2.play("sphaera")
	Audio.play_sfx("electric_zap2")
	Audio.play_sfx("pre_thunder")

func _process(delta: float) -> void :
	position.x += dir * ((_speed * 3) * delta)
	position.y -= ((_speed / 1.5) * delta)
	SphaeraA.position.y += ((_speed * 2) * delta)
	SphaeraB.position.y -= ((_speed * 2) * delta)
	_speed += 0.2
