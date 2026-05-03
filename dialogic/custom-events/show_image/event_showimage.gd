extends Node

var ImageDock = preload("res://dialogic/custom-events/show_image/ImageDock.tscn")

func handle_event(event_data, dialog_node):
	\
\
\
\
	" \n\t\tIf this event should wait for dialog advance to occur, uncomment the WAITING line\n\t\tIf this event should block the dialog from continuing, uncomment the WAITINT_INPUT line\n\t\tWhile other states exist, they generally are not neccesary, but include IDLE, TYPING, and ANIMATING\n\t"
	
	
	
	if event_data["image_path"] == "*":
		for imgdock in get_tree().get_nodes_in_group("image_dock_dialog"):
			imgdock.hide_image()
	else:
		var ImageDockInstance = ImageDock.instance()
		ImageDockInstance.image_path = event_data["image_path"]
		dialog_node.add_child(ImageDockInstance)
	
	
	dialog_node._load_next_event()
	dialog_node.set_state(dialog_node.state.READY)
