extends Control

func _ready() -> void :
	Audio.stop_music()
	$BtnBuyGame.visible = false
		
	
	if (
		Features.has("switch")
		or Features.has("xbox")
		or Features.has("ps")
	):
		$SocialButtons.visible = false
		$BtnClose.grab_focus()
	
	if Features.has("mobile") == true:
		$SocialButtons.visible = false
		$BtnBuyGame.visible = true
		$BtnBuyGame.grab_focus()

func _process(_delta: float) -> void :
	if Input.is_action_just_pressed("ui_cancel"):
		_on_BtnClose_pressed()

func _on_BtnClose_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	SceneChanger.change_scene("res://src/screens/main_menu.tscn")


func _on_BtnBuyGame_pressed() -> void :
	Audio.play_sfx("ui_accept")
	OS.shell_open("https://play.google.com/store/apps/details?id=com.danny_garay.toziuha_night_oota")
