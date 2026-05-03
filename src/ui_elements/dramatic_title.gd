extends Control

signal started

signal ended

onready var Lbl = $Label
onready var Lbl2 = $Label2
onready var Anim = $AnimationPlayer

func _ready() -> void :
	Lbl.text = ""
	Lbl2.text = ""
	Lbl.modulate.a = 0
	Lbl2.modulate.a = 0

func show_title(title: String) -> void :
	emit_signal("started")
	
	Audio.play_sfx("cinematic_hit_reverse")
	Anim.play("show")
	Lbl.text = title
	Lbl2.text = title
	Lbl2.rect_pivot_offset = Lbl2.rect_size / 2
	

func play_hit_sfx() -> void :
	Audio.play_sfx("axe_hit_blood")

func vibration_hit() -> void :
	Gamepad.start_vibration(0, 1.0, 1.0, 0.5)
