extends Position2D

onready var Lbl = $Label
onready var AnimPlayer = $AnimationPlayer
onready var AnimCritic = $AnimCritic
onready var Tw = $Tween



func show_number(
	numb: int = 0, glob_pos: Vector2 = Vector2.ZERO, 
	font: String = "normal", 
	critic: bool = false
) -> void :
	
	global_position = glob_pos
	
	global_position.x += RNGTools.randi_range( - 12, 12)
	
	match font:
		"red":
			Lbl.self_modulate = Color.pink
		"green":
			Lbl.self_modulate = Color.green
		"blue":
			Lbl.self_modulate = Color.aqua

	Lbl.text = str(numb)
	
	
	if critic == true and numb > 0:
		AnimCritic.play("critic")
		
	else:
		Lbl.rect_scale = Vector2(1, 1)
	
	
	
	if font in ["green"]:
		Lbl.text = "+" + Lbl.text

	AnimPlayer.play("show")
	
	var end_global_pos = global_position
	end_global_pos.y -= 25
	
	Tw.interpolate_property(
		self, "global_position", 
		global_position, end_global_pos, 3, 
		Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	Tw.start()


