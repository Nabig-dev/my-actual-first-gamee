extends PanelContainer

signal text_ended

onready var TimerToHide = $TimerToHide
onready var TimerLetter = $TimerInBetweenLetter
onready var Lbl = $Label

var text: String = "Sodales facilisis inceptos eget vestibulum"

func _ready() -> void :
	
	modulate = Color("00ffffff")
	rect_size = Vector2(32, 18)
	
	var Tw = get_tree().create_tween()
	Tw.tween_property(
		self, "modulate", Color("ffffff"), 0.3
	)

	for l in text:
		Lbl.text = Lbl.text + l
		TimerLetter.start(0.04)
		
		if rect_size.x > 110:
			Lbl.rect_min_size.x = 115
			Lbl.autowrap = true
		yield(TimerLetter, "timeout")
	
	
	var time_to_hide: float = 3.0
	time_to_hide = Lbl.text.length() / 8
	if time_to_hide < 3.0:
		time_to_hide = 3.0
	TimerToHide.start(time_to_hide)
	yield(TimerToHide, "timeout")
	
	var Tw2 = get_tree().create_tween()
	Tw2.tween_property(
		self, "modulate", Color("00ffffff"), 0.5
	)
	
	yield(Tw2, "finished")
	
	emit_signal("text_ended")
	
	queue_free()
