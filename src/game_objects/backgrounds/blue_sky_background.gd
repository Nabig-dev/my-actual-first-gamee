extends ParallaxBackground

export var speed: int = 3
export var dir: int = 1

var motion: Vector2

var hour: int = 12
var dayphase: String

onready var Lay1 = $ParallaxLayer
onready var Lay2 = $ParallaxLayer2
onready var Lay3 = $ParallaxLayer3

func _process(delta: float) -> void :
	
	motion = Vector2( - speed, 0)
	motion *= delta
	
	Lay1.motion_offset += motion * dir / Vector2(50, 50)
	Lay2.motion_offset += motion * dir / Vector2(5, 5)
	Lay3.motion_offset += motion * dir
