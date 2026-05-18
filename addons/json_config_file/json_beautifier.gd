








class_name JSONBeautifier





static func beautify_json(json: String, spaces: = 0) -> String:
	var error_message: String = validate_json(json)
	if not error_message.empty():
		return error_message

	var indentation: = ""
	if spaces > 0:
		for i in spaces:
			indentation += " "
	else:
		indentation = "\t"

	var quotation_start: = - 1
	var char_position: = 0
	for i in json:
		
		
		if i == "," and char_position + 1 == json.length():
			break
	
		
		if i == "\"":
			if quotation_start == - 1:
				quotation_start = char_position
			elif json[char_position - 1] != "\\":
				quotation_start = - 1

			char_position += 1

			continue
		elif quotation_start != - 1:
			char_position += 1

			continue

		match i:
			
			" ", "\n", "\t":
				json[char_position] = ""
				char_position -= 1
			"{", "[", ",":
				if json[char_position + 1] != "}" and \
				json[char_position + 1] != "]":
					json = json.insert(char_position + 1, "\n")
					char_position += 1
			"}", "]":
				if json[char_position - 1] != "{" and \
				json[char_position - 1] != "[":
					json = json.insert(char_position, "\n")
					char_position += 1
			":":
				json = json.insert(char_position + 1, " ")
				char_position += 1
		
		char_position += 1

	for i in [["{", "}"], ["[", "]"]]:
		var bracket_start: int = json.find(i[0])
		while bracket_start != - 1:
			var bracket_end: int = json.find("\n", bracket_start)
			var bracket_count: = 0
			while bracket_end != - 1:
				if json[bracket_end - 1] == i[0]:
					bracket_count += 1
				elif json[bracket_end + 1] == i[1]:
					bracket_count -= 1

				
				while json[bracket_end + 1] == indentation[0]:
					bracket_end += 1

					if json[bracket_end + 1] == i[1]:
						bracket_count -= 1

				if bracket_count <= 0:
					break

				bracket_end = json.find("\n", bracket_end + 1)

			
			bracket_end = json.rfind("\n", json.rfind("\n", bracket_end) - 1)
			while bracket_end > bracket_start:
				json = json.insert(bracket_end + 1, indentation)
				bracket_end = json.rfind("\n", bracket_end - 1)

			bracket_start = json.find(i[0], bracket_start + 1)

	return json




static func uglify_json(json: String) -> String:
	var quotation_start: = - 1
	var char_position: = 0
	for i in json:
		
		if i == "\"":
			if quotation_start == - 1:
				quotation_start = char_position
			elif json[char_position - 1] != "\\":
				quotation_start = - 1

			char_position += 1

			continue
		elif quotation_start != - 1:
			char_position += 1

			continue

		if i == " " or i == "\n" or i == "\t":
			json[char_position] = ""
			char_position -= 1

		char_position += 1

	return json
