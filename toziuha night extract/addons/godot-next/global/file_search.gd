tool 
class_name FileSearch
extends Reference




class FileEvaluator extends Reference:
	var file_path: String = "" setget set_file_path

	
	func _is_match() -> bool:
		return true


	
	func _get_key():
		return file_path


	
	func _get_value() -> Dictionary:
		return {"path": file_path}


	
	func set_file_path(p_value):
		file_path = p_value


class FilesThatHaveString extends FileEvaluator:
	var _compare: String

	func _init(p_compare: String = ""):
		_compare = p_compare


	func _is_match() -> bool:
		return file_path.find(_compare) != - 1


class FilesThatAreSubsequenceOf extends FileEvaluator:
	var _compare: String
	var _case_sensitive: bool

	func _init(p_compare: String = "", p_case_sensitive: bool = false):
		_compare = p_compare
		_case_sensitive = p_case_sensitive


	func _is_match() -> bool:
		if _case_sensitive:
			return _compare.is_subsequence_of(file_path)
		return _compare.is_subsequence_ofi(file_path)


class FilesThatMatchRegex extends FileEvaluator:
	var _regex: RegEx = RegEx.new()
	var _compare_full_path
	var _match: RegExMatch = null

	func _init(p_regex_str: String, p_compare_full_path: bool = false):
		_compare_full_path = p_compare_full_path
		if _regex.compile(p_regex_str) != OK:
			push_error("Check failed. FilesThatMatchRegex failed to compile regex: " + p_regex_str)
			return


	func _is_match() -> bool:
		if not _regex.is_valid():
			return false
		_match = _regex.search(file_path if _compare_full_path else file_path.get_file())
		return _match != null


	func _get_value() -> Dictionary:
		var data = ._get_value()
		data.match = _match
		return data


class FilesThatExtendResource extends FileEvaluator:
	var _match_func: FuncRef
	var _exts: Dictionary

	func _init(p_types: PoolStringArray = PoolStringArray(["Resource"]), p_match_func: FuncRef = null, p_block_base_resource: bool = false):
		_match_func = p_match_func
		for type in p_types:
			for a_ext in ResourceLoader.get_recognized_extensions_for_type(type):
				_exts[a_ext] = null
		if p_block_base_resource:
			
			
			_exts.erase("tres")
			_exts.erase("res")


	func _is_match() -> bool:
		for a_ext in _exts:
			if file_path.get_file().get_extension() == a_ext:
				if _match_func:
					return _match_func.call_func(file_path)
				return true
		return false


const SELF_PATH: String = "res://addons/godot-next/global/file_search.gd"

static func search_string(p_str: String, p_from_dir: String = "res://", p_recursive: bool = true) -> Dictionary:
	return _search(FilesThatHaveString.new(p_str), p_from_dir, p_recursive)


static func search_subsequence(p_str: String, p_from_dir: String = "res://", p_recursive: bool = true) -> Dictionary:
	return _search(FilesThatAreSubsequenceOf.new(p_str, false), p_from_dir, p_recursive)


static func search_subsequence_i(p_str: String, p_from_dir: String = "res://", p_recursive: bool = true) -> Dictionary:
	return _search(FilesThatAreSubsequenceOf.new(p_str, true), p_from_dir, p_recursive)


static func search_regex(p_regex: String, p_from_dir: String = "res://", p_recursive: bool = true) -> Dictionary:
	return _search(FilesThatMatchRegex.new(p_regex, false), p_from_dir, p_recursive)


static func search_regex_full_path(p_regex: String, p_from_dir: String = "res://", p_recursive: bool = true) -> Dictionary:
	return _search(FilesThatMatchRegex.new(p_regex, true), p_from_dir, p_recursive)


static func search_scripts(p_match_func: FuncRef = null, p_from_dir: String = "res://", p_recursive: bool = true) -> Dictionary:
	return _search(FilesThatExtendResource.new(["Script"], p_match_func), p_from_dir, p_recursive)


static func search_scenes(p_match_func: FuncRef = null, p_from_dir: String = "res://", p_recursive: bool = true) -> Dictionary:
	return _search(FilesThatExtendResource.new(["PackedScene"], p_match_func), p_from_dir, p_recursive)


static func search_types(p_match_func: FuncRef = null, p_from_dir: String = "res://", p_recursive: bool = true) -> Dictionary:
	return _search(FilesThatExtendResource.new(["Script", "PackedScene"], p_match_func), p_from_dir, p_recursive)


static func search_resources(p_types: PoolStringArray = ["Resource"], p_match_func: FuncRef = null, p_from_dir: String = "res://", p_recursive: bool = true) -> Dictionary:
	return _search(FilesThatExtendResource.new(p_types, p_match_func), p_from_dir, p_recursive)


static func _this() -> Script:
	return load(SELF_PATH) as Script





static func _search(p_evaluator: FileEvaluator, p_from_dir: String = "res://", p_recursive: bool = true) -> Dictionary:
	var dirs: Array = [p_from_dir]
	var dir: Directory = Directory.new()
	var data: Dictionary = {}
	var eval: FileEvaluator = p_evaluator

	
	while not dirs.empty():
		var dir_name = dirs.back()
		dirs.pop_back()

		if dir.open(dir_name) == OK:
			
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name:
				
				if not file_name.begins_with("."):
					var a_path = dir.get_current_dir().plus_file(file_name)
					eval.set_file_path(a_path)

					
					if p_recursive and dir.current_is_dir():
						dirs.push_back(a_path)
					
					
					elif not data.has(a_path) and eval._is_match():
						data[eval._get_key()] = eval._get_value()

				
				file_name = dir.get_next()

			
			dir.list_dir_end()

	return data
