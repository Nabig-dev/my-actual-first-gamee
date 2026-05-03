extends Node2D

export var time_to_start: float = 1
export var time_active: float = 4

onready var Enemy = $EnemyBase
onready var VisibleNotif = $VisibilityNotifier2D

func _ready() -> void :
	$Timer.start(time_to_start)
	Enemy.change_state("inactive")
	
	for n in ["_Body2", "_Body3", "_Body4", "_Body5"]:
		get_node("Worm/" + n + "/GiantWorm").material = $Worm / _Head.material
	$Worm / _Head / _GiantWormParts6.material = $Worm / _Head.material
	$Worm / _Head / GiantWorm.material = $Worm / _Head.material

func _on_start_show() -> void :
	if Enemy.state == "dead" or VisibleNotif.is_on_screen() == false:
		return
	Audio.play_sfx("impact_wall")
	Audio.play_sfx("impact_mineral")

func _on_appear_anim_end() -> void :
	if Enemy.state == "dead":
		return
	Enemy.change_state("show")

func _on_Timer_timeout() -> void :
	if Enemy.state == "dead":
		return
	if VisibleNotif.is_on_screen() == true:
		Audio.play_sfx("worm_rumble")
	Enemy.change_state("appear")
	yield($AnimationPlayer, "animation_finished")
	$TimerActive.start(time_active)


func _on_TimerActive_timeout() -> void :
	if Enemy.state == "dead":
		return
	if VisibleNotif.is_on_screen() == true:
		Audio.play_sfx("impact_mineral3")
	Enemy.change_state("hide")
	yield($AnimationPlayer, "animation_finished")
	Enemy.change_state("inactive")
	$Timer.start(time_to_start)


func _on_HurtboxEnemy_defeated() -> void :
	$Timer.stop()
	$TimerActive.stop()
