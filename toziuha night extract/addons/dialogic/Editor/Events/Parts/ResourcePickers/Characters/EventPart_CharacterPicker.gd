tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"



export (bool) var allow_no_character: = false


onready var picker_menu = $HBox / MenuButton
onready var no_character_button = $NoCharacterContainer / NoCharacterButton
onready var no_character_container = $NoCharacterContainer


var no_character_icon
var all_characters_icon
var single_character_icon


func _ready():
	if DialogicUtil.get_character_list().size() > 0:
		picker_menu.show()
		no_character_container.hide()
	else:
		picker_menu.hide()
		no_character_container.show()
		var editor_reference = find_parent("EditorView")
		no_character_button.connect("pressed", editor_reference.get_node("MainPanel/MasterTreeContainer/MasterTree"), "new_character")
	
	
	
	
	var event_node = get_node("../../../../../../../..")
	if event_node.get_node_or_null("AllowNoCharacter"):
		allow_no_character = true
		no_character_container.hide()
	
	
	picker_menu.connect("about_to_show", self, "_on_PickerMenu_about_to_show")
	
	
	no_character_icon = get_icon("GuiRadioUnchecked", "EditorIcons")
	all_characters_icon = get_icon("GuiEllipsis", "EditorIcons")
	single_character_icon = load("res://addons/dialogic/Images/Resources/character.svg")
	


func load_data(data: Dictionary):
	
	.load_data(data)
	
	allow_no_character = data["event_id"] != "dialogic_002"
	
	update_to_character()



func get_preview():
	return ""



func update_to_character():
	if event_data["character"] != "":
		if event_data["character"] == "[All]":
			picker_menu.text = "All characters"
			picker_menu.reset_modulation()
			picker_menu.custom_icon = all_characters_icon
		else:
			for ch in DialogicUtil.get_character_list():
				if ch["file"] == event_data["character"]:
					picker_menu.text = ch["name"]
					picker_menu.custom_icon_modulation = ch["color"]
					picker_menu.custom_icon = single_character_icon
	else:
		if allow_no_character:
			picker_menu.text = "No Character"
			picker_menu.custom_icon = no_character_icon
		else:
			picker_menu.text = "Select Character"
			picker_menu.custom_icon = single_character_icon
		picker_menu.reset_modulation()


func _on_PickerMenu_selected(index, menu):
	var metadata = menu.get_item_metadata(index)
	if event_data["character"] != metadata.get("file", ""):
		if event_data.get("event_id") == "dialogic_002":
			if event_data.get("type") == 0:
				event_data["portrait"] = "Default"
			elif event_data.get("type") == 2:
				event_data["portrait"] = "(Don't change)"
	event_data["character"] = metadata.get("file", "")
	
	update_to_character()
	
	
	data_changed()


func _on_PickerMenu_about_to_show():
	build_PickerMenu()


func build_PickerMenu():
	picker_menu.get_popup().clear()
	var folder_structure = DialogicUtil.get_characters_folder_structure()

	
	build_PickerMenuFolder(picker_menu.get_popup(), folder_structure, "MenuButton")



func build_PickerMenuFolder(menu: PopupMenu, folder_structure: Dictionary, current_folder_name: String):
	var index = 0
	
	
	if menu == picker_menu.get_popup():
		if event_data.get("event_id", "dialogic_001") != "dialogic_002":
			menu.add_item("No character")
			menu.set_item_metadata(index, {"file": ""})
			menu.set_item_icon(index, no_character_icon)
			index += 1

		
		if event_data.get("type", 0) == 1:
			menu.add_item("All characters")
			menu.set_item_metadata(index, {"file": "[All]"})
			menu.set_item_icon(index, all_characters_icon)
			index += 1
	
	
	for folder_name in folder_structure["folders"].keys():
		var submenu = PopupMenu.new()
		var submenu_name = build_PickerMenuFolder(submenu, folder_structure["folders"][folder_name], folder_name)
		submenu.name = submenu_name
		menu.add_submenu_item(folder_name, submenu_name)
		menu.set_item_icon(index, get_icon("Folder", "EditorIcons"))
		menu.add_child(submenu)
		index += 1
		
		
		picker_menu.update_submenu_style(submenu)
	
	var files_info = DialogicUtil.get_characters_dict()
	for file in folder_structure["files"]:
		menu.add_item(files_info[file]["name"])
		
		
		menu.set_item_icon(index, single_character_icon)
		menu.set_item_metadata(index, {"file": file})
		index += 1
	
	if not menu.is_connected("index_pressed", self, "_on_PickerMenu_selected"):
		menu.connect("index_pressed", self, "_on_PickerMenu_selected", [menu])
	
	return current_folder_name
