extends Button

signal num_changed(numbercurrent)

var num: int = 0

func update_info() -> void :
	text = str(num)

func _on_Btn_pressed() -> void :
	Audio.play_sfx("ui_put_object")
	num += 1
	if num > 3:
		num = 0
	update_info()
	emit_signal("num_changed", num)
