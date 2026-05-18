extends Node

class_name FuncsNumbers


static func add_value(
	add_val: float, val: float, val_max: float
) -> float:
	val += add_val
	
	if val > val_max:
		val = val_max
	return val



static func decrease_value(
	minus_val: float, val: float, minimum: float = 0.0
) -> float:
	val -= minus_val
	
	if val < minimum:
		val = minimum
	return val


static func get_percentage(val: float = 1.0, val_max: float = 1.0) -> float:
	var percent: float = val * (100.0 / val_max)
	return percent



static func dec2bin(decimal_value: int) -> int:
	var binary_string: String
	var temp: int
	var count: int = 31
	
	while (count >= 0):
		temp = decimal_value >> count
		if (temp & 1):
			binary_string = binary_string + "1"
		else:
			binary_string = binary_string + "0"
		count -= 1

	return int(binary_string)
