tool 
extends Control

export (bool) var enable_editing = false

export (String) var documentation_path: String = "res://addons/dialogic/Documentation"
var MarkdownParser = load("res://addons/dialogic/Documentation/Nodes/DocsMarkdownParser.gd").new()

var current_path: String = ""
var current_headings = []

onready var Content = $Content

signal open_non_html_link(link, section)












func load_page(page_path: String, section: String = ""):
	Content.set("custom_styles/normal", StyleBoxEmpty.new())
	Content.get("custom_styles/normal").content_margin_left = 15
	Content.get("custom_styles/normal").content_margin_top = 15
	Content.get("custom_styles/normal").content_margin_right = 15
	Content.get("custom_styles/normal").content_margin_bottom = 15
	
	var base_size = 16
	Content.set("custom_fonts/normal_font/size", int(base_size * get_constant("scale", "Editor")))
	Content.set("custom_fonts/bold_font/size", int(base_size * get_constant("scale", "Editor")))
	
	Content.set("custom_fonts/mono_font/size", int(base_size * get_constant("scale", "Editor")))
	Content.set("custom_fonts/bold_italics_font/size", int(base_size * get_constant("scale", "Editor")))
	
	
	
	Content.set("custom_fonts/mono_font", get_font("doc_source", "EditorFonts"))
	Content.set("custom_fonts/bold_font", Content.get_font("doc_bold", "EditorFonts"))
	
	MarkdownParser.set_accent_colors(get_color("accent_color", "Editor"), get_color("disabled_font_color", "Editor"))
	
	if page_path == "" and not section:
		return
	
	show()
	_on_Content_resized()
	
	
	
	if page_path.count("#") > 0:
		var result = page_path.split("#")
		page_path = result[0]
		section = "#" + result[1]
	
	
	if not page_path.begins_with("res://"):
		page_path = documentation_path + "/Content/" + page_path
	if not page_path.ends_with(".md"):
		page_path += ".md"
	
	
	var f = File.new()
	f.open(page_path, File.READ)
	current_path = page_path
	
	
	Content.bbcode_text = MarkdownParser.parse(f.get_as_text(), current_path, documentation_path)
	f.close()
	
	
	current_headings = MarkdownParser.heading1s + MarkdownParser.heading2s + MarkdownParser.heading3s + MarkdownParser.heading4s + MarkdownParser.heading5s
	create_content_menu(MarkdownParser.heading1s + MarkdownParser.heading2s)

	
	if not scroll_to_section(section):
		Content.scroll_to_line(0)
	
	
	yield(get_tree(), "idle_frame")
	_on_Up_pressed()



func scroll_to_section(title):
	if not title:
		return
	
	for heading in current_headings:
		if (heading.to_lower().strip_edges().replace(" ", "-") == title.replace("#", "")) or \
		(heading.to_lower().strip_edges() == title.to_lower().strip_edges()):
			var x = Content.bbcode_text.find(heading.replace("#", "").strip_edges() + "[/font]")
			x = Content.bbcode_text.count("\n", 0, x)
			Content.scroll_to_line(x)
			
			$ContentMenu / Panel.hide()
			
			return true
	





func _ready():
	$Up.icon = get_icon("ArrowUp", "EditorIcons")
	
	$Editing.visible = enable_editing
	


func create_content_menu(headings):
	for child in $ContentMenu / Panel / VBox.get_children():
		child.queue_free()
	if len(headings) < 2:
		$ContentMenu.hide()
		return
	$ContentMenu.show()
	headings.pop_front()
	for heading in headings:
		var button = Button.new()
		button.set("custom_styles/normal", get_stylebox("sub_inspector_bg0", "Editor"))
		button.text = heading
		button.align = Button.ALIGN_LEFT
		button.connect("pressed", self, "content_button_pressed", [heading])
		$ContentMenu / Panel / VBox.add_child(button)


func content_button_pressed(heading):
	scroll_to_section(heading)
	$ContentMenu / ToggleContents.pressed = false



func _on_meta_clicked(meta):
	
	if meta.begins_with("http"):
		
		
		if meta.count("Documentation/Content") > 0:
			meta = meta.split("Documentation/Content")[1]
		
		
		else:
			OS.shell_open(meta)
			return
	
	
	if meta.begins_with("#"):
		
		scroll_to_section(meta)
	
	
	else:
		
		var link = meta
		var section = null
		if meta.count("#") > 0:
			var split = meta.split("#")
			link = split[0]
			section = split[1]
		if link.begins_with("."):
			link = current_path.trim_suffix(current_path.get_file()).trim_suffix("/") + link.trim_prefix(".")
		if not link.begins_with("res://"):
			link = documentation_path.plus_file("Content").plus_file(link)
		if not link.ends_with(".md"):
			link += ".md"

		emit_signal("open_non_html_link", link, section)


func _on_EditPage_pressed():
	var x = File.new()
	x.open(current_path, File.READ)
	OS.shell_open(x.get_path_absolute())


func _on_RefreshPage_pressed():
	load_page(current_path)


func _on_Up_pressed():
	Content.scroll_to_line(0)


func _on_ToggleContents_toggled(button_pressed):
	$ContentMenu / Panel.visible = button_pressed

func toggle_editing():
	enable_editing = not enable_editing
	$Editing.visible = enable_editing

func _on_Content_resized():
	if not Content: return
	if Content.rect_size.x < 500:
		Content.get("custom_styles/normal").content_margin_left = 15
		Content.get("custom_styles/normal").content_margin_right = 15
	else:
		Content.get("custom_styles/normal").content_margin_left = (Content.rect_size.x - 500) / 4
		Content.get("custom_styles/normal").content_margin_right = (Content.rect_size.x - 500) / 3
	Content.update()
