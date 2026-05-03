extends Node2D

onready var SphaeraA = $Spin / Sphaera1
onready var SphaeraB = $Spin / Sphaera2

var _speed: float = 10

func _ready() -> void :
	$AnimationPlayer.play("spin")
	$AnimationPlayer2.play("sphaera")

func _process(delta: float) -> void :
	SphaeraA.position.y += _speed * delta
	SphaeraB.position.y -= _speed * delta
	_speed += 0.5
