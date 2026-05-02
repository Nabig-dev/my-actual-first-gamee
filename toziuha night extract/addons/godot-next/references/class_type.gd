tool 
class_name ClassType
extends Reference




































































enum Source{
	NONE, 
	ENGINE, 
	SCRIPT, 
	ANONYMOUS, 
}

export var name: String = "" setget set_name, get_name
export (String, FILE) var path: String = "" setget set_path, get_path
export (Resource) var res: Resource = null setget set_res, get_res

var _source: int = Source.NONE

var _script_map: Dictionary = {}
var _path_map: Dictionary = {}
var _deep_type_map: Dictionary = {}
var _deep_path_map: Dictionary = {}

var _script_map_dirty: bool = true
var _is_filesystem_connected: bool = false

func _init(p_input = null, p_generate_deep_map: bool = true, p_duplicate_maps: bool = true) -> void :
	if p_generate_deep_map:
		_fetch_deep_type_map()
	match typeof(p_input):
		TYPE_OBJECT:
			if p_input is (get_script() as Script):
				self.name = p_input.name
				if p_duplicate_maps:
					_script_map = p_input._script_map.duplicate()
					_path_map = p_input._path_map.duplicate()
					_deep_type_map = p_input._deep_type_map.duplicate()
					_deep_path_map = p_input._deep_path_map.duplicate()
				else:
					_script_map = p_input._script_map
					_path_map = p_input._path_map
					_deep_type_map = p_input._deep_type_map
					_deep_path_map = p_input._deep_path_map
				return
			_init_from_object(p_input)
			_connect_script_updates()
		TYPE_STRING:
			if ResourceLoader.exists(p_input):
				_init_from_path(p_input)
				_connect_script_updates()
			else:
				_init_from_name(p_input)
				_connect_script_updates()
	return





func to_string():
	if name:
		return name
	if res:
		var named_path = namify_path(res.resource_path)
		if res is PackedScene:
			named_path += "Scn"
		return named_path
	return ""













func get_script_classes() -> Dictionary:
	_fetch_script_map()
	return _script_map





func get_path_map() -> Dictionary:
	_fetch_script_map()
	return _path_map



func get_deep_type_map() -> Dictionary:
	_fetch_deep_type_map()
	return _deep_type_map



func get_deep_path_map() -> Dictionary:
	_fetch_deep_type_map()
	return _deep_path_map



func refresh_script_classes() -> void :
	_script_map = _get_script_map()
	_build_path_map()



func refresh_deep_type_map() -> void :
	_deep_type_map = _get_deep_type_map()
	_build_deep_path_map()



func is_type(p_other) -> bool:
	match _source:
		Source.NONE:
			return false
		Source.ENGINE:
			if typeof(p_other) == TYPE_OBJECT and p_other.get_script() == get_script():
				return static_is_type(name, p_other.name, _get_map())
			return static_is_type(name, p_other, _get_map())
	if typeof(p_other) == TYPE_OBJECT:
		match p_other.get_class():
			"Script", "PackedScene":
				pass
			_:
				if p_other.get_script() == get_script():
					if res:
						return static_is_type(res, p_other.res, _get_map())
					return static_is_type(name, p_other.name, _get_map())

				var other = from_object(p_other)
				if other.res:
					return static_is_type(res, other.res, _get_map())
	return static_is_type(res, p_other, _get_map())



func instance() -> Object:
	if _source == Source.ENGINE:
		return ClassDB.instance(name)
	if res:
		if res is Script:
			return res.new()
		if res is PackedScene:
			return res.instance()
	return null



func get_engine_class() -> String:
	if Source.ENGINE == _source:
		return name
	if res:
		if res is Script:
			return (res as Script).get_instance_base_type()
		if res is PackedScene:
			var state: = (res as PackedScene).get_state()
			return state.get_node_type(0)
	return ""



func get_script_class() -> String:
	match _source:
		Source.ENGINE:
			return ""
	var script: Script = null
	if res:
		var scene: = res as PackedScene
		if scene:
			script = _scene_get_root_script(scene)
		elif res is Script:
			script = res as Script
	_fetch_script_map()
	while script:
		if _path_map.has(script.resource_path):
			return _path_map[script.resource_path]
		script = script.get_base_script()
	return ""



func get_type_class() -> String:
	var ret: = get_script_class()
	if not ret:
		ret = get_engine_class()
	return ret



func class_exists() -> bool:
	return _source != Source.NONE





func path_exists() -> bool:
	return ResourceLoader.exists(path)



func is_valid() -> bool:
	return class_exists() or path_exists()



func is_non_class_res() -> bool:
	return path_exists() and not class_exists()



func as_script() -> Script:
	return res as Script



func as_scene() -> PackedScene:
	return res as PackedScene



func get_engine_parent() -> Reference:
	var ret: = _new()
	if _source == Source.SCRIPT:
		ret.name = get_engine_class()
	elif _source == Source.ENGINE:
		ret.name = ClassDB.get_parent_class(name)
	return ret



func get_script_parent() -> Reference:
	var ret: = _new()
	if _source == Source.ENGINE:
		ret.name = ""
	elif res:
		var scene: = res as PackedScene
		if scene:
			var script: = _scene_get_root_script(scene)
			ret._init_from_object(script)
		else:
			var script: = res as Script
			if script:
				ret._init_from_object(script.get_base_script())
			else:
				ret.path("")

	return ret



func get_scene_parent() -> Reference:
	var ret: = _new()
	match _source:
		Source.ENGINE, Source.SCRIPT:
			return ret
	var scene: = res as PackedScene
	scene = _scene_get_root_scene(scene)
	ret.res = scene
	return ret



func get_type_parent() -> Reference:
	var ret = get_scene_parent()
	if ret.is_valid():
		return ret
	ret = get_script_parent()
	if ret.is_valid():
		return ret
	return get_engine_parent()



















func become_parent() -> bool:
	if not res:
		if not name:
			return true
		name = ClassDB.get_parent_class(name)
		return ClassDB.class_exists(name)
	var scene: = res as PackedScene
	if scene:
		var base: = _scene_get_root_scene(scene)
		if base:
			self.res = base
			return true
		var script: = _scene_get_root_script(scene)
		if script:
			self.res = script
			return true
	return false




func get_type_script() -> Script:
	var scene: = res as PackedScene
	var script: Script = null
	if scene:
		script = _scene_get_root_script(scene)
	if not script:
		script = res as Script
	return script




func can_instance() -> bool:
	if _source == Source.ENGINE:
		return ClassDB.can_instance(name)
	var script = get_type_script()
	if script:
		return script.can_instance()
	return false


func is_object_instance_of(p_object) -> bool:
	var ct = from_object(p_object)
	return is_type(ct)




func get_inheritors_list() -> PoolStringArray:
	var class_list = get_class_list()
	var ret: = PoolStringArray()
	for a_class in class_list:
		if a_class != name and static_is_type(a_class, name, _get_map()):
			ret.append(a_class)
	return ret



func get_deep_inheritors_list() -> PoolStringArray:
	_fetch_deep_type_map()
	var class_list: = PoolStringArray(_deep_type_map.keys())
	var ret: = PoolStringArray()
	for a_class in class_list:
		if a_class != name and static_is_type(a_class, name, _get_map()):
			ret.append(a_class)
	return ret



func get_engine_class_list() -> PoolStringArray:
	return ClassDB.get_class_list()



func get_script_class_list() -> PoolStringArray:
	_fetch_script_map()
	return PoolStringArray(_script_map.keys())



func get_class_list() -> PoolStringArray:
	var class_list: = PoolStringArray()
	class_list.append_array(get_engine_class_list())
	class_list.append_array(get_script_class_list())
	return class_list



func get_deep_class_list() -> PoolStringArray:
	_fetch_deep_type_map()
	var class_list: = PoolStringArray(_deep_type_map.keys())
	class_list.append_array(PoolStringArray(get_engine_class_list()))
	return class_list



func _get_map() -> Dictionary:
	var map: = {}
	
	if not _deep_type_map.empty():
		map = _deep_type_map
	
	if map.empty():
		_fetch_script_map()
		map = _script_map
	return map



static func static_get_engine_class_list() -> PoolStringArray:
	return ClassDB.get_class_list()



static func static_get_script_class_list() -> PoolStringArray:
	return PoolStringArray(_get_script_map().keys())



static func static_get_class_list() -> PoolStringArray:
	var class_list: = PoolStringArray()
	class_list.append_array(static_get_engine_class_list())
	class_list.append_array(static_get_script_class_list())
	return class_list



static func static_get_deep_class_list() -> PoolStringArray:
	var _deep_type_map = _get_deep_type_map()
	var class_list: = PoolStringArray(_deep_type_map.keys())
	class_list.append_array(static_get_engine_class_list())
	return class_list



static func static_is_object_instance_of(p_object, p_type, p_map: Dictionary = {}) -> bool:
	if not p_object or typeof(p_object) != TYPE_OBJECT:
		return false
	var node: = p_object as Node
	var map = p_map
	if map.empty():
		map = _get_script_map()
	if node and node.filename:
		return static_is_type(load(node.filename), p_type, map)
	var script: = p_object.get_script() as Script
	if script:
		return static_is_type(script, p_type, map)
	return static_is_type(p_object.get_class(), p_type, map)








static func static_is_type(p_type, p_other, p_map: Dictionary = {}) -> bool:
	if not p_type:
		return false
	var map = {}
	if p_map.empty():
		map = _get_script_map()
	else:
		map = p_map

	match typeof(p_type):
		
		TYPE_STRING:

			
			if ClassDB.class_exists(p_type) and ClassDB.class_exists(p_other):
				return ClassDB.is_parent_class(p_type, p_other)

			
			
			
			
			
			
			var res_type: = _convert_name_to_res(p_type, map)
			if res_type:
				return static_is_type(res_type, p_other, map)

			return false

		TYPE_OBJECT:

			match typeof(p_other):
				
				
				
				
				
				
				TYPE_STRING:

					if ClassDB.class_exists(p_other):
						if p_type is PackedScene:
							return _scene_is_engine(p_type, p_other)
						elif p_type is Script:
							return _script_is_engine(p_type, p_other)

					var res_other: = _convert_name_to_res(p_other, map)
					if res_other:
						return static_is_type(p_type, res_other, map)

				
				
				
				
				
				
				TYPE_OBJECT:

					if p_type is PackedScene:
						if p_other is PackedScene:
							return _scene_is_scene(p_type, p_other)
						elif p_other is Script:
							return _scene_is_script(p_type, p_other)
					elif p_type is Script:
						if p_other is PackedScene:
							return _script_is_scene(p_type, p_other)
						elif p_other is Script:
							return _script_is_script(p_type, p_other)
	return false



static func from_name(p_name: String) -> Reference:
	var ret: = _new()
	ret._init_from_name(p_name)
	return ret



static func from_path(p_path: String) -> Reference:
	var ret: = _new()
	ret._init_from_path(p_path)
	return ret



static func from_object(p_object: Object) -> Reference:
	var ret: = _new()
	ret._init_from_object(p_object)
	return ret



static func from_type_dict(p_data: Dictionary) -> Reference:
	var ret: = _new()
	match p_data.type:
		"Engine":
			ret._init_from_name(p_data.name)
		"Script", "PackedScene":
			ret._init_from_path(p_data.path)
	return ret



static func namify_path(p_path: String) -> String:
	var p: = p_path.get_file().get_basename()
	while p != p.get_basename():
		p = p.get_basename()
	return p.capitalize().replace(" ", "")



func _init_from_name(p_name: String) -> void :
	name = p_name
	if ClassDB.class_exists(p_name):
		path = ""
		res = null
		_source = Source.ENGINE
		return
	_fetch_script_map()
	if _deep_type_map.has(p_name):
		path = _deep_type_map[p_name].path
		res = load(path)
		_source = Source.ANONYMOUS
		if _script_map.has(p_name):
			_source = Source.SCRIPT
		return
	if _script_map.has(p_name):
		path = _script_map[p_name].path
		res = load(path)
		_source = Source.SCRIPT
		return

	path = ""
	res = null
	_source = Source.NONE
	_connect_script_updates()



func _init_from_path(p_path: String) -> void :
	path = p_path
	res = load(path) if ResourceLoader.exists(path) else null
	_fetch_script_map()
	if not _deep_path_map.empty() and _deep_path_map.has(p_path):
		name = _deep_path_map[p_path]
		_source = Source.ANONYMOUS
		if _script_map.has(name):
			_source = Source.SCRIPT
		return
	if _path_map.has(p_path):
		name = _path_map[p_path]
		_source = Source.SCRIPT
		return
	name = ""
	_source = Source.NONE
	_connect_script_updates()













func _init_from_object(p_object: Object) -> void :
	var initialized: bool = false
	if not p_object:
		name = ""
		path = ""
		res = null
		_source = Source.NONE
		initialized = true
	var n: = p_object as Node
	if not initialized and n and n.filename:
		_init_from_path(n.filename)
		initialized = true
	var s: = (p_object.get_script() as Script) if p_object else null
	if not initialized and s:
		if not s.resource_path:
			res = s
			path = ""
			name = ""
			_source = Source.ANONYMOUS
		else:
			_init_from_path(s.resource_path)
		initialized = true
	if not initialized and (p_object is PackedScene or p_object is Script):
		_init_from_path((p_object as Resource).resource_path)
		initialized = true
	if not initialized and not path and not name:
		_init_from_name(p_object.get_class())
		initialized = true
	_connect_script_updates()


func _connect_script_updates() -> void :
	if Engine.editor_hint and not _is_filesystem_connected:
		var ep: EditorPlugin = EditorPlugin.new()
		var fs: EditorFileSystem = ep.get_editor_interface().get_resource_filesystem()
		if not fs.is_connected("filesystem_changed", self, "set"):
			
			fs.connect("filesystem_changed", self, "set", ["_script_map_dirty", true])
		ep.free()
		_is_filesystem_connected = true



func _fetch_script_map() -> void :
	if _script_map_dirty:
		_script_map = _get_script_map()
		_build_path_map()
		_script_map_dirty = false



func _build_path_map() -> void :
	_path_map = _get_path_map(_script_map)



static func _get_path_map(p_script_map: Dictionary) -> Dictionary:
	var _path_map = {}
	for a_name in p_script_map:
		_path_map[p_script_map[a_name].path] = a_name
	return _path_map



static func _get_script_map() -> Dictionary:
	var script_classes: Array = ProjectSettings.get_setting("_global_script_classes") as Array if ProjectSettings.has_setting("_global_script_classes") else []
	var script_map: = {}
	for a_class in script_classes:
		script_map[a_class["class"]] = a_class
	return script_map



func _fetch_deep_type_map() -> void :
	if _deep_type_map.empty():
		_deep_type_map = _get_deep_type_map()
		_build_deep_path_map()



func _build_deep_path_map() -> void :
	_deep_path_map = _get_deep_path_map(_deep_type_map)


func _get_deep_path_map(p_deep_type_map: Dictionary) -> Dictionary:
	var _deep_path_map = {}
	for a_name in p_deep_type_map:
		_deep_path_map[p_deep_type_map[a_name].path] = a_name
	return _deep_path_map



static func _get_deep_type_map() -> Dictionary:
	var _script_map = _get_script_map()
	var _path_map = _get_path_map(_script_map)
	var dirs = ["res://"]
	var first = true
	var data = {}

	
	
	var exts = {}
	var res_types = ["Script", "PackedScene"]
	for a_type in res_types:
		for a_ext in ResourceLoader.get_recognized_extensions_for_type(a_type):
			exts[a_ext] = a_type
	exts.erase("res")
	exts.erase("tres")

	
	while not dirs.empty():
		var dir = Directory.new()
		var dir_name = dirs.back()
		dirs.pop_back()

		if dir.open(dir_name) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name:
				if not dir_name == "res://":
					first = false
				
				if not file_name.begins_with("."):
					
					if dir.current_is_dir():
						dirs.push_back(dir.get_current_dir().plus_file(file_name))
					
					
					elif not data.has(file_name) and exts.has(file_name.get_extension()):
						var a_path = dir.get_current_dir() + ("/" if not first else "") + file_name

						var existing_name = _path_map[a_path] if _path_map.has(a_path) else ""
						var a_name = namify_path(file_name)
						a_name = a_name.replace("2d", "2D").replace("3d", "3D")

						if data.has(existing_name) and existing_name == a_name:
							file_name = dir.get_next()
							continue
						elif existing_name:
							a_name = existing_name

						data[a_name] = {
							"name": a_name, 
							"path": a_path, 
							"type": exts[file_name.get_extension()]
						}
				
				file_name = dir.get_next()
			
			dir.list_dir_end()

	return data



static func _get_script() -> Script:
	return load("res://addons/godot-next/references/class_type.gd") as Script



static func _new() -> Reference:
	return (_get_script()).new() as Reference



static func _script_is_engine(p_script: Script, p_class: String) -> bool:
	return ClassDB.is_parent_class(p_script.get_instance_base_type(), p_class)



static func _script_is_script(p_script: Script, p_other: Script) -> bool:
	var script = p_script
	while script:
		if script == p_other:
			return true
		script = script.get_base_script()
	return false



static func _script_is_scene(p_script: Script, p_scene: PackedScene) -> bool:
	var state: = p_scene.get_state()
	for prop_index in range(state.get_node_property_count(0)):
		if state.get_node_property_name(0, prop_index) == "script":
			var script: = state.get_node_property_value(0, prop_index) as Script
			return _script_is_script(p_script, script)
	return false



static func _scene_is_engine(p_scene: PackedScene, p_class: String) -> bool:
	return ClassDB.is_parent_class(p_scene.get_state().get_node_type(0), p_class)



static func _scene_is_script(p_scene: PackedScene, p_script: Script) -> bool:
	if not p_scene or not p_script:
		return false
	var script: = _scene_get_root_script(p_scene)
	if not script:
		return false
	return _script_is_script(script, p_script)



static func _scene_is_scene(p_scene: PackedScene, p_other: PackedScene) -> bool:
	if not p_scene or not p_other:
		return false
	if p_scene == p_other:
		return true
	var scene: = p_scene
	while scene:
		var state: = scene.get_state()
		var base = state.get_node_instance(0)
		if p_other == base:
			return true
		scene = base
	return false


static func _convert_name_to_res(p_name: String, p_map: Dictionary = {}) -> Resource:
	if not p_name or ClassDB.class_exists(p_name) or p_map.empty() or not p_map.has(p_name):
		return null
	return load(p_map[p_name].path)


static func _convert_name_to_variant(p_name: String, p_map: Dictionary = {}):
	var res = _convert_name_to_res(p_name, p_map)
	if res:
		return res
	if ClassDB.class_exists(p_name):
		return p_name
	return null



static func _scene_get_root_script(p_scene: PackedScene) -> Script:
	var state: = p_scene.get_state()
	while state:
		var prop_count: = state.get_node_property_count(0)
		if prop_count:
			for i in range(prop_count):
				if state.get_node_property_name(0, i) == "script":
					var script: = state.get_node_property_value(0, i) as Script
					return script
		var base: = state.get_node_instance(0)
		if base:
			state = base.get_state()
		else:
			state = null
	return null



static func _scene_get_root_scene(p_scene: PackedScene) -> PackedScene:
	if not p_scene:
		return null
	var state: = p_scene.get_state()
	return state.get_node_instance(0)



func set_name(p_value: String) -> void :
	_init_from_name(p_value)


func get_name() -> String:
	return name



func set_path(p_value: String) -> void :
	_init_from_path(p_value)


func get_path() -> String:
	return path



func set_res(p_value: Resource) -> void :
	if not p_value:
		self.name = ""
	_init_from_object(p_value)


func get_res() -> Resource:
	return res
