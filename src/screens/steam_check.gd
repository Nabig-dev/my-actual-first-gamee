extends MarginContainer

func _ready() -> void :
	
	visible = false
	
	if Steam.is_init() == true:
		if is_game_bought_on_steam() == false:
			visible = true
			$VBoxContainer / Label.text = "Steam license invalid. The game is not in your library."
			$VBoxContainer / Button.grab_focus()
			return
	
	else:
		visible = true
		$VBoxContainer / Label.text = "Please launch the game using the Steam Client."
		$VBoxContainer / Button.grab_focus()
		return

	
	$VBoxContainer / Button.disabled = true
	
	VarsGlobal.selected_stage = "oota"
	SceneChanger.change_scene("res://src/screens/manage_savegame.tscn")

func is_game_bought_on_steam() -> bool:
	
	if Steam.is_init():
		return Steam.apps.is_subscribed_app(2112750)
	else:
		return true

func _on_Button_pressed() -> void :
	get_tree().quit()
