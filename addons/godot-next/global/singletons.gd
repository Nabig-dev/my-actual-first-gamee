tool 
class_name Singletons
extends Reference






const SINGLETON_CACHE = preload("res://addons/godot-next/data/singleton_cache.tres")



static func fetch(p_script: Script) -> Object:
	var cache: Dictionary = SINGLETON_CACHE.get_cache()
	if not cache.has(p_script):
		if p_script is Resource:
			var path = _get_persistent_path(p_script)
			if path:
				var paths: Dictionary = SINGLETON_CACHE.get_paths()
				cache[p_script] = ResourceLoader.load(path) if ResourceLoader.exists(path) else p_script.new()
				paths[p_script] = path
			else:
				cache[p_script] = p_script.new()
		else:
			cache[p_script] = p_script.new()
	return cache[p_script]



static func fetchs(p_name: String) -> Object:
	var ct = ClassType.new(p_name)
	if ct.res:
		return fetch(ct.res)
	return null



static func fetch_editor(p_class: GDScriptNativeClass) -> Object:
	if not Engine.editor_hint:
		push_warning("Cannot access '%s' (editor-only class) at runtime." % p_class.get_class())
		return null

	var cache: Dictionary = SINGLETON_CACHE.get_cache()
	if cache.has(p_class):
		return cache[p_class]
	return null



static func erase(p_script: Script) -> bool:
	var cache: Dictionary = SINGLETON_CACHE.get_cache()
	var paths: Dictionary = SINGLETON_CACHE.get_paths()
	var erased = cache.erase(p_script)
	
	paths.erase(p_script)
	return erased


static func save(p_script: Script) -> void :
	var paths: Dictionary = SINGLETON_CACHE.get_paths()
	if not paths.has(p_script):
		return
	var cache: Dictionary = SINGLETON_CACHE.get_cache()
	
	ResourceSaver.save(paths[p_script], cache[p_script])


static func save_all() -> void :
	var cache: Dictionary = SINGLETON_CACHE.get_cache()
	var paths: Dictionary = SINGLETON_CACHE.get_paths()
	for a_script in paths:
		
		ResourceSaver.save(paths[a_script], cache[a_script])


static func _get_persistent_path(p_script: Script):
	return p_script.get("SELF_RESOURCE")



static func _register_editor_singletons(plugin: EditorPlugin):
	var cache: Dictionary = SINGLETON_CACHE.get_cache()

	cache[UndoRedo] = plugin.get_undo_redo()

	cache[EditorInterface] = plugin.get_editor_interface()

	cache[ScriptEditor] = plugin.get_editor_interface().get_script_editor()
	cache[EditorSelection] = plugin.get_editor_interface().get_selection()
	cache[EditorSettings] = plugin.get_editor_interface().get_editor_settings()
	cache[EditorFileSystem] = plugin.get_editor_interface().get_resource_filesystem()
	cache[EditorResourcePreview] = plugin.get_editor_interface().get_resource_previewer()
