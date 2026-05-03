extends Node2D

var active: bool

var time_active: float = 5

var speed: float = 80.0

onready var FogParallax = $FogParallax

func _ready() -> void :
	$AnimationPlayer.play("pre-show")


func _physics_process(delta: float):
	FogParallax.dir = get_dir()
	if active == true:
		VarsGlobal.Player.global_position.x += (speed * get_dir()) * delta

func get_dir() -> int:
	if global_position.x > VarsGlobal.Player.global_position.x:
		return 1
	else:
		return - 1

func dissapear() -> void :
	Audio.stop_sfx("wind_strong")
	$TimerEnd.stop()
	active = false
	if is_in_group("tornado_v"):
		remove_from_group("tornado_v")
	$AnimationPlayer.play("dissapear")

func _show_anim_finished() -> void :
	$TimerEnd.start(time_active)

func _on_TimerEnd_timeout() -> void :
	dissapear()


func _on_AnimationPlayer_animation_started(anim_name: String) -> void :
	if anim_name == "show":
		Audio.play_sfx("wind_strong")
		active = true

func _on_TornadoVertical_tree_exiting() -> void :
	Audio.stop_sfx("wind_strong")
