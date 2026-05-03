tool 
class_name ArrayMap
extends Resource












var values: = []
var keys: = {}


export var name: = ""



var _type: = TYPE_NIL
var _hint: = PROPERTY_HINT_NONE
var _hint_string: = ""


func _init(p_name: String = "") -> void :
	name = p_name


func has(p_key: String) -> bool:
	return keys.has(p_key)



func insert(p_key: String, p_value) -> void :
	if not keys:
		
		_type = typeof(p_value)
		if _type == TYPE_OBJECT and p_value is Resource:
			_hint = PROPERTY_HINT_RESOURCE_TYPE
			_hint_string = p_value.get_class()
		elif _type == TYPE_ARRAY:
			_hint = 24
			_hint_string = str(typeof(p_value)) + ":"

	if keys.has(p_key):
		values[keys[p_key]] = p_value
	else:
		keys[p_key] = values.size()
		values.append(p_value)


func erase(p_key: String) -> void :
	assert (keys.has(p_key))
	values.remove(keys[p_key])
	
	keys.erase(p_key)



func get_value(p_key: String):
	assert (keys.has(p_key))
	return values[keys[p_key]]



func find(p_value) -> String:
	for i in values.size():
		if p_value == values[i]:
			for a_key in keys:
				if keys[a_key] == i:
					return a_key as String
	return ""



func keys() -> Array:
	return keys.keys()



func values_ref() -> Array:
	return values



func dict() -> Dictionary:
	var ret: = {}
	for a_key in keys:
		ret[a_key] = values[keys[a_key]]
	return ret


func clear() -> void :
	values.clear()
	keys.clear()



func _get_property_list():
	var ret: = []
	for i in values.size():
		ret.append({
			"name": "values/" + str(i), 
			"type": _type, 
			"hint": _hint, 
			"hint_string": _hint_string, 
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		})
	for a_key in keys:
		ret.append({
			"name": "keys/" + str(a_key), 
			"type": TYPE_INT, 
			"hint": PROPERTY_HINT_NONE, 
			"hint_string": "_hint_string", 
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		})
	return ret



func _get(p_name: String):
	if p_name.begins_with("values/"):
		var i = int(p_name.replace("values/", ""))
		if i < values.size() and i >= 0:
			return values[i]

	if p_name.begins_with("keys/"):
		var key = p_name.replace("keys/", "")
		if keys.has(key):
			return keys[key]



func _set(p_name: String, p_value):
	if p_name.begins_with("values/"):
		var i = int(p_name.replace("values/", ""))
		if i < values.size() and i >= 0:
			values[i] = p_value
			return true

	if p_name.begins_with("keys/"):
		var key = p_name.replace("keys/", "")
		if keys.has(key):
			keys[key] = p_value
			return true

	return false
