extends Node

var dbs_path: String = "res://databases"

var _databases: Dictionary

func _ready() -> void :
	for f in FuncsFiles.get_files(dbs_path):
		if f.ends_with(".csvdb") == true:
			_load_file(dbs_path + "/" + f)

func get_db(db_name) -> Dictionary:
	if _databases.keys().has(db_name) == true:
		return _databases[db_name]
	else:
		return {}

func _load_file(f_path: String) -> void :
	var err: int
	var F: = File.new()
	
	err = F.open(f_path, File.READ)
	
	if err == OK and f_path.ends_with(".csvdb") == true:
		
		var db_csv: Dictionary = {}
		var headers: PoolStringArray
		var i: int = 0
		
		while not F.eof_reached():

			if i == 0:
				headers = F.get_csv_line(",")
			else:
				var j: int = 0
				var row: PoolStringArray = F.get_csv_line(",")

				
				for col in row:
					
					if col.empty() == true:
						break
					
					if j == 0:
						db_csv[row[j]] = {}
					
					else:
						if col.is_valid_integer() == true:
							db_csv[row[0]][headers[j]] = int(col)
						elif col.is_valid_float() == true:
							db_csv[row[0]][headers[j]] = float(col)
						else:
							db_csv[row[0]][headers[j]] = col
					
					j += 1
			
			i += 1
		
		
		_databases[
			f_path.get_file().replace(".csvdb", "")
		] = db_csv
	
	else:
		print_debug("Error loading file: " + f_path + " err:" + str(err))
