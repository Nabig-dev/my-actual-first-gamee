extends Control

func _ready() -> void :
	$VBoxContainer / BtnReturn.grab_focus()

func _on_BtnFocus(opt: String) -> void :
	match opt:
		"unbreakable_will":
			$Label.text = tr("ABOUTUNBREAKABLEWILL")
		"dynamic_knockback":
			$Label.text = tr("ABOUTDYNAMICKNOCKBACK")
		"desperation_attack":
			$Label.text = tr("ABOUTDESPERATIONATTACK")
		_:
			$Label.text = ""


func _on_BtnResetDefault_focus_entered() -> void :
	$Label.text = ""
func _on_BtnReturn_focus_entered() -> void :
	$Label.text = ""


func _on_BtnResetDefault_pressed() -> void :
	Audio.play_sfx("ui_success")
	Config.set_value(
		"difficulty", "unbreakable_will", false
	)
	Config.set_value(
		"difficulty", "dynamic_knockback", true
	)
	Config.set_value(
		"difficulty", "desperation_attack", true
	)
	Notification.show_notif(tr("CONF_BY_DEFAULT_DONE"))


func _on_BtnReturn_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	SceneChanger.change_scene("res://src/screens/options.tscn")
