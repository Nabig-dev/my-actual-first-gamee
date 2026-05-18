extends Position2D


export var pendulum: NodePath


export var cooldown_node: NodePath

export var max_length: float = 24.0
export var min_length: float = 12.5
export var kick_impulse: float = 0.02
export var gravity: float = 6.0

export var damping: float = 0.995


var PendulumNode: Object = null

var CoolDown: Object = null

var arm_length: float


var angle: float

var angular_velocity: float = 0.0
var angular_acceleration: float = 0.0


var _pivot_point: = Vector2()


var _end_position: = Vector2()

var _active: bool = false

func _ready() -> void :
	
	if pendulum.is_empty() == false:
		PendulumNode = get_node(pendulum)
		_end_position = PendulumNode.global_position
	
	
	if cooldown_node.is_empty() == false:
		CoolDown = get_node(cooldown_node)
	
	
	set_start_position(_end_position)

func set_active_pendulum(val: bool) -> void :
	_active = val
	if _active and PendulumNode != null:
		set_start_position(PendulumNode.global_position)

func set_start_position(
	end_pos: Vector2, custom_length: float = 0, 
	calculate: bool = true
):
	
	_pivot_point = global_position
	_end_position = end_pos

	if custom_length == 0:
		arm_length = Vector2.ZERO.distance_to(_end_position - _pivot_point)
	else:
		arm_length = custom_length
	
	
	if arm_length > max_length:
		arm_length = max_length
	elif arm_length < min_length:
		arm_length = min_length
	
	if calculate == false:
		return
	
	
	var angle_deg: float = rad2deg(
		_end_position.angle_to_point(_pivot_point)
	) - 90.0
	
	angle = Vector2.ZERO.angle_to(_end_position - _pivot_point) - deg2rad(angle_deg)
	angular_velocity = 0.0
	angular_acceleration = 0.0

func modify_length(val: float) -> void :
	set_start_position(_end_position, arm_length + val, false)

func process_velocity(delta: float) -> void :
	
	_pivot_point = global_position
	
	
	angular_acceleration = (( - gravity * delta) / arm_length) * sin(angle)
	
	
	angular_velocity += angular_acceleration
	
	angular_velocity *= damping
	
	
	angle += angular_velocity
	
	_end_position = _pivot_point + Vector2(arm_length * sin(angle), arm_length * cos(angle))
	
	if PendulumNode != null:
		PendulumNode.global_position = _end_position

func add_angular_velocity(force: float) -> void :
	angular_velocity += force

func _physics_process(delta) -> void :
	if _active == false:
		return
	process_velocity(delta)
	
	


func kick(dir: int = 0) -> void :
	
	if CoolDown != null:
		
		if CoolDown.is_stopped() == false:
			return
		CoolDown.start()
	
	add_angular_velocity(dir * kick_impulse)




