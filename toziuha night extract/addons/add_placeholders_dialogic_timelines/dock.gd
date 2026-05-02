extends Control


func _on_FileDialog_files_selected(paths: PoolStringArray) -> void :
	
	var F: = File.new()
	var texts: String
	
	for p in paths:
		
		var timeline_id: String
		var dict_data: Dictionary
		var err: int = F.open(p, File.READ)
		
		if err != OK:
			print("(%s) Error: %d" % [p, err])
			return
		
		dict_data = JSON.parse(F.get_as_text()).result
		
		
		timeline_id = dict_data["metadata"]["file"].replace("timeline-", "")
		timeline_id = timeline_id.replace(".json", "")
		
		var i: int = 0
		for e in dict_data["events"]:

			var ev_id: String
			
			match e["event_id"]:
				
				"dialogic_001":
					ev_id = "text"
				
				"dialogic_010":
					ev_id = "question"
				
				"dialogic_011":
					ev_id = "choice"
			
			if ev_id != "":
				
				if e[ev_id] in ["..."]:
					pass
				else:
					var line_key: String = "DLG%d_%s" % [
						i, timeline_id
					]
					var line_text: String = dict_data["events"][i][ev_id]
					
					
					
					
					if "," in line_text or "\"" in line_text:
						line_text = "\"%s\"" % [line_text]
					
					
					dict_data["events"][i][ev_id] = line_key
					
					
					texts = texts + "%s,%s,%s\n" % [
						line_key, 
						line_text, 
						"Placeholder:" + line_key
					]
			
			i += 1

		
		set_json(p, dict_data)
	
	
	
	$MarginContainer / TextEdit.text = texts


func set_json(path: String, data: Dictionary):
	var file = File.new()
	var err = file.open(path, File.WRITE)
	if err == OK:
		file.store_line(JSON.print(data, "\t", true))
		file.close()
	return err

func _on_BtnOpen_pressed() -> void :
	$FileDialog.popup_centered()


func _on_BtnHelp_pressed() -> void :
	OS.alert(
		"Abre el timeline, esto colocará identificadores en el timeline y en el campo de abajo saldrá el texto con los dialogos extraidos para colocar en el csv", 
		"Como usar"
	)
