extends Control

func _ready() -> void :

	$HBoxContainer / LblVersion.text = "v%s" % load("res://version.gd").VERSION
	$HBoxContainer / LblStatus.text = "%s" % VarsGlobal.get_version_status()
	if $HBoxContainer / LblStatus.text == "demo":
		$HBoxContainer / LblVersion.visible = false

	if Features.has("mobile"):
		$Logo / HBoxContainer.visible = false
		$Logo / HBoxContainer2.visible = true
	else:
		$Logo / HBoxContainer.visible = true
		$Logo / HBoxContainer2.visible = false
	
	if OS.get_name() == "Android" and Features.has("demo") == false:
		GooglePlayGamesServices.sign_in_show_popup()

func _process(_delta: float) -> void :
	if Input.is_action_just_pressed("ui_accept"):
		SceneChanger.change_scene("res://src/screens/main_menu.tscn")
