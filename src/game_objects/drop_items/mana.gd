extends KinematicBody2D

export var mana_double: bool = false

var speed: int = 200

var velocity: = Vector2.ZERO

var _follow_player: bool = false

var _mana_count: int = 8

onready var AnimSprite = $AnimatedSprite

onready var TimerStartFollow = $TimerStartFollow
onready var TimerFree = $TimerFree
onready var TimerFree2 = $TimerFree2

onready var MParticles = $Particles
onready var MParticles2 = $Particles2
onready var MParticlesEnd1 = $ParticlesEnd1
onready var MParticlesEnd2 = $ParticlesEnd2

onready var ShineBlue = $AnimatedSprite / ShineBlue
onready var ShineCyan = $AnimatedSprite / ShineCyan

func _ready() -> void :

	TimerStartFollow.start(0.6)
	
	velocity.y = - 150
	
	TimerFree.start()
	
	if mana_double:
		
		AnimSprite.animation = "cyan"
		_mana_count = _mana_count * 2
		MParticles2.emitting = true
		
		ShineBlue.visible = false
	
	else:
		
		MParticles.emitting = true
		
		ShineCyan.visible = false

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
	MParticles2.emitting = false
	if _follow_player:
		if mana_double:
			MParticlesEnd2.emitting = true
		else:
			MParticlesEnd1.emitting = true
		TimerFree2.start(2)
		yield(TimerFree2, "timeout")
	queue_free()

func _on_AreaAbsorbPlayer_area_entered(_area: Area2D) -> void :

	_follow_player = true
	AnimSprite.visible = false
	
	if mana_double:
		Audio.play_sfx("mana_absorb_x5")
		Gamepad.start_vibration(0, 0.4, 0.4, 0.3)
	else:
		Audio.play_sfx("mana_absorb")
		Gamepad.start_vibration(0, 0.2, 0.1, 0.3)

	
	VarsGlobal.game_data["player_mp_now"] = int(FuncsNumbers.add_value(
		_mana_count, VarsGlobal.game_data["player_mp_now"], VarsGlobal.game_data["player_mp_max"]
	))
	
	VarsGlobal.GameInterface.update_hud_values()
	
	TimerFree.stop()
	_on_TimerFree_timeout()

func _on_TimerStartFollow_timeout() -> void :
	TimerFree.stop()
	_follow_player = true
