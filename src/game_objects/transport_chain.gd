extends Line2D

export var TargetPosition: NodePath

var _target: Position2D = null

func _ready() -> void :
	if (
		TargetPosition.is_empty() == false
		and get_node(TargetPosition) is Position2D
	):
		_target = get_node(TargetPosition)

func _process(_delta: float) -> void :
	if _target != null and points.empty() == false:
		points[0] = _target.global_position
