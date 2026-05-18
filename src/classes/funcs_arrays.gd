extends Node

class_name FuncsArrays

static func get_array_unique(array: Array) -> Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique

static func get_new_position_on_array(
		arr: Array, current_pos: = 0, direction: = "prev"
	) -> int:

	var new_pos: int = 0
	var arr_size: int = arr.size()
	
	
	
	if current_pos == (arr_size - 1) and direction == "next":
		new_pos = 0
	
	
	elif current_pos == 0 and direction == "prev":
		new_pos = arr_size - 1
	
	elif direction == "next":
			new_pos = current_pos + 1
	elif direction == "prev":
		new_pos = current_pos - 1
	
	
	
	if new_pos < 0 or new_pos > (arr_size - 1):
		new_pos = 0
		print_debug("la nueva posicion sobrepasa index del array, regresamos 0")
	
	
	return new_pos

static func is_out_index(arr: Array, idx: int) -> bool:
	if arr.size() - 1 > idx:
		return true
	return false

static func get_flags(string_bin: String) -> Array:
	
	
	var result: Array
	
	
	string_bin = string_bin.replace("*", "")
	
	
	
	for l in string_bin:
		result.append(bool(int(l)))
	
	
	result.invert()
	
	return result

static func shuffle_array_with_seed(arr: Array, seed_string: String) -> Array:
	var _seed = string_to_seed(seed_string)
	var rng = RandomNumberGenerator.new()
	rng.seed = _seed
	
	var shuffled_array = arr.duplicate()
	
	for i in range(shuffled_array.size()):
		var random_index = rng.randi_range(0, i)
		
		var temp = shuffled_array[i]
		shuffled_array[i] = shuffled_array[random_index]
		shuffled_array[random_index] = temp
	
	return shuffled_array

static func string_to_seed(s: String) -> int:
	var hash_value: int = 0
	for i in range(s.length()):
		hash_value = (hash_value * 31 + ord(s[i])) % 2147483647
	return hash_value
