tool 
class_name CallbackDelegator
extends Node






























var _elements: ResourceSet = ResourceSet.new()


var _callbacks: Dictionary = {
	"_enter_tree": {}, 
	"_exit_tree": {}, 
	"_ready": {}, 
	"_process": {}, 
	"_physics_process": {}, 
	"_input": {}, 
	"_unhandled_input": {}, 
	"_unhandled_key_input": {}
}


var _class_type: ClassType = ClassType.new()

func _ready() -> void :
	_handle_notification("_ready")



func _enter_tree() -> void :
	var elements = _elements.get_data().values()
	for an_element in elements:
		if not an_element.owner:
			_initialize_element(an_element)
	_check_for_empty_callbacks()

	_handle_notification("_enter_tree")


func _exit_tree() -> void :
	_handle_notification("_exit_tree")


func _process(delta: float) -> void :
	_handle_notification("_process", delta)


func _physics_process(delta: float) -> void :
	_handle_notification("_physics_process", delta)


func _input(event: InputEvent) -> void :
	_handle_notification("_input", event)


func _unhandled_input(event: InputEvent) -> void :
	_handle_notification("_unhandled_input", event)


func _unhandled_key_input(event: InputEventKey) -> void :
	_handle_notification("_unhandled_key_input", event)




func add_element(p_type: Script) -> Resource:
	var elements = _elements.get_data()

	_class_type.res = p_type
	if not _class_type.is_type(_elements.get_base_type()):
		return null
	if has_element(p_type):
		return get_element(p_type)

	var element: Resource = p_type.new()

	elements[_class_type.get_script_class()] = element
	_initialize_element(element)

	return element



func get_element(p_type: Script) -> Resource:
	var elements = _elements.get_data()
	_class_type.res = p_type
	return elements.get(_class_type.get_script_class(), null)



func has_element(p_type: Script) -> bool:
	var elements = _elements.get_data()
	_class_type.res = p_type
	return elements.has(_class_type.get_script_class())




func remove_element(p_type: Script) -> bool:
	var elements = _elements.get_data()
	var element = get_element(p_type)
	if element:
		_remove_from_callbacks(element)
		_class_type.res = p_type
		return elements.erase(_class_type.get_script_class())
	return false



func get_element_types() -> Array:
	return _elements.get_data().keys()



func get_elements() -> Array:
	return _elements.get_data().values()


func _parse_property(p_inspector: EditorInspectorPlugin, p_pinfo: PropertyInfo) -> void :
	match p_pinfo.name:
		"_elements":
			p_inspector.add_custom_control(InspectorControls.new_button("Initialize Default Behavior", false, self, "_set_base_type_behavior"))


func _get_property_list() -> Array:
	return [PropertyInfoFactory.new_resource("_elements").to_dict()]



func _handle_notification(p_name: String, p_param = null) -> void :
	if Engine.editor_hint:
		return
	if p_param:
		for an_element in _callbacks[p_name]:
			an_element.call(p_name, p_param)
	else:
		for an_element in _callbacks[p_name]:
			an_element.call(p_name)



func _initialize_element(p_element: Resource) -> void :
	_awake(p_element)
	
	p_element.connect("script_changed", self, "_refresh_callbacks", [p_element])
	_add_to_callbacks(p_element)



func _add_to_callbacks(p_element: Resource) -> void :
	for a_callback in _callbacks:
		if p_element.has_method(a_callback) and p_element.get_enabled():
			_callbacks[a_callback][p_element] = null



func _remove_from_callbacks(p_element: Resource) -> void :
	for a_callback in _callbacks:
		_callbacks[a_callback].erase(p_element)
	_check_for_empty_callbacks()



func _check_for_empty_callbacks() -> void :
	for a_callback in _callbacks:
		match a_callback:
			"_process":
				set_process( not _callbacks[a_callback].empty())
			"_physics_process":
				set_physics_process( not _callbacks[a_callback].empty())
			"_input":
				set_process_input( not _callbacks[a_callback].empty())
			"_unhandled_input":
				set_process_unhandled_input( not _callbacks[a_callback].empty())
			"_unhandled_key_input":
				set_process_unhandled_key_input( not _callbacks[a_callback].empty())



func _awake(p_element: Resource) -> void :
	p_element.owner = self
	if p_element.has_method("_awake"):
		p_element._awake()



func _on_element_script_change(p_element: Resource) -> void :
	_remove_from_callbacks(p_element)
	_add_to_callbacks(p_element)


func _set_base_type_behavior() -> void :
	_class_type.name = "Behavior"
	_elements.set_base_type(_class_type.res)
