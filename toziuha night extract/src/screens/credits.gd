extends Control

var _social_buttons: bool = true

onready var version = load("res://version.gd").VERSION

func _ready() -> void :
	
	get_node("%LabelTitle").text = "Toziuha Night: Order of the Alchemists - v%s %s" % [
		version, VarsGlobal.get_version_status()
	]
	
	if (
		Features.has("switch")
		or Features.has("xbox")
		or Features.has("ps")
	):
		_social_buttons = false
	
	get_node("%CreditsScroll").grab_focus()
	
	if _social_buttons == false:
		get_node("%HBxSocialButton").visible = false
		get_node("%LblWebsite").visible = true
		get_node("%LblWebsite").text = "%s: %s" % [
			tr("WEBSITE"), "dannygaray60.github.io/tn-oota.html"
		]

func _process(_delta: float) -> void :
	if get_node("%CreditsScroll").has_focus() == true and get_node("%PopupSocial").visible == false:
		if Input.is_action_pressed("ui_down"):
			get_node("%CreditsScroll").set_v_scroll(
				get_node("%CreditsScroll").get_v_scroll() + 3
			)
		elif Input.is_action_pressed("ui_up"):
			get_node("%CreditsScroll").set_v_scroll(
				get_node("%CreditsScroll").get_v_scroll() - 3
			)
		if Input.is_action_just_pressed("ui_cancel"):
			_on_BtnExit_pressed()

		if Input.is_action_just_pressed("ui_accept") and _social_buttons == true:
			_on_BtnSeeSocialLinks_pressed()

	if get_node("%PopupSocial").visible == true and Input.is_action_just_pressed("ui_cancel"):
		_on_BtnClosePopup_pressed()

func _on_CreditsScroll_focus_entered() -> void :
	get_node("%CreditsPanelContainer").visible = true
	get_node("%HBxHelpers").visible = true
func _on_CreditsScroll_focus_exited() -> void :
	get_node("%CreditsPanelContainer").visible = false
	get_node("%HBxHelpers").visible = false


func _on_BtnExit_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	SceneChanger.change_scene("res://src/screens/main_menu.tscn")


func _on_BtnSeeSocialLinks_pressed() -> void :
	Audio.play_sfx("ui_accept")
	get_node("%PopupSocial").show()
	get_node("%PopupSocial/SocialButtons/HbxMain/Btnweb").grab_focus()


func _on_BtnClosePopup_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	get_node("%PopupSocial").hide()
	get_node("%CreditsScroll").grab_focus()
