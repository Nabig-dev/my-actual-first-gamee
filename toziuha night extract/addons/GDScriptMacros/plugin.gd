tool 
extends EditorPlugin


var script_editor: TextEdit
var cursor_line = - 1

var macroStr: = {}
var macroArgs: = {}
var macroPath: = "res://addons/GDScriptMacros/macros.txt"
var macroDate: int

func _input(event: InputEvent) -> void :
	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_SHIFT:
			check_macro(cursor_line)

func check_macro(line: int) -> void :
	var writtenLine: = script_editor.get_line(line)

	var keyword = writtenLine.strip_edges(true, true)
	var splitLine = Array(keyword.split(" ", false))
	
	keyword = splitLine.pop_front()
	var givenArgs = splitLine
	
	if macroStr.has(keyword):
		
		if givenArgs.size() != macroArgs[keyword].size(): return
		
		var constructLine = writtenLine
		var indent = get_indentation(writtenLine)
		constructLine = indent + macroStr[keyword]
		
		constructLine = constructLine.replace("\n", "\n" + indent)
		
		if macroArgs.has(keyword):
			for i in givenArgs.size():
				constructLine = constructLine.replace(macroArgs[keyword][i], givenArgs[i])
		
		script_editor.set_line(line, constructLine)
		
		
		if constructLine.ends_with("\n"):
			script_editor.cursor_set_line(line + 1)


func get_indentation(string: String) -> String:
	var indentation: = ""
	for i in string:
		if i == "\t" or i == " ":
			indentation += i
		else:
			break
	return indentation


func _init_macro_file() -> void :
	var file: = File.new()

	var date: = file.get_modified_time(macroPath)
	if date == macroDate:
		return
	macroDate = date

	file.open(macroPath, File.READ)
	var keyword: String

	while true:
		var line: = file.get_line()
		if line.begins_with("[macro]"):
			
			if keyword:
				macroStr[keyword] = macroStr[keyword].trim_suffix("\n")
			
			keyword = line.trim_prefix("[macro]")
			
			var splitLine: Array = Array(keyword.split(" ", false))
			keyword = splitLine.pop_front()
			
			macroArgs[keyword] = []
			for i in splitLine:
				macroArgs[keyword].append(i)
			
			macroStr[keyword] = ""
		else:
			if not file.eof_reached():
				if keyword:
					macroStr[keyword] += line + "\n"
			else:
				if keyword:
					macroStr[keyword] += line
				break
	file.close()


func _ready():
	get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_changed")
	_init_macro_file()


func _notification(what: int):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		_init_macro_file()


func _on_cursor_changed():
	if is_instance_valid(script_editor):
		if cursor_line != script_editor.cursor_get_line():
			check_macro(cursor_line)
			cursor_line = script_editor.cursor_get_line()

func _on_gui_focus_changed(node: Node):
	if node is TextEdit:
		if is_instance_valid(script_editor):
			script_editor.disconnect("cursor_changed", self, "_on_cursor_changed")
		script_editor = node
		script_editor.connect("cursor_changed", self, "_on_cursor_changed")
