extends Node2D

export var falling_platform: bool = false
export var snow: bool = false

var player_entered: bool

func _ready() -> void :
	$SnowTile.visible = snow
	$ParticlesSnow.visible = snow
	
	
	if falling_platform == true:
		$PlatformRotation.modulate = Color("00ff46")

func start_anim() -> void :
	if (
		$AnimationPlayer.is_playing() == false
		and VarsGlobal.Player.global_position.y < global_position.y
	):
		if falling_platform == false:
			$AnimationPlayer.play("rotate")
		else:
			Audio.play_sfx("falling_platform")
			$AnimationPlayer.play("fall")

func _play_snd() -> void :
	Audio.play_sfx("platform_rotating")

func _on_AreaDetectPlayer_body_entered(_body: Node) -> void :
	player_entered = true
	start_anim()

func _on_AreaDetectPlayer_body_exited(_body: Node) -> void :
	player_entered = false


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void :
	if anim_name == "fall" and player_entered == true:
		start_anim()
