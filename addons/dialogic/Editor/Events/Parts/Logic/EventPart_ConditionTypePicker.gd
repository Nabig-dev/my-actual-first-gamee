tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"


var options = [
	{
		"text": "Equal to", 
		"condition": "=="
	}, 
	{
		"text": "Different from", 
		"condition": "!="
	}, 
	{
		"text": "Greater than", 
		"condition": ">"
	}, 
	{
		"text": "Greater or equal to", 
		"condition": ">="
	}, 
	{
		"text": "Less than", 
		"condition": "<"
	}, 
	{
		"text": "Less or equal to", 
		"condition": "<="
	}
]

onready var picker_menu = $MenuButton


func _ready():
	
	picker_menu.get_popup().connect("index_pressed", self, "_on_PickerMenu_selected")
	picker_menu.connect("about_to_show", self, "_on_PickerMenu_about_to_show")
	picker_menu.custom_icon = get_icon("GDScript", "EditorIcons")


func load_data(data: Dictionary):
	
	.load_data(data)
	
	
	select_condition_type(data["condition"])
	


func get_preview():
	return ""

func select_condition_type(condition):
	if condition != "":
		for o in options:
			if (o["condition"] == condition):
				picker_menu.text = o["text"]
	else:
		picker_menu.text = options[0]["text"]

func _on_PickerMenu_selected(index):
	event_data["condition"] = picker_menu.get_popup().get_item_metadata(index).get("condition", "")
	
	select_condition_type(event_data["condition"])
	
	
	data_changed()

func _on_PickerMenu_about_to_show():
	picker_menu.get_popup().clear()
	var index = 0
	for o in options:
		picker_menu.get_popup().add_item(o["text"])
		picker_menu.get_popup().set_item_metadata(index, o)
		index += 1
