tool 
extends Reference
class_name CSVLoader

static func load_csv_translation(filepath: String, conf: ConfigFile) -> Dictionary:
	
	var f_cell: String = conf.get_value("csv", "f_cell", "keys")
	var delimiter: String = conf.get_value("csv", "delimiter", ",")

	var f: = File.new()
	var err: = f.open(filepath, File.READ)

	if err != OK:
		return {"TMERROR": "Can't open file: {0}, code {1}".format([filepath, err])}
	
	var first_row: = f.get_csv_line(delimiter)

	if first_row[0] != f_cell:
		return {"TMERROR": "Translation file is missing the `id` (f_cell) column"}
	
	var languages: = PoolStringArray()
	for i in range(1, len(first_row)):
		languages.append(first_row[i])
	
	var ids: = []
	var rows: = []
	while not f.eof_reached():
		var row: = f.get_csv_line(delimiter)
		if len(row) < 1 or row[0].strip_edges() == "":
			
			continue
		if len(row) < len(first_row):
			
			row.resize(len(first_row))
		ids.append(row[0])
		var trans = PoolStringArray()
		for i in range(1, len(row)):
			trans.append(row[i])
		rows.append(trans)
	f.close()
	
	var translations: = {}
	for i in len(ids):
		var t: = {}
		for language_index in len(rows[i]):
			t[languages[language_index]] = rows[i][language_index]
		translations[ids[i]] = t

	
	
	if (
		languages.size() > 0 and translations.empty() == true
	):
		return {"EMPTYTRANSLATIONS": languages}
	
	
	return translations

static func save_csv_translation(
	filepath: String, data: Dictionary, langs: Array, conf: ConfigFile
) -> int:
	
	var f_cell: String = conf.get_value("csv", "f_cell", "keys")
	var delimiter: String = conf.get_value("csv", "delimiter", ",")
	
	
	var f = File.new()
	var err = f.open(filepath, File.WRITE)
	var csv_headers: Array = [f_cell]
	csv_headers.append_array(langs)

	if err != OK:
		OS.alert(
			"Can't open file: {0}, code {1}".format([filepath, err]), 
			"Translation Manager - Error"
		)
		return err
	
	
	f.store_csv_line(csv_headers, delimiter)
	
	
	for str_key in data.keys():
		
		var str_translations: Array = data[str_key].values()
		
		var row_data: Array = [str_key]
		row_data.append_array(str_translations)
		
		f.store_csv_line(row_data, delimiter)

	return OK

