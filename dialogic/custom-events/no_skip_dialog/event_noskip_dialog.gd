extends Node

func handle_event(event_data, dialog_node):
	
	var SkipNode = dialog_node.get_node_or_null("ControlSkip")

	if SkipNode != null:
		
		SkipNode.visible = not event_data["skip_disabled"]
	
	
	dialog_node._load_next_event()
	dialog_node.set_state(dialog_node.state.READY)
