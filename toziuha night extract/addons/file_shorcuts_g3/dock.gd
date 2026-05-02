tool 

extends MarginContainer

var Conf = ConfigFile.new()
var save_path = "res://addons/file_shorcuts_g3/data.ini"

var MenuBtnPopup: Popup

func _ready() -> void :
	MenuBtnPopup = get_node("%MenuBtn").get_popup()

	Conf.load(save_path)
	
	var paths_saved: Array = Conf.get_value("main", "paths", [])
	
	load_paths(paths_saved)
	
	MenuBtnPopup.connect(
		"id_pressed", self, "_On_MenuBtnPopup_id_pressed"
	)

func load_paths(paths: Array) -> void :
	MenuBtnPopup.clear()
	var i = 0
	for p in paths:
		MenuBtnPopup.add_item(
			p, i
		)
		i += 1

func drop_data(position, data):
	
	
	Conf.load(save_path)
	var paths_saved: Array = Conf.get_value("main", "paths", [])
	
	paths_saved.append_array(data["files"])
	
	load_paths(paths_saved)
	
	Conf.set_value("main", "paths", paths_saved)
	
	Conf.save(save_path)

func can_drop_data(position, data):
	var can_drop: bool = true
	
	for d in data["files"]:
		if d.ends_with(".gd") or d.ends_with(".tscn"):
			pass
		else:
			can_drop = false
	
	return can_drop

func _On_MenuBtnPopup_id_pressed(id: int) -> void :
	var path = MenuBtnPopup.get_item_text(
		MenuBtnPopup.get_item_index(id)
	)
	var scene_type: int = 0
	
	
	var interface = get_tree().get_meta("editor_interface")
	
	if path.ends_with(".gd"):
		interface.set_main_screen_editor("Script")
	
	else:
		
		var resource = ResourceLoader.load(path)
		if resource is PackedScene:
			var instance = resource.instance()
			if instance is Spatial:
					scene_type = 1
		
		if scene_type == 0:
			interface.set_main_screen_editor("2D")
		else:
			interface.set_main_screen_editor("3D")
	
	
	interface.open_scene_from_path(path)
