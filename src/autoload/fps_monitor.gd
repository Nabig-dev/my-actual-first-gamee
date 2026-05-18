extends Control

var times: = []

var fps: = 0

onready var DbgLbl = $Label

func _ready() -> void :
	enable_monitor(false)

func _process(_delta: float) -> void :
	var now: = OS.get_ticks_msec()

	
	while times.size() > 0 and times[0] <= now - 1000:
		times.pop_front()

	times.append(now)
	fps = times.size()

	
	DbgLbl.text = str(fps).pad_zeros(1)

func enable_monitor(val: bool = true) -> void :
	visible = val
	set_process(val)
