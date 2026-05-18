tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"


export (String) var default_text = "Select Definition"


onready var picker_menu = $HBox / MenuButton


func _ready():
	picker_menu.connect("about_to_show", self, "_on_PickerMenu_about_to_show")
	
	
	picker_menu.custom_icon_modulation = get_color("font_color", "Editor")
	picker_menu.custom_icon = load("res://addons/dialogic/Images/Resources/definition.svg")


func load_data(data: Dictionary):
	
	.load_data(data)
	
	
	select_definition_by_id(data["definition"])
	

func get_preview():
	return ""

func select_definition_by_id(id):
	if id != "":
		for d in DialogicResources.get_default_definitions()["variables"]:
			if d["id"] == id:
				picker_menu.text = d["name"]
	else:
		picker_menu.text = default_text


func _on_PickerMenu_selected(index, menu):
	var text = menu.get_item_text(index)
	var metadata = menu.get_item_metadata(index)
	picker_menu.text = text
	
	event_data["definition"] = metadata["file"]
	
	data_changed()

func _on_PickerMenu_about_to_show():
	
	picker_menu.get_popup().clear()
	
	build_PickerMenuFolder(picker_menu.get_popup(), DialogicUtil.get_definitions_folder_structure(), "MenuButton")


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
		
	
	var files_info = DialogicUtil.get_default_definitions_dict()
	for file in folder_structure["files"]:
		if files_info[file]["type"] == 0:
			menu.add_item(files_info[file]["name"])
			menu.set_item_icon(index, load("res://addons/dialogic/Images/Resources/definition.svg"))
			menu.set_item_metadata(index, {"file": file})
			index += 1
	
	if not menu.is_connected("index_pressed", self, "_on_PickerMenu_selected"):
		menu.connect("index_pressed", self, "_on_PickerMenu_selected", [menu])
	
	return current_folder_name
