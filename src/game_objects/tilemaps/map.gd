tool 

extends TileMap

var color_tres = preload("res://assets/tres/map_tiles/color.tres")
var entries_tres = preload("res://assets/tres/map_tiles/entries.tres")
var markers_tres = preload("res://assets/tres/map_tiles/markers.tres")
var wall_tres = preload("res://assets/tres/map_tiles/wall.tres")
var current_room_tres = preload("res://assets/tres/map_tiles/current_room.tres")
var position_player_tres = preload("res://assets/tres/map_tiles/position_room.tres")
var roomcopy_tres = preload("res://assets/tres/map_tiles/roomcopydata.tres")

enum TYPES{
	BG_COLOR, WALL, ENTRY, MARK, 
	CURRENT_ROOM, PLAYER_POSITION, CUSTOM_MARKS, ROOM_DATA_COPY, CURRENT_POS
}

export var copy_tiledata: bool setget copydata

export (TYPES) var type = TYPES.WALL setget update_name


func copydata(val: bool) -> void :
	copy_tiledata = val
	if type == TYPES.ROOM_DATA_COPY:
		var txt_copy: String
		var used_cells: Array = get_used_cells()
		if used_cells.size() == 1:
			txt_copy = "[[%d,%d]]" % [
				used_cells.front().x, used_cells.front().y
			]
		elif used_cells.size() > 1:
			txt_copy = "[[%d,%d],[%d,%d]]" % [
				used_cells.front().x, 
				used_cells.front().y, 
				used_cells.back().x, 
				used_cells.back().y, 
			]
		
		if txt_copy.empty() == false:
			OS.set_clipboard(txt_copy)
		clear()
	copy_tiledata = false

func update_name(nm: int) -> void :
	var name_string: String = TYPES.keys()[nm]
	type = nm
	name = name_string.capitalize() + "TileMap"
	name = name.replace(" ", "")

	match type:
		TYPES.BG_COLOR:
			tile_set = color_tres
			
		TYPES.WALL:
			tile_set = wall_tres
			
		TYPES.ENTRY:
			tile_set = entries_tres
			
		TYPES.MARK, TYPES.CUSTOM_MARKS, TYPES.CURRENT_POS:
			tile_set = markers_tres
			
		TYPES.CURRENT_ROOM:
			tile_set = current_room_tres
			
		TYPES.PLAYER_POSITION:
			tile_set = position_player_tres
		TYPES.ROOM_DATA_COPY:
			tile_set = roomcopy_tres
