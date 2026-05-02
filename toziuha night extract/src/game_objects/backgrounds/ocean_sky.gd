extends ParallaxBackground

export var auto_dayphase_textures: bool = false
export var speed: int = 3
export var dir: int = 1

var motion: Vector2

var hour: int = 12
var dayphase: String

onready var CloudsA = $ParallaxLayer2
onready var CloudsB = $ParallaxLayer4

func _ready() -> void :
	
	hour = Time.get_time_dict_from_system()["hour"]

	if Config.get_value("video", "vfx_level", 1) < 2:
		$ParallaxLayer3 / Waves.visible = false
	
	if hour >= 0 and hour < 12:
		dayphase = "day"
	elif hour >= 12 and hour < 18:
		dayphase = "noon"
	else:
		dayphase = "night"
	
	if dayphase != "day" and auto_dayphase_textures == true:
		$ParallaxLayer / DayBack.texture = load(
			"res://assets/sprites/bg/ocean_sky/%s_back.png" % [dayphase]
		)
		for cl in get_tree().get_nodes_in_group("ocean_sky_clouds_sprites"):
			cl.texture = load(
				"res://assets/sprites/bg/ocean_sky/%s_clouds.png" % [dayphase]
			)
		for cl in get_tree().get_nodes_in_group("ocean_sky_middle_sprites"):
			cl.texture = load(
				"res://assets/sprites/bg/ocean_sky/%s_middle.png" % [dayphase]
			)

func _process(delta: float) -> void :
	
	motion = Vector2( - speed, 0)
	motion *= delta
	
	CloudsA.motion_offset += motion * dir
	CloudsB.motion_offset += motion * dir
