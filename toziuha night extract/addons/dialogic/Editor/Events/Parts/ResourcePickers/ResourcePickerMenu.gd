tool 
extends MenuButton

export (Texture) var custom_icon setget set_custom_icon
var custom_icon_modulation setget set_custom_icon_modulation
var menu_background


var default_color = Color("ccced3")

func _ready():
	menu_background = load("res://addons/dialogic/Editor/Events/styles/ResourceMenuPanelBackground.tres")
	menu_background.bg_color = get_color("base_color", "Editor")
	add_color_override("font_color", default_color)
	update_submenu_style(get_popup())
	reset_modulation()
	$Icon2.texture = get_icon("Collapse", "EditorIcons")

func update_submenu_style(submenu):
	submenu.add_stylebox_override("panel", menu_background)
	submenu.add_stylebox_override("hover", StyleBoxEmpty.new())
	submenu.add_color_override("font_color_hover", get_color("accent_color", "Editor"))

func set_custom_icon(texture: Texture):
	$Icon.texture = texture

func set_custom_icon_modulation(color: Color):
	$Icon.modulate = color

func reset_modulation():
	$Icon.modulate = default_color
	$Icon2.modulate = default_color
