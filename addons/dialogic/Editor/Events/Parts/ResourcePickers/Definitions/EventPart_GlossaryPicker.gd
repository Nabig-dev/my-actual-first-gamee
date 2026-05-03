tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"


export (String) var default_text = "Select Glossary Item"


onready var picker_menu = $MenuButton


func _ready():
	picker_menu.connect("about_to_show", self, "_on_PickerMenu_about_to_show")
	picker_menu.custom_icon = get_icon("ListSelect", "EditorIcons")


func load_data(data: Dictionary):
	
	.load_data(data)
	
	
	select_glossary_by_id(data["glossary_id"])
	

func get_preview():
	return ""

func select_glossary_by_id(id):
	if id != "":
		for d in DialogicResources.get_default_definitions()["glossary"]:
			if d["id"] == id:
				picker_menu.text = d["name"]
	else:
		picker_menu.text = default_text


func _on_PickerMenu_selected(index, menu):
	event_data["glossary_id"] = menu.get_item_metadata(index).get("file", "")
	
	select_glossary_by_id(event_data["glossary_id"])
	
	
	data_changed()

func _on_PickerMenu_about_to_show():
	build_PickerMenu()

func build_PickerMenu():
	picker_menu.get_popup().clear()
	var folder_structure = DialogicUtil.get_definitions_folder_structure()

	
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
	
	var files_info = DialogicUtil.get_default_definitions_dict()
	for file in folder_structure["files"]:
		if files_info[file]["type"] == 1:
			menu.add_item(files_info[file]["name"])
			menu.set_item_icon(index, editor_reference.get_node("MainPanel/MasterTreeContainer/MasterTree").glossary_icon)
			menu.set_item_metadata(index, {"file": file})
			index += 1
	
	if not menu.is_connected("index_pressed", self, "_on_PickerMenu_selected"):
		menu.connect("index_pressed", self, "_on_PickerMenu_selected", [menu])
	
	return current_folder_name
