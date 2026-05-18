extends Node


func handle_event(event_data, dialog_node):
	
	dialog_node.input_enable = event_data["input_enabled"]
	
	
	dialog_node._load_next_event()
	dialog_node.set_state(dialog_node.state.READY)
