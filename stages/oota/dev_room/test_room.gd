extends Node

func _ready() -> void :
	
	
	pass

func hash_word_to_number(word: String = "nabig", element: String = "FE", color: String = "BLACK") -> int:
	var hash_value: int = 0
	
	for c in word + element + color:
		hash_value += ord(c)
	
	var result = hash_value % 4
	return result

