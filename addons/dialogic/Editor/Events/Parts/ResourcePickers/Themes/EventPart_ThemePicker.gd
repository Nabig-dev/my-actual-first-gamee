tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"


export (String) var default_text = "Select Theme"


onready var picker_menu = $MenuButton


func _ready():
	picker_menu.connect("about_to_show", self, "_on_PickerMenu_about_to_show")
	picker_menu.custom_icon = load("res://addons/dialogic/Images/Resources/theme.svg")


func load_data(data: Dictionary):
	
	.load_data(data)
	
	
	select_theme()
	

func get_preview():
	return ""

func select_theme():
	if event_data["set_theme"] != "":
		for theme in DialogicUtil.get_theme_list():
			if theme["file"] == event_data["set_theme"]:
				picker_menu.text = theme["name"]
	else:
		picker_menu.text = default_text


func _on_PickerMenu_selected(index, menu):
	event_data["set_theme"] = menu.get_item_metadata(index).get("file", "")
	
	select_theme()
	
	
	data_changed()


func _on_PickerMenu_about_to_show():
	build_PickerMenu()

func build_PickerMenu():
	picker_menu.get_popup().clear()
	var folder_structure = DialogicUtil.get_theme_folder_structure()

	
	build_PickerMenuFolder(picker_menu.get_popup(), folder_structure, "MenuButton")


func build_PickerMenuFolder(menu: PopupMenu, folder_structure: Dictionary, current_folder_name: String):
	var index = 0
	for folder_name in folder_structure["folders"].keys():
		var submenu = PopupMenu.new()
		var submenu_name = build_PickerMenuFolder(submenu, folder_structure["folders"][folder_name], folder_name)
		submenu.name = submenu_name
		menu.add_submenu_item(folder_name, submenu_name)
		menu.set_item_icon(index, get_icon("Folder", "EditorIcons"))
		menu.add_child(submenu)
		picker_menu.update_submenu_style(submenu)
		index += 1
	
	var files_info = DialogicUtil.get_theme_dict()
	for file in folder_structure["files"]:
		menu.add_item(files_info[file]["name"])
		menu.set_item_icon(index, editor_reference.get_node("MainPanel/MasterTreeContainer/MasterTree").theme_icon)
		menu.set_item_metadata(index, {"file": file})
		index += 1
	
	if not menu.is_connected("index_pressed", self, "_on_PickerMenu_selected"):
		menu.connect("index_pressed", self, "_on_PickerMenu_selected", [menu])
	
	return current_folder_name
