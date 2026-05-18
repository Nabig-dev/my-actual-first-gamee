extends Node

class_name FuncsFiles

static func get_files(path: String) -> Array:
	var files: Array = []
	var dir: = Directory.new()
	var err_open: int = dir.open(path)
	var err_list_dir: int = dir.list_dir_begin(true)
	
	if err_open == OK and err_list_dir == OK:
		var file = dir.get_next()
		while file != "":
			files += [file]
			file = dir.get_next()
		
		return files
	
	else:
		return []

static func create_texture_from_filepath(filepath: String) -> Texture:
	
	if filepath.empty():
		return null
	
	var img = Image.new()
	var err = img.load(filepath)
	if err != 0:
		print("Error cargando la imagen: " + filepath)
		return null

	var img_tex = ImageTexture.new()
	img_tex.create_from_image(img, 7)

	return img_tex
