tool 
extends Node
class_name DialogicCustomEvents





var handlers: = {}








func update() -> void :
	var path: String = DialogicResources.get_working_directories()["CUSTOM_EVENTS_DIR"]
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			
			if dir.current_is_dir() and not file_name in [".", ".."]:
				
				
				
				var event = load(path.plus_file(file_name).plus_file("EventBlock.tscn")).instance()
				
				if event:
					var handler_script_path = path.plus_file(file_name).plus_file("event_" + event.event_data["event_id"] + ".gd")
					var event_id = event.event_data["event_id"]
					var event_name = event.event_name
					
					
					
					
					
					
					
					
					if handlers.has(event_id):
						
						
						file_name = dir.get_next()
						continue
					else:
						
						
						
						var handler = Node.new()
						handler.set_script(load(handler_script_path))
						handler.set_name(event_name)
						
						
						handler.set_meta("event_id", event_id)
						
						
						handlers[event_id] = handler
						
						self.add_child(handler)
					
					event.queue_free()
				else:
					print("[D] An error occurred when trying to access a custom event.")
			
			
			else:
				pass
			file_name = dir.get_next()
	else:
		print("[D] An error occurred when trying to access the custom event folder.")
