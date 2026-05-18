extends Control

signal animation_started
signal animation_ended

onready var Lbl = $Label
onready var Lbl2 = $Label2
onready var Anim = $AnimationPlayer

var _play_with_shader: bool = true

func show_title(txt: String) -> void :
	var text_show: = "- %s -" % [txt]
	if _play_with_shader == true:
		Anim.play("show")
	else:
		Anim.play("show_noshader")
	emit_signal("animation_started")
	Lbl.text = text_show
	Lbl2.text = text_show
	Lbl.rect_pivot_offset = Lbl.rect_size / 2
	Lbl2.rect_pivot_offset = Lbl2.rect_size / 2

func _play_sfx() -> void :
	Audio.play_sfx("ui_levelup")

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void :
	emit_signal("animation_ended")

func _on_Label_font_replaced() -> void :
	$Label.material = null
	$Label2.material = null
	_play_with_shader = false
