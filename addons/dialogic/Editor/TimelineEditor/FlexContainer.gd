tool 
extends Container











export var horizontal_margin: float = 5
export var vertical_margin: float = 5



var _reported_height_at_last_minimum_size_call: float = 0


func _init() -> void :
	size_flags_horizontal = SIZE_EXPAND_FILL


func _ready():
	pass


func _get_minimum_size() -> Vector2:
	var max_child_width: float = 0
	
	for child in get_children():
		if not child.has_method("get_combined_minimum_size"):
			break
		
		var requested_size: Vector2 = child.get_combined_minimum_size()
		if requested_size.x > max_child_width:
			max_child_width = requested_size.x
	
	var height: = _calculate_layout(false)
	_reported_height_at_last_minimum_size_call = height
	
	return Vector2(max_child_width, height)


func _notification(what):
	if (what == NOTIFICATION_SORT_CHILDREN):
		var height = _calculate_layout(true)
		
		if height != _reported_height_at_last_minimum_size_call:
			_make_parent_reevaluate_our_size()




func _calculate_layout(apply: bool) -> float:
	var child_position: Vector2 = Vector2(0, 0)
	var row_height: float = 0
	var container_width: float = rect_size.x
	var num_children_in_current_row: float = 0
	
	for child in get_children():
		if not child.has_method("get_combined_minimum_size"):
			continue
		if not child.visible:
			continue
		
		var child_min_size: Vector2 = child.get_combined_minimum_size()
		
		if num_children_in_current_row > 0:
			child_position.x += horizontal_margin
		
		if child_position.x + child_min_size.x > container_width:
			
			child_position = Vector2(0, child_position.y + row_height + vertical_margin)
			row_height = 0
			num_children_in_current_row = 0
		
		if apply:
			fit_child_in_rect(child, Rect2(child_position, child_min_size))
		
		if child_min_size.y > row_height:
			row_height = child_min_size.y
		
		child_position.x += child_min_size.x
		num_children_in_current_row += 1
	
	return child_position.y + row_height


func _make_parent_reevaluate_our_size():
	
	rect_min_size = Vector2(0, 20000)
	rect_min_size = Vector2(0, 0)























	
