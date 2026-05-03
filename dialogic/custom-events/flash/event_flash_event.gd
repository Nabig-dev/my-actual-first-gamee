extends Node

var FlashEvent = preload("res://dialogic/custom-events/flash/flash_effect.tscn")

func handle_event(event_data, dialog_node):
	
	var FlashInstance = FlashEvent.instance()
	FlashInstance.time = event_data["time_flash"]
	
	dialog_node.add_child(FlashInstance)
	
	
	dialog_node._load_next_event()
	dialog_node.set_state(dialog_node.state.READY)
