extends Node2D

export var pointer: NodePath

export var max_scale: Vector2 = Vector2(1, 1)
export var min_scale: Vector2 = Vector2(0.25, 0.25)

var Pointer: Object

var ConfigMap = preload("res://addons/json_config_file/json_conf.gd").new()

var _data_ini_loaded: bool

var _tilemap_current_room: TileMap
var _tilemap_bg: TileMap
var _tilemap_walls: TileMap
var _tilemap_entries: TileMap
var _tilemap_marks: TileMap
var _tilemap_custom_marks: TileMap
var _tilemap_current_pos: TileMap
var _tilemaps_childrens: Array

onready var TimerMove = $TimerMove

func _notification(what: int) -> void :
	if what == NOTIFICATION_EXIT_TREE:
		ConfigMap.queue_free()

func _ready() -> void :
	
	if pointer.is_empty() == false:
		Pointer = get_node(pointer)
	
	scale = max_scale
	
	
	var data_path: String = "res://stages/%s/data.json" % [VarsGlobal.selected_stage]
	
	
	if ConfigMap.load_file(data_path) == OK:
		_data_ini_loaded = true

func set_initial_data() -> void :
	update_tilemaps_childrens()
	yield(get_tree(), "idle_frame")
	update_current_room()
	yield(get_tree(), "idle_frame")
	update_discovered_rooms()
	update_markers_tiles()

func update_markers_tiles() -> void :
	for m_key in VarsGlobal.game_data["map_markers"].keys():
		
		for m_tile in VarsGlobal.game_data["map_markers"][m_key]:
			add_mark(m_key, m_tile, false)

func update_tilemaps_childrens() -> void :
	
	var children: Array = get_children()
	if children.size() == 2:
		var children_2 = children[1].get_children()
		
		for child in children_2:
			if child is TileMap:
				
				
				if pointer.is_empty() == false:
					var child_duplicate = child.duplicate()
					add_child(child_duplicate)
					child.queue_free()
					child = child_duplicate
				
				_tilemaps_childrens.append(child)
				
				if child.type == child.TYPES.CURRENT_ROOM:
					_tilemap_current_room = child
				
				if child.type == child.TYPES.BG_COLOR:
					_tilemap_bg = child
				
				if child.type == child.TYPES.WALL:
					_tilemap_walls = child
				if child.type == child.TYPES.ENTRY:
					_tilemap_entries = child
				
				if child.type == child.TYPES.MARK:
					_tilemap_marks = child
				
				if child.type == child.TYPES.CUSTOM_MARKS:
					_tilemap_custom_marks = child
				
				if child.type == child.TYPES.CURRENT_POS:
					_tilemap_current_pos = child

func erase_invalid_childrens() -> void :
	for child in _tilemaps_childrens:
		if is_instance_valid(child) == false or child == null:
			_tilemaps_childrens.erase(child)
	yield(get_tree(), "idle_frame")

func update_discovered_rooms() -> void :
	if (
		
		_tilemaps_childrens.size() == 0
		or _data_ini_loaded == false
	):
		return

	
	for t in _tilemap_bg.get_used_cells():
		
		var tile: Array = [int(t.x), int(t.y)]
		var tile_is_visited = VarsGlobal.game_data["visited_tiles"].has(tile)
		var tile_is_visible = VarsGlobal.game_data["visible_tiles"].has(tile)

		if tile_is_visited == false:
			_tilemap_bg.set_cell(tile[0], tile[1], - 1)
			if tile_is_visible == false:
				_tilemap_walls.set_cell(tile[0], tile[1], - 1)
				_tilemap_entries.set_cell(tile[0], tile[1], - 1)
				_tilemap_custom_marks.set_cell(tile[0], tile[1], - 1)

func update_current_room() -> void :
	if (
		pointer.is_empty() == true
		or _tilemaps_childrens.size() == 0
		or _data_ini_loaded == false
	):
		return

	var room_cells: Array = ConfigMap.get_value(
		"map", 
		VarsGlobal.game_data["current_room"], []
	)
	
	
	if room_cells.size() == 0:
		return

	
	if room_cells.size() == 1:
		_tilemap_current_room.set_cell(
			room_cells[0][0], 
			room_cells[0][1], 
			0
		)
		add_tile_to_gamedata("visited_tiles", room_cells[0])
	
	
	elif room_cells.size() == 2:
		var start_cell: Array = room_cells[0]
		var end_cell: Array = room_cells[1]
		
		
		for tile_y in range(
			start_cell[1], end_cell[1] + 1
		):
			
			for tile_x in range(
				start_cell[0], end_cell[0] + 1
			):
				
				_tilemap_current_room.set_cell(
					tile_x, tile_y, 0
				)
				add_tile_to_gamedata("visited_tiles", [tile_x, tile_y])

func get_current_pos_room() -> int:
	
	var current_tile_pos: int = - 1
	
	if VarsGlobal.GameScenario.get_node_or_null(
		"CameraLimit/GridWindowSize"
	) != null:
		current_tile_pos = int(
			VarsGlobal.GameScenario.get_node("CameraLimit/GridWindowSize").current_position
		)
	return current_tile_pos

func add_tile_to_gamedata(data_key: String, tile: Array) -> void :
	if VarsGlobal.game_data[data_key].has(tile) == false:
		VarsGlobal.game_data[data_key].append(tile)

func add_visible_room_to_gamedata(room_name: String) -> void :

	var room_cells: Array = ConfigMap.get_value(
		"map", room_name, []
	)
	
	
	if room_cells.size() == 0:
		return

	
	if room_cells.size() == 1:
		add_tile_to_gamedata("visible_tiles", room_cells[0])
	
	
	elif room_cells.size() == 2:
		var start_cell: Array = room_cells[0]
		var end_cell: Array = room_cells[1]
		
		
		for tile_y in range(
			start_cell[1], end_cell[1] + 1
		):
			
			for tile_x in range(
				start_cell[0], end_cell[0] + 1
			):
				add_tile_to_gamedata("visible_tiles", [tile_x, tile_y])

func center() -> void :
	erase_invalid_childrens()
	if (
		pointer.is_empty() == true
		or _tilemaps_childrens.size() == 0
		or _tilemap_current_room.get_used_cells().empty() == true
	):
		return
	
	
	var position_pointer = Pointer.rect_position + (Pointer.rect_pivot_offset)
	
	
	position = position_pointer

	
	var current_room_center: Vector2 = _tilemap_current_room.get_used_rect().get_center()
	
	
	var currentpos: int = get_current_pos_room()
	var current_room_used_cells: int = _tilemap_current_room.get_used_cells().size()
	
	if currentpos == - 1:
		currentpos = 0
	
	if current_room_used_cells > 0:
		var tile_vec: Vector2 = _tilemap_current_room.get_used_cells()[currentpos]
		_tilemap_current_pos.clear()
		_tilemap_current_pos.set_cell(
			int(tile_vec.x), int(tile_vec.y), 14
		)
		current_room_center = _tilemap_current_pos.get_used_rect().get_center()
		
		if _tilemap_current_pos.get_used_rect().position.y < 0:
			current_room_center = current_room_center + Vector2(0, - 1)
		if _tilemap_current_pos.get_used_rect().position.x < 0:
			current_room_center = current_room_center + Vector2( - 1, 0)

	
	for t in _tilemaps_childrens:
		if is_instance_valid(t) == true:
			
			t.position = (
				t.map_to_world(current_room_center) * Vector2( - 1, - 1)
			) - Pointer.rect_pivot_offset

func get_pointed_tile() -> Array:
	erase_invalid_childrens()
	if (
		pointer.is_empty() == true
		or _tilemaps_childrens.size() == 0
	):
		return []
	
	
	var position_pointer: Vector2
	position_pointer = Pointer.rect_position
	position_pointer -= position
	
	position_pointer -= _tilemaps_childrens[0].position
	
	var tile_vector = _tilemap_bg.world_to_map(position_pointer)

	return [int(tile_vector.x), int(tile_vector.y)]

func add_mark(ide: int, tile: Array, savetogamedata: bool = true) -> void :
	erase_invalid_childrens()
	
	_tilemap_marks.set_cell(
		int(tile[0]), int(tile[1]), ide
	)
	
	if ide == - 1:
		
		_erase_tile_from_gamedata(tile)
	
	elif savetogamedata == true:
		
		if VarsGlobal.game_data["map_markers"].has(ide) == false:
			VarsGlobal.game_data["map_markers"][ide] = []
		_erase_tile_from_gamedata(tile)
		
		yield(get_tree(), "idle_frame")
		VarsGlobal.game_data["map_markers"][ide].append(tile)

func get_mark_idx(tile: Array) -> int:
	return _tilemap_marks.get_cell(tile[0], tile[1])

func move(move_vec: Vector2) -> void :
	
	var move_val: int = 16
	
	if pointer.is_empty() == true or _tilemaps_childrens.size() == 0 or TimerMove.is_stopped() == false:
		return
	
	if scale == max_scale:
		TimerMove.start(0.05)
	else:
		TimerMove.start(0.02)
	
	for t in _tilemaps_childrens:
		match move_vec:
			Vector2.UP:
				t.position.y += move_val
			Vector2.DOWN:
				t.position.y -= move_val
			Vector2.LEFT:
				t.position.x += move_val
			Vector2.RIGHT:
				t.position.x -= move_val
	
	if Audio.sfx_is_playing("ui_move_map") == false:
		Audio.play_sfx("ui_move_map")

func _erase_tile_from_gamedata(t: Array) -> void :
	for t_ide in VarsGlobal.game_data["map_markers"]:
		
		if VarsGlobal.game_data["map_markers"][t_ide].has(t) == true:
			VarsGlobal.game_data["map_markers"][t_ide].erase(t)

func change_zoom() -> void :

	if pointer.is_empty() == true or _tilemaps_childrens.size() == 0:
		return
	
	
	if scale == max_scale:
		scale = min_scale
		Audio.play_sfx("ui_zoom_out")
	
	
	else:
		scale = max_scale
		Audio.play_sfx("ui_zoom_in")
