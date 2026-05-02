tool 
extends TileMap

var Normal = preload("res://assets/sprites/tiles/solid/eztilia_rocks.png")
var NormalSnow = preload("res://assets/sprites/tiles/solid/eztilia_rocks_snow.png")

export (
	String, 
	"normal", "normal_snow"
) var type = "normal" setget set_textures

func set_textures(textur: String) -> void :
	type = textur

	var texture_to_use: Texture
	
	match textur:
		"normal":
			texture_to_use = Normal
		"normal_snow":
			texture_to_use = NormalSnow

	tile_set = tile_set.duplicate()
	for idx in tile_set.get_tiles_ids():
		tile_set.tile_set_texture(idx, texture_to_use)
