extends Node

func handle_event(event_data, dialog_node):
	
	var BGNode = dialog_node.get_node_or_null("BG")

	if BGNode != null:
		
		BGNode.visible = event_data["bg_visible"]
	
	
	dialog_node._load_next_event()
	dialog_node.set_state(dialog_node.state.READY)
