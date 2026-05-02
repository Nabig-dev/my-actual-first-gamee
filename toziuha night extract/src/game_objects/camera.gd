extends Camera2D







signal camera_positioned_on_player

signal tweened_to_position
signal tweened_to_player

export var offset_position: = Vector2(0, 0)


var decay: = 0.8

var max_offset = Vector2(100, 75)

var max_roll: = 0.1

var trauma: = 0.0

var trauma_power: = 2

var _noise_y: = 0

var _shake_enabled: bool = false


var _auto_moving: bool

onready var Noise = OpenSimplexNoise.new()

onready var TweenMoveOffsetRJoy = $TweenMoveOffsetRJoy

export var follow_player: = false

func _ready() -> void :
	randomize()
	Noise.seed = randi()
	Noise.period = 4
	Noise.octaves = 2
	
	_shake_enabled = Config.get_value("gameplay", "camera_shake", false)
	
	
	if follow_player == true and is_instance_valid(VarsGlobal.Player):
		global_position = VarsGlobal.Player.global_position - offset_position
		emit_signal("camera_positioned_on_player")

	reset_smoothing()

func _process(delta: float) -> void :
	
	if follow_player == true:
		global_position = (
			VarsGlobal.Player.global_position - offset_position
		)
	
		
		if Input.is_action_pressed("r_joy_up"):
			if offset_v > - 5:
				offset_v -= 0.1
		elif Input.is_action_pressed("r_joy_down"):
			if offset_v < 5:
				offset_v += 0.1

	
	if (
		Input.is_action_just_released("r_joy_up")
		or Input.is_action_just_released("r_joy_down")
	):
		offset_v = 0

	if trauma:
		trauma = max(trauma - decay * delta, 0)
		_shake()

func get_center_limits() -> Vector2:
	
	var center_x: int = (limit_left + limit_right) / 2
	
	var center_y: int = (limit_top + limit_bottom) / 2
	return Vector2(center_x, center_y)


func get_limit_l() -> float:
	var limit: float = global_position.x - 150
	if limit < limit_left:
		limit = limit_left + 10
	return limit
func get_limit_r() -> float:
	var limit: float = global_position.x + 150
	if limit > limit_right:
		limit = limit_right - 10
	return limit



func set_limits(camera_limiter: ColorRect) -> void :
	var left_top: = camera_limiter.get_begin()
	var right_bottom: = camera_limiter.get_end()
	
	limit_left = int(left_top.x)
	limit_top = int(left_top.y)
	limit_right = int(right_bottom.x)
	limit_bottom = int(right_bottom.y)


func move_to(pos: Vector2, duration: float = 1.0) -> void :
	var Tw: = get_tree().create_tween()
	
	follow_player = false
	
	Tw.tween_property(
		self, "global_position", pos, duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	
	offset_v = 0
	Input.action_release("r_joy_up")
	Input.action_release("r_joy_down")
	
	yield(Tw, "finished")
	emit_signal("tweened_to_position")


func return_to_player(duration: float = 1.0) -> void :
	var Tw: = get_tree().create_tween()
	var pos: Vector2 = VarsGlobal.Player.global_position
	
	
	Tw.tween_property(
		self, "global_position", pos, duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	yield(Tw, "finished")
	follow_player = true
	emit_signal("tweened_to_player")





func start_shake(
	amount: float = 1.0, add_trauma: bool = false, 
	ignore_shake_conf: bool = false, 
	reset_trauma: bool = true
) -> void :
	
	
	if (
		(trauma != 0.0 and add_trauma == false)
		or (_shake_enabled == false and ignore_shake_conf == false)
	):
		return
		
	if reset_trauma:
		trauma = 0.0
		offset = Vector2.ZERO
	
	
	trauma = min(trauma + amount, 1.0)

func _shake() -> void :
	var amount = pow(trauma, trauma_power)
	_noise_y += 1
	rotation = max_roll * amount * Noise.get_noise_2d(Noise.seed, _noise_y)
	offset.x = max_offset.x * amount * Noise.get_noise_2d(Noise.seed * 2, _noise_y)
	offset.y = max_offset.y * amount * Noise.get_noise_2d(Noise.seed * 3, _noise_y)
