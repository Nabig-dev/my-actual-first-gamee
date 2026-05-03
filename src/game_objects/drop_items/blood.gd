extends KinematicBody2D

var speed: int = 150

var velocity: = Vector2.ZERO

var _follow_player: bool = false

var blood: int = 5

onready var AnimSprite = $AnimatedSprite

onready var TimerStartFollow = $TimerStartFollow
onready var TimerFree = $TimerFree
onready var TimerFree2 = $TimerFree2

onready var MParticles = $CPUParticles2D
onready var MParticlesEnd1 = $CPUParticles2D2

func _ready() -> void :

	TimerStartFollow.start(1.0)
	
	velocity.y = - 200
	
	TimerFree.start()

func _physics_process(delta):
	
	if _follow_player and VarsGlobal.Player != null:
		
		velocity = Vector2.ZERO
		
		velocity = global_position.direction_to(
			_get_player_pos()
		) * speed
		speed += 10

	velocity.y += 375 * delta
	
	velocity = move_and_slide(velocity)
	
	

func _get_player_pos():
	var pos = VarsGlobal.Player.BodyNode.global_position
	return pos

func _on_TimerFree_timeout() -> void :
	MParticles.emitting = false
	if _follow_player:
		MParticlesEnd1.emitting = true
		TimerFree2.start(2)
		yield(TimerFree2, "timeout")
	queue_free()

func _on_AreaAbsorbPlayer_area_entered(_area: Area2D) -> void :

	_follow_player = true
	AnimSprite.visible = false
	
	Audio.play_sfx("blood_absorb")
	Gamepad.start_vibration(0, 0.2, 0.1, 0.3)

	
	VarsGlobal.game_data["player_bl_now"] = FuncsNumbers.add_value(
		blood, 
		VarsGlobal.game_data["player_bl_now"], 
		VarsGlobal.game_data["player_bl_max"]
	)
	
	VarsGlobal.GameInterface.update_hud_values()
	
	TimerFree.stop()
	_on_TimerFree_timeout()

func _on_TimerStartFollow_timeout() -> void :
	TimerFree.stop()
	_follow_player = true
