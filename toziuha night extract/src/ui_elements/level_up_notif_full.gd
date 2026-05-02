extends CanvasLayer

var paused_game: bool
var can_pause: bool
var can_move: bool

func _ready() -> void :
	
	can_pause = VarsGlobal.GameInterface.can_pause
	can_move = VarsGlobal.Player.enabled_input
	
	if Engine.time_scale == 1.0:
		paused_game = get_tree().is_paused()
		get_tree().set_pause(true)
		
		
	
	$AnimationPlayer.play("show")

func play_snd() -> void :
	Audio.play_sfx("ui_levelup2")

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void :
	
	
	get_tree().set_pause(paused_game)
	queue_free()
