tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"



var options = [
	{
		"text": "to be", 
		"operation": "="
	}, 
	{
		"text": "to itself plus", 
		"operation": "+"
	}, 
	{
		"text": "to itself minus", 
		"operation": "-"
	}, 
	{
		"text": "to itself multiplied by", 
		"operation": "*"
	}, 
	{
		"text": "to itself divided by", 
		"operation": "/"
	}, 
]


onready var picker_menu = $MenuButton


func _ready():
	picker_menu.get_popup().connect("index_pressed", self, "_on_PickerMenu_selected")
	picker_menu.connect("about_to_show", self, "_on_PickerMenu_about_to_show")
	picker_menu.custom_icon = get_icon("GDScript", "EditorIcons")


func load_data(data: Dictionary):
	
	.load_data(data)
	
	
	select_operation()
	

func get_preview():
	return ""

func select_operation():
	for o in options:
		if (o["operation"] == event_data["operation"]):
			picker_menu.text = o["text"]


func _on_PickerMenu_selected(index):
	event_data["operation"] = picker_menu.get_popup().get_item_metadata(index).get("operation")
	
	select_operation()
	
	
	data_changed()

func _on_PickerMenu_about_to_show():
	picker_menu.get_popup().clear()
	
	var index = 0
	for o in options:
		picker_menu.get_popup().add_item(o["text"])
		picker_menu.get_popup().set_item_metadata(index, o)
		index += 1
