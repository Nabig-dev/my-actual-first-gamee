extends Control

func play(txt: String) -> void :
	var lang: String = Config.get_value("gameplay", "lang", "en")

	$Label.text = txt
	
	if lang != "en":
		$Label.material = null
		$AnimationPlayer.play("show_noshader")
	else:
		$AnimationPlayer.play("show")
