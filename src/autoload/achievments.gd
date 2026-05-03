extends Node

signal achievment_obtained(id_achievment)

var achievs: Dictionary = {
	"ach1": ["ACH1TITLE", "ACH1DESC"], 
	"ach2": ["ACH2TITLE", "ACH2DESC"], 
	"ach3": ["ACH3TITLE", "ACH3DESC"], 
	"ach4": ["ACH4TITLE", "ACH4DESC"], 
	"ach5": ["ACH5TITLE", "ACH5DESC"], 
	"ach6": ["ACH6TITLE", "ACH6DESC"]
}

var playstore_achievs_id: Dictionary = {
	"ach1": "CgkI8uOon7sKEAIQAQ", 
	"ach2": "CgkI8uOon7sKEAIQAg", 
	"ach3": "CgkI8uOon7sKEAIQAw", 
	"ach4": "CgkI8uOon7sKEAIQBA", 
	"ach5": "CgkI8uOon7sKEAIQBQ", 
	"ach6": "CgkI8uOon7sKEAIQBg"
}

var filesave_path: String = "user://ach.data"

var _loggedin_playstore: bool

func _ready() -> void :
	
	if OS.get_name() == "Android" and Features.has("demo") == false:
		GooglePlayGamesServices.connect("sign_in_user_authenticated", self, "_on_playstore_signin")
		GooglePlayGamesServices.sign_in_is_authenticated()

	check_ach_filesave()


func check_ach_filesave() -> void :
	var D: = Directory.new()
	var F: = File.new()
	var err: int

	
	if D.file_exists(filesave_path) == false:
		
		err = F.open(filesave_path, File.WRITE)
		if err == OK:
			
			F.store_var([])
			print_debug("Achievement file created and saved successfully.")
		else:
			
			print_debug("Error creating achievement file: %d" % [err])
		
		
		F.close()
	else:
		
		pass


func erase_ach(idach: String) -> void :
	if is_ach_unlocked(idach) == true:
		var unlocked_achs: Array = get_unlocked_ach()
		
		var F: = File.new()
		var err: int
		unlocked_achs.erase(idach)
		err = F.open(filesave_path, File.WRITE)
		if err == OK:
			F.store_var(unlocked_achs)
		F.close()
		if Steam.is_init():
			Steam.clear_achievement(idach)
		print_debug("Achievment erased: %s" % [idach])


func clear_ach() -> void :

	
	if Steam.is_init():
		for ach in range(Steam.user_stats.get_num_achievements()):
			erase_ach(Steam.user_stats.get_achievement_name(ach))

	
	var F: = File.new()
	var err: int
	err = F.open(filesave_path, File.WRITE)
	if err == OK:
		F.store_var([])
	F.close()
	
	print_debug("All achievments erased")


func get_total_achievements() -> int:
	if Steam.is_init():
		return Steam.user_stats.get_num_achievements()
	else:
		return achievs.size()


func get_unlocked_ach() -> Array:
	var F: = File.new()
	var err: int
	var achievments_list: Array
	
	err = F.open(filesave_path, File.READ)
	
	if err == OK:
		achievments_list = F.get_var()
	else:
		print_debug("Error creating achievment file: %d" % [err])
	
	F.close()
	return achievments_list


func is_ach_unlocked(idach: String) -> bool:
	var unlocked_achs: Array = get_unlocked_ach()
	
	if Steam.is_init():
		return Steam.get_achievement(idach)
	
	if idach in unlocked_achs:
		return true
	else:
		return false


func obtain_ach(idach: String) -> void :
	
	if Steam.is_init() == true:
		if is_ach_unlocked(idach) == false:
			Audio.play_sfx("ui_achievement")
			Steam.set_achievement(idach)

	if _loggedin_playstore == true:
		GooglePlayGamesServices.achievements_unlock(playstore_achievs_id[idach])
	
	var unlocked_achs: Array = get_unlocked_ach()
	if is_ach_unlocked(idach) == false:
		unlocked_achs.append(idach)
		
		var F: = File.new()
		var err: int
		err = F.open(filesave_path, File.WRITE)
		if err == OK:
			F.store_var(unlocked_achs)
		F.close()
		
		if Steam.is_init() == false and _loggedin_playstore == false:
			emit_signal("achievment_obtained", idach)
		Audio.play_sfx("ui_achievement")



func get_ach_data(idach: String) -> Dictionary:

	var data: Dictionary = {
		"name": "Achievement unknown: " + idach, 
		"desc": "No description.", 
		"imgpath": "res://assets/images/achievments/unk.png", 
		"imgpath_locked": "res://assets/images/achievments/locked.png", 
	}
	
	if achievs.has(idach) == true:
		data["name"] = tr(achievs[idach][0])
		data["desc"] = tr(achievs[idach][1])
	
	if ResourceLoader.exists("res://assets/images/achievments/%s.png" % [idach]) == true:
		data["imgpath"] = "res://assets/images/achievments/%s.png" % [idach]

	if ResourceLoader.exists("res://assets/images/achievments/%s_locked.png" % [idach]) == true:
		data["imgpath_locked"] = "res://assets/images/achievments/%s_locked.png" % [idach]
	
	return data

func _on_playstore_signin(is_auth: bool) -> void :
	_loggedin_playstore = is_auth
