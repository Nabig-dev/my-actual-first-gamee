extends Control

var _selected_action: String = ""

onready var VbxButtons = $MarginContainer / HBoxContainer / PanelBtns / Margin / Scroll / Margin / Vbx
onready var VbxButtonsChildren = VbxButtons.get_children()
onready var GridIcons = $MarginContainer / HBoxContainer / PanelIcons / Margin / GridContainer
onready var GridIconsChildren = GridIcons.get_children()

func _ready() -> void :
	
	
	GridIcons.visible = false
	
	$MarginContainer / HBoxContainer / PanelBtns / LblMsg.visible = false
	
	VbxButtonsChildren[0].grab_focus()
	
	for b in VbxButtonsChildren:
		if b is Button and (b.name.begins_with("ui_") or b.name in ["jump", "quickmenu", "attack", "circuit", "backdash"]):
			b.connect("pressed", self, "_on_Button_Selected", [b.name])
			b.text = tr("ACTION_" + b.name.to_upper())
			b.get_node("HelperIconBtn").action = b.name
			b.get_node("HelperIconBtn").update_icon()
	
	for ic in GridIconsChildren:
		if ic is TextureButton:
			ic.connect("pressed", self, "_on_Icon_Selected", [int(ic.name)])
			ic.get_node("Icon").frame = int(ic.name)
			ic.connect("focus_entered", self, "_on_Icon_btn_focused")
	
	
	
	

func _process(_delta: float) -> void :
	
	if Input.is_action_just_pressed("ui_cancel"):
		if _selected_action != "":
			_restore_left_panel()
		else:
			_on_BtnReturn_pressed()

func _on_Icon_btn_focused() -> void :
	Audio.play_sfx("ui_btn_focused")

func _on_Button_Selected(action: String) -> void :
	Audio.play_sfx("ui_accept")
	_selected_action = action
	
	VbxButtons.visible = false
	
	$MarginContainer / HBoxContainer / PanelBtns / LblMsg.visible = true
	
	
	$MarginContainer / HBoxContainer / PanelBtns / LblMsg.text = tr(
		"SELECT_NEW_ICON_FOR_ACTION"
	) % [tr(
		"ACTION_" + _selected_action.to_upper()
	)]
	
	
	$MarginContainer / HBoxContainer / PanelIcons / Margin / LblMsg.visible = false
	
	
	GridIcons.visible = true
	
	GridIcons.get_node(
		String(Config.get_value("helper_btn_icon", _selected_action, 0))
	).grab_focus()

func _on_Icon_Selected(frame: int) -> void :
	
	Audio.play_sfx("ui_accept")
	
	Config.set_value("helper_btn_icon", _selected_action, frame)
	

	_restore_left_panel()

func _restore_left_panel() -> void :
	
	Audio.play_sfx("ui_cancel")
	
	
	$MarginContainer / HBoxContainer / PanelBtns / LblMsg.visible = false
	
	
	$MarginContainer / HBoxContainer / PanelIcons / Margin / LblMsg.visible = true
	
	
	VbxButtons.visible = true
	
	GridIcons.visible = false
	
	VbxButtons.get_node(_selected_action).grab_focus()
	yield(get_tree(), "idle_frame")
	$MarginContainer / HBoxContainer / PanelBtns / Margin / Scroll.ensure_control_visible(
		VbxButtons.get_node(_selected_action)
	)
	
	_selected_action = ""

func _on_BtnReturn_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	SceneChanger.change_scene("res://src/screens/options.tscn")
