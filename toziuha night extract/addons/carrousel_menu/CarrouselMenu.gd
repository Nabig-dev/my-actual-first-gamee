extends Node2D




signal selected_item(item_index)

signal focused_to(item_index)

signal _move_ended

export var active: bool = true

export var focus_idx: int = - 1

export var key_left: String = "ui_left"
export var key_right: String = "ui_right"
export var key_select: String = "ui_select"

export var animation_duration: float = 0.3

export var separation: float = 200

export var scale_focused: float = 1.0
export var scale_unfocused: float = 0.9

export var unfocused_position_y_offset: float = - 50.0

export var color_focused: Color = Color.white
export var color_unfocused: Color = Color("424242")

export var show_crosshair: bool

export var simulate_infinite_list: bool = true

export var minimum_for_infinite_list: int = 5

export (Array, NodePath) var items

var selected_index: int

var _item_middle_index: int = 0
var _items_list: Array

var _moving_anim: bool

var _extra_items_lst_l: Array
var _extra_items_lst_r: Array

var _main_position_left: float = 0
var _main_position_right: float

func _ready() -> void :

	if show_crosshair == true:
		var NewSprite: = Sprite.new()
		NewSprite.scale = Vector2(0.3, 0.3)
		NewSprite.texture = load("res://addons/carrousel_menu/cross.png")
		NewSprite.name = "Cross"
		add_child(NewSprite)
	
	var NewPosition: = Position2D.new()
	NewPosition.name = "Items"
	add_child(NewPosition)
	
	var i: int
	
	var prev_pos_x: float = 0
	for it in items:
		if it.is_empty() == false:
			
			var ItemInstance: Node2D = get_node(it).duplicate()
			ItemInstance.position = Vector2(prev_pos_x, 0)
			prev_pos_x += separation
			
			$Items.add_child(ItemInstance)
			
			_items_list.append(ItemInstance)
			
			get_node(it).queue_free()
		i += 1
	
	_main_position_right = - (separation * (_items_list.size() - 1) + 1)
		
	
	
	if _items_list.size() >= minimum_for_infinite_list and simulate_infinite_list == true:
		
		var extra_range_inverted: Array = range(_items_list.size())
		extra_range_inverted.invert()
		i = 0
		for n in extra_range_inverted:
			if n > 0:
				var ExtraNode = _items_list[n].duplicate()
				ExtraNode.z_index = 0
				ExtraNode.modulate = color_unfocused
				ExtraNode.scale = Vector2(scale_unfocused, scale_unfocused)
				if i == 0:
					ExtraNode.position = _items_list[i].position - Vector2(separation, 0)
				else:
					ExtraNode.position = _extra_items_lst_l[i - 1].position - Vector2(separation, 0)
				ExtraNode.position.y = unfocused_position_y_offset
				$Items.add_child(ExtraNode)
				_extra_items_lst_l.append(ExtraNode)
				i += 1
		
		var extra_range = range(_items_list.size())
		i = 0
		for n in extra_range:
			if n < _items_list.size() - 1:
				
				var ExtraNode = _items_list[n].duplicate()
				ExtraNode.z_index = 0
				ExtraNode.modulate = color_unfocused
				ExtraNode.scale = Vector2(scale_unfocused, scale_unfocused)
				if i == 0:
					ExtraNode.position = _items_list[_items_list.size() - 1].position + Vector2(separation, 0)
				else:
					ExtraNode.position = _extra_items_lst_r[i - 1].position + Vector2(separation, 0)
				ExtraNode.position.y = unfocused_position_y_offset
				$Items.add_child(ExtraNode)
				_extra_items_lst_r.append(ExtraNode)
				i += 1
	
	
	if focus_idx < 0:
		
		_item_middle_index = round(float(_items_list.size()) / 2.0) - 1
		focus_item_first_time(_item_middle_index)
	else:
		
		focus_item_first_time(focus_idx)

func _process(_delta: float) -> void :
	if active == false:
		return
	if Input.is_action_just_pressed(key_left) and key_left.empty() == false:
		move_to("prev")
	elif Input.is_action_just_pressed(key_right) and key_right.empty() == false:
		move_to("next")
	elif Input.is_action_just_pressed(key_select) and key_select.empty() == false:
		emit_signal("selected_item", selected_index)


func focus_item_first_time(idx: int) -> void :
	selected_index = idx
	_update_positions()
	emit_signal("focused_to", selected_index)


func move_to(dir: String) -> void :
	if _moving_anim == true or _items_list.size() <= 1:
		return
	selected_index = _get_new_position_on_array(_items_list, selected_index, dir)
	_update_positions(dir)
	emit_signal("focused_to", selected_index)

func get_selected_node(idx: int = - 1) -> Object:
	var idx_to_select: int = selected_index
	if idx >= 0:
		idx_to_select = idx
	return _items_list[idx_to_select]

func _update_positions(dir: String = "") -> void :
	
	
	_set_focus(_items_list[selected_index], true)
	
	var i: int
	
	
	i = selected_index
	for _n in range(_items_list.size()):
		if i != selected_index and i >= 0:
			_set_focus(_items_list[i], false)
		i -= 1
	
	
	i = selected_index
	for _n in range(_items_list.size()):
		if i != selected_index and i < _items_list.size():
			_set_focus(_items_list[i], false)
		i += 1
	
	var _scrolled_outside: bool
	
	if dir.empty() == false:
		
		if (
			dir == "next" and simulate_infinite_list == true
			and _extra_items_lst_r.empty() == false
		):
			_tween_position_main_x($Items, $Items.position.x - separation)
			
			if selected_index == 0:
				_scrolled_outside = true
				_set_focus(_extra_items_lst_r[0], true)
			yield(self, "_move_ended")
			if _scrolled_outside == true:
				_set_focus(_extra_items_lst_r[0], false, false)
				$Items.position.x = _main_position_left
		
		elif (
			dir == "prev" and simulate_infinite_list == true
			and _extra_items_lst_l.empty() == false
		):
			_tween_position_main_x($Items, $Items.position.x + separation)
			if $Items.position.x + separation > 0:
				_scrolled_outside = true
				_set_focus(_extra_items_lst_l[0], true)
			yield(self, "_move_ended")
			if _scrolled_outside == true:
				_set_focus(_extra_items_lst_l[0], false, false)
				$Items.position.x = _main_position_right
		
		elif dir == "next":
			
			if selected_index == 0:
				_tween_position_main_x($Items, _main_position_left)
			else:
				_tween_position_main_x($Items, $Items.position.x - separation)
		
		elif dir == "prev":
			
			if $Items.position.x + separation > 0:
				_tween_position_main_x($Items, _main_position_right)
			else:
				_tween_position_main_x($Items, $Items.position.x + separation)

	
	else:
		_tween_position_main_x($Items, $Items.position.x - (separation * _item_middle_index))

func _set_focus(obj: Node2D, focus: bool = true, animated: bool = true) -> void :
	
	
	var f_color: Color = color_focused
	var f_scale: float = scale_focused
	var f_y_offset: float = 0
	
	
	if focus == false:
		f_color = color_unfocused
		f_scale = scale_unfocused
		f_y_offset = unfocused_position_y_offset
	
	if animated == true:
		_tween_modulate(obj, f_color)
		_tween_scale(obj, Vector2(f_scale, f_scale))
		_tween_item_position_y(obj, f_y_offset)
	else:
		_tween_modulate(obj, f_color, 0)
		_tween_scale(obj, Vector2(f_scale, f_scale), 0)
		_tween_item_position_y(obj, f_y_offset, 0)
	
	obj.z_index = int(focus)

func _tween_scale(obj: Node2D, new_scale: Vector2, duration: float = animation_duration) -> void :
	var Tw = get_tree().create_tween()
	Tw.tween_property(
		obj, "scale", new_scale, duration
	).set_trans(Tween.TRANS_SINE)

func _tween_modulate(obj: Node2D, new_color: Color, duration: float = animation_duration) -> void :
	var Tw = get_tree().create_tween()
	Tw.tween_property(
		obj, "modulate", new_color, duration
	)


func _tween_item_position_y(obj: Node2D, new_val_y: float, duration: float = animation_duration) -> void :
	var Tw: = create_tween()
	Tw.tween_property(
		obj, "position", Vector2(obj.position.x, new_val_y), duration
	)

func _tween_position_main_x(obj: Node2D, new_val_x: float) -> void :
	_moving_anim = true
	var TweenMove: = create_tween()
	TweenMove.tween_property(
		obj, "position", Vector2(new_val_x, obj.position.y), animation_duration
	).set_trans(Tween.TRANS_QUAD)
	yield(TweenMove, "finished")
	_moving_anim = false
	emit_signal("_move_ended")






func _get_new_position_on_array(
		arr: Array, current_pos: = 0, direction: = ""
	) -> int:

	var new_pos: int = 0
	var arr_size: int = arr.size()
	
	
	
	if current_pos == (arr_size - 1) and direction == "next":
		new_pos = 0
	
	
	elif current_pos == 0 and direction == "prev":
		new_pos = arr_size - 1
	
	elif direction == "next":
			new_pos = current_pos + 1
	elif direction == "prev":
		new_pos = current_pos - 1
	
	else:
		new_pos = current_pos
	
	
	
	if direction.empty() == false and new_pos < 0 or new_pos > (arr_size - 1):
		new_pos = 0
		print_debug("la nueva posicion sobrepasa index del array, regresamos 0")

	
	return new_pos
