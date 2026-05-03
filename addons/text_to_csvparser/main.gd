extends MarginContainer



func _on_Button_pressed() -> void :
	$VBoxContainer / HBoxContainer / TextEdit2.text = ""
	var ide: String = "%s%s" % [
		$VBoxContainer / HBoxContainer2 / LineEdit.text.to_upper(), 
		$VBoxContainer / HBoxContainer2 / LineEdit2.text.to_upper()
	]
	var txt: String = OS.get_clipboard()
	var txt_arr: Array
	var txt_parsed: String
	txt_arr = txt.split("\n")
	
	var i: int = 0
	var t_final: String
	for t in txt_arr:
		t_final = t
		if "," in t_final:
			t_final = "\"%s\"" % [t]
		
		txt_parsed = txt_parsed + "%s,%s,%s\n" % [
			ide + str(i), t_final, "PLACEHOLDER" + ide + str(i)
		]
		i += 1

	$VBoxContainer / HBoxContainer / TextEdit2.text = txt_parsed
	
	_on_Button2_pressed()


func _on_Button2_pressed() -> void :
	OS.set_clipboard(
		$VBoxContainer / HBoxContainer / TextEdit2.text
	)
