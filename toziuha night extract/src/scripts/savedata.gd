extends Node

var GameVer = preload("res://version.gd").new()

var err: int = OK

var dir = Directory.new()
var file = File.new()

var _path_savefolder: String = "user://saves"
var _path_fullsavefile: String = _path_savefolder + "/%s-%d.toziuhasave"

var _playstore_logged: bool

func _ready() -> void :
	if OS.get_name() == "Android" or Features.has("demo") == false:
		GooglePlayGamesServices.connect("sign_in_user_authenticated", self, "_on_playstore_signin")
		GooglePlayGamesServices.connect("snapshots_game_saved", self, "_on_playstore_snapshot_saved")
		GooglePlayGamesServices.sign_in_is_authenticated()

func serialize_data(quick_save: bool = false) -> Dictionary:
	var save_data: Dictionary
	save_data = {
		"game_version": GameVer.VERSION, 
		"game_version_status": VarsGlobal.get_version_status(), 
		"quick_save": quick_save, 
		"stage_name": VarsGlobal.selected_stage, 
		"thermal_bar_is_active": ThermalBar.is_active(), 
		"thermal_bar_type": ThermalBar.type, 
		"game_data": VarsGlobal.game_data
	}
	return save_data


func get_game_resume(
	slot: int = VarsGlobal.selected_slot, 
	stage: String = VarsGlobal.selected_stage
) -> Dictionary:
	var resume_dict: Dictionary = {}
	var file_path = _path_fullsavefile % [
		stage, slot
	]
	var _data: Dictionary
	
	err = file.open(file_path, File.READ)
	
	if err == OK:
		_data = file.get_var()
		resume_dict["save_name"] = _data["game_data"]["save_name"]
		resume_dict["scenario_name"] = tr(_data["game_data"]["current_area_title"])
		
		
		if resume_dict["scenario_name"] == _data["game_data"]["current_area_title"]:
			resume_dict["scenario_name"] = _data["game_data"]["current_area_title"].capitalize()
		
		resume_dict["millis_elapsed"] = _data["game_data"]["millis_elapsed"]
		resume_dict["total_visited_rooms"] = _data["game_data"]["visited_rooms"].size()
		resume_dict["total_visited_tiles"] = _data["game_data"]["visited_tiles"].size()
	
	return resume_dict

func game_exists(
	slot: int = VarsGlobal.selected_slot, 
	stage: String = VarsGlobal.selected_stage, 
	is_quicksave: bool = false
) -> bool:
	if is_quicksave == true:
		stage = stage + "-quick"
	var file_path = _path_fullsavefile % [
		stage, slot
	]
	return file.file_exists(file_path)

func save_game(
	slot: int = VarsGlobal.selected_slot, 
	stage: String = VarsGlobal.selected_stage, 
	save_name: String = VarsGlobal.game_data["save_name"], 
	quicksave: bool = false, 
	savesnapshot: bool = true
) -> int:

	if quicksave == true:
		stage = stage + "-quick"

	
	if dir.dir_exists(_path_savefolder) == false:
		dir.make_dir(_path_savefolder)

	var file_path = _path_fullsavefile % [
		stage, slot
	]
	
	err = file.open(file_path, File.WRITE)
	
	
	if err == OK:
		
		
		
		
		if Stopwatch.is_active == true:
			VarsGlobal.game_data["millis_elapsed"] += Stopwatch.millis_elapsed
			Stopwatch.stop()
			Stopwatch.start()
		VarsGlobal.game_data["save_name"] = save_name
		file.store_var(serialize_data(quicksave))
	
	file.close()
	
	
	if quicksave == false and _playstore_logged == true and savesnapshot == true:
		_save_to_playstore()
	
	
	
	
	
	return err

func load_game(
	slot: int = VarsGlobal.selected_slot, 
	stage: String = VarsGlobal.selected_stage, 
	quickload: bool = false
) -> int:
	
	if quickload == true:
		stage = stage + "-quick"
	
	var file_path = _path_fullsavefile % [
		stage, slot
	]
	var savegame_data: Dictionary
	
	
	if file.file_exists(file_path) == false:
		return ERR_FILE_NOT_FOUND
	
	err = file.open(file_path, File.READ)
	
	if err == OK:
		savegame_data = file.get_var()
		
		
		
		
		
		if (
			savegame_data["stage_name"] != VarsGlobal.selected_stage
			or savegame_data["quick_save"] != quickload
			
		) and OS.is_debug_build() == false:
			return ERR_INVALID_PARAMETER
		
		
		VarsGlobal.game_data = savegame_data["game_data"]
		if savegame_data["thermal_bar_is_active"] == true:
			ThermalBar.start(
				savegame_data["thermal_bar_type"]
			)
	
	file.close()
	
	return err

func delete_game(
	slot: int = VarsGlobal.selected_slot, 
	stage: String = VarsGlobal.selected_stage, 
	is_quicksave: bool = false
) -> int:
	if is_quicksave == true:
		stage = stage + "-quick"
	var file_path = _path_fullsavefile % [
		stage, slot
	]
	
	file.close()
	if file.file_exists(file_path) == true:
		return dir.remove(file_path)
	return ERR_FILE_NOT_FOUND



func update_flag_game(new_flag: String) -> void :

	
	if game_exists() == false:
		VarsGlobal.add_flag(new_flag)
		return
	
	var file_path = _path_fullsavefile % [
		VarsGlobal.selected_stage, VarsGlobal.selected_slot
	]
	var savegame: Dictionary
	
	err = file.open(file_path, File.READ)
	if err == OK:
		
		savegame = file.get_var()

		if savegame["game_data"]["flags"].has(new_flag) == false:
			savegame["game_data"]["flags"].append(new_flag)
		
			
			
			err = file.open(file_path, File.WRITE)
			if err == OK:
				file.store_var(savegame)
				VarsGlobal.add_flag(new_flag)
		
		file.close()



func increase_death_counter() -> void :
	
	if game_exists() == false:
		VarsGlobal.game_data["total_deaths"] += 1
		return
	
	var file_path = _path_fullsavefile % [
		VarsGlobal.selected_stage, VarsGlobal.selected_slot
	]
	var savegame: Dictionary
	
	err = file.open(file_path, File.READ)
	
	if err == OK:
		savegame = file.get_var()
		savegame["game_data"]["total_deaths"] += 1
		err = file.open(file_path, File.WRITE)
		if err == OK:
			file.store_var(savegame)
		
	file.close()


func _save_to_playstore() -> void :
	GooglePlayGamesServices.snapshots_save_game(
		"%s_%s" % [VarsGlobal.selected_stage, VarsGlobal.selected_slot], 
		"%s %s %s" % [
			VarsGlobal.game_data["save_name"], 
			VarsGlobal.game_data["current_area_title"], 
			"%.2f%% " % [
				VarsGlobal.get_map_percentage(VarsGlobal.game_data["visited_tiles"].size())
			]
		], 
		JSON.print(VarsGlobal.game_data).to_utf8(), 
		Stopwatch.convert_to_milli_int(VarsGlobal.game_data["millis_elapsed"]), 
		int(VarsGlobal.get_map_percentage(VarsGlobal.game_data["visited_tiles"].size()))
	)


func replace_gamedata_to_savefile(gamedata: Dictionary, slot: int = 0, stage: String = "oota") -> int:
	var _err: int
	
	if game_exists(slot, stage, false) == false:
		_err = save_game(slot, stage, "XANDRIA", false, false)
		if _err != OK:
			return _err
	VarsGlobal.game_data = gamedata
	err = save_game(slot, stage, VarsGlobal.game_data["save_name"], false, false)
	return err

func _on_playstore_signin(is_auth: bool) -> void :
	_playstore_logged = is_auth

func _on_playstore_snapshot_saved(saved: bool, file_name: String, _description: String) -> void :
	if (
		saved == true and file_name == "%s_%s" % [VarsGlobal.selected_stage, VarsGlobal.selected_slot]
	):
		VarsGlobal.GameInterface.show_notif_item_obtained("SAVEDATABACKED")
