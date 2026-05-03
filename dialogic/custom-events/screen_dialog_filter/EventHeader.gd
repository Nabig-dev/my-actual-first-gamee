tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"

onready var MenuBtn = $MenuButton

func _ready() -> void :
	MenuBtn.get_popup().connect(
		"index_pressed", self, "_on_menu_item_selected"
	)

func load_data(data: Dictionary):
	
	.load_data(data)
	
	if event_data.has("filter_idx") == false:
		event_data["filter_idx"] = 0
	
	MenuBtn.get_popup().set_current_index(event_data["filter_idx"])
	_on_menu_item_selected(event_data["filter_idx"])

func _on_menu_item_selected(idx: int) -> void :
	MenuBtn.text = "Selected: %s" % [MenuBtn.get_popup().get_item_text(idx)]
	event_data["filter_idx"] = idx
	data_changed()
