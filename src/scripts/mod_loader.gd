extends Node



var Dir: = Directory.new()
var F: = File.new()

var mods_path: String = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/Toziuha Night OotA Mods"

var _folder_ok: bool

func _ready() -> void :
	if Features.has("pc") == true:
		_folder_ok = check_mods_folder()
	
	if _folder_ok == true:
		load_mods()

func check_mods_folder() -> bool:
	var err: int
	if Dir.dir_exists(mods_path) == false:
		err = Dir.make_dir(mods_path)
		if err == OK:
			return true
		else:
			print("Error loading mods folder: %d" % [err])
			return false
	else:
		return true

func load_mods() -> void :
	if check_mods_folder() == false:
		return
	for f in FuncsFiles.get_files(mods_path):
		if f.ends_with(".pck") == true:
			var err: bool = ProjectSettings.load_resource_pack(
				mods_path + "/" + f
			)
			if err == false:
				print("Error loading mod file: " + f)
			else:
				print("Mod pck loaded: " + f)
