tool 
extends TileMap

var Normal = preload("res://assets/sprites/tiles/solid/the_sinkhole.png")
var NormalSnow = preload("res://assets/sprites/tiles/solid/eztilia_snow.png")
var Build = preload("res://assets/sprites/tiles/solid/eztilia_build.png")
var BuildSnow = preload("res://assets/sprites/tiles/solid/eztilia_build_snow.png")

export (
	String, 
	"normal", "normal_snow", 
	"build", "build_snow"
) var type = "normal" setget set_textures

func set_textures(textur: String) -> void :
	type = textur

	var texture_to_use: Texture
	
	match textur:
		"normal":
			texture_to_use = Normal
		"normal_snow":
			texture_to_use = NormalSnow
		"build":
			texture_to_use = Build
		"build_snow":
			texture_to_use = BuildSnow

	tile_set = tile_set.duplicate()
	for idx in tile_set.get_tiles_ids():
		tile_set.tile_set_texture(idx, texture_to_use)
