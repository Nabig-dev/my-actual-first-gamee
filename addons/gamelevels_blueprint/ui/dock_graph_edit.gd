tool 

extends GraphEdit

signal scene_dropped(filepath, node_position)

func snap(pos: Vector2):

	if use_snap:

		pos = pos / snap_distance
		pos = pos.floor() * snap_distance
		
	return pos

func can_drop_data(position, data):
	
	if data["files"].size() > 1 or data["files"][0].get_extension() != "tscn":
		return false
	
	return true

func drop_data(position, data):
	var filepath = data["files"][0]
	
	
	var offset = (scroll_offset + position) / Vector2(zoom, zoom)
	
	if use_snap == true:
		offset = snap(offset)
	
	emit_signal("scene_dropped", filepath, offset)

