tool 

extends TileMap

enum VARIANT{STONE, VEGETATION}
export (VARIANT) var variant = 0 setget _update_tilemap

var _tilemap: Array = [
	preload("res://assets/sprites/tiles/solid/terrain1_stone_brown.png"), 
	preload("res://assets/sprites/tiles/solid/terrain1_vegetation.png"), 
]

func _ready() -> void :
	tile_set = tile_set.duplicate()

func _update_tilemap(tilemp: int) -> void :
	variant = tilemp
	
	for t in tile_set.get_tiles_ids():
		tile_set.tile_set_texture(t, _tilemap[variant])

	name = "TileMapTerrain" + VARIANT.keys()[variant].capitalize()
