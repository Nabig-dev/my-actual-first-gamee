tool 

extends ParallaxBackground

export var editor_enabled: bool = true setget _set_visible

onready var Fire1 = $ParallaxFire / Fire1
onready var Fire1B = $ParallaxFire / Fire1B
onready var Fire1C = $ParallaxFire / Fire1C
onready var Fire2 = $ParallaxFire / Fire2
onready var Fire2B = $ParallaxFire / Fire2B
onready var FireGif = $ParallaxFire / FireGif
onready var Waves = $ParallaxFire / Waves

var _vfx_val: int

func _ready() -> void :
	
	if Engine.is_editor_hint():
		return
	
	_vfx_val = Config.get_value("video", "vfx_level", 1)
	
	FireGif.playing = false
	
	
	if _vfx_val == 1:
		Fire1C.material = null
		Fire1C.visible = false
		Fire2B.material = null
		Fire2B.visible = false
	
	
	elif _vfx_val == 0:
		_disable_firewaves()
		FireGif.playing = true
		FireGif.visible = true
	
	_set_visible(true)

func disable_all() -> void :
	_disable_firewaves()
	_set_visible(false)

func _set_visible(vis: bool) -> void :
	editor_enabled = vis
	$ParallaxFire.visible = vis

func _disable_firewaves() -> void :
	Fire1.material = null
	Fire1.visible = false
	Fire1B.material = null
	Fire1B.visible = false
	Fire1C.material = null
	Fire1C.visible = false
	Fire2.material = null
	Fire2.visible = false
	Fire2B.material = null
	Fire2B.visible = false
	Waves.material = null
	Waves.visible = false
