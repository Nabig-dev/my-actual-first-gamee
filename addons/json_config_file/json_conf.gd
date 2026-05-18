extends Node2D




var F: = File.new()

var settings_path: String = "user://settings.json"
var data_loaded: Dictionary = {}

func load_file(filepath: String) -> int:
	
	var err: int = OK
	
	
	err = make_file_if_not_exists(filepath)

	
	if err != OK:
		return err
	
	
	err = F.open(filepath, File.READ)

	if err == OK:
		var json_data: String = F.get_as_text()
		
		F.close()
		if json_data.empty() == false:
			data_loaded = parse_json(
				json_data
			)
		settings_path = filepath

	return err


func save_file(conf_path: String = settings_path) -> int:
	var err: int = OK

	err = F.open(conf_path, File.WRITE)
	
	if err == OK:
		F.store_line(
			JSONBeautifier.beautify_json(
				to_json(data_loaded)
			)
		)
		F.close()

	return err

func set_value(section: String, key: String, value) -> void :
	
	if data_loaded.has(section) == false:
		data_loaded[section] = {key: value}
	
	data_loaded[section][key] = value

func get_value(
	section: String, key: String, default
):
	if has_section_key(section, key) == true:
		
		var obtained_val = data_loaded[section][key]
		
		
		
		if (
			obtained_val is String
			and obtained_val.begins_with("(")
			and obtained_val.ends_with(")")
		):
			obtained_val = obtained_val.replace(")", "")
			obtained_val = obtained_val.replace("(", "")
			obtained_val = obtained_val.strip_edges()
			obtained_val = Vector2(
				obtained_val.split(",")[0], 
				obtained_val.split(",")[1]
			)
		
		
		if str(obtained_val).is_valid_integer() == true:
			obtained_val = int(obtained_val)
		
		
		if (
			obtained_val is String
			and obtained_val.begins_with("[")
			and obtained_val.ends_with("]")
		):
			obtained_val = str2var(obtained_val)
		
		return obtained_val
	
	else:
		return default

func get_section_keys(section: String) -> PoolStringArray:
	var arr: PoolStringArray
	if has_section(section) == true:
		arr = data_loaded[section].keys()
	return arr

func has_section(section: String) -> bool:
	return data_loaded.has(section)

func has_section_key(section: String, key: String) -> bool:
	if has_section(section) == true:
		if data_loaded[section].has(key):
			return true
	return false

func make_file_if_not_exists(filepath: String) -> int:
	var err: int = OK
	if F.file_exists(filepath) == false:
		err = F.open(filepath, File.WRITE)
		F.store_line(to_json({}))
		F.close()
	return err
