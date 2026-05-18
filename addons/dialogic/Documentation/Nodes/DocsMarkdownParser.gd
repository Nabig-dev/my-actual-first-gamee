extends Node

var heading1_font = "res://addons/dialogic/Documentation/Theme/DocumentationH1.tres"
var heading2_font = "res://addons/dialogic/Documentation/Theme/DocumentationH2.tres"
var heading3_font = "res://addons/dialogic/Documentation/Theme/DocumentationH3.tres"
var heading4_font = "res://addons/dialogic/Documentation/Theme/DocumentationH4.tres"
var heading5_font = "res://addons/dialogic/Documentation/Theme/DocumentationH5.tres"

var heading1s = []
var heading2s = []
var heading3s = []
var heading4s = []
var heading5s = []
var result = ""
var bolded = []
var italics = []
var striked = []
var coded = []
var linknames = []
var links = []
var imagenames = []
var imagelinks = []
var lists = []
var underlined = []

var accent_color: = Color()
var sub_accent_color: = Color()

var editor_scale: = 1.0

func set_accent_colors(new_accent_color: Color, new_sub_accent_color: Color) -> void :
	accent_color = new_accent_color
	sub_accent_color = new_sub_accent_color
	

func parse(content: String, file_path: String = "", docs_path: String = ""):
	
	heading1s = []
	heading2s = []
	heading3s = []
	heading4s = []
	heading5s = []
	result = ""
	bolded = []
	italics = []
	striked = []
	coded = []
	linknames = []
	links = []
	imagenames = []
	imagelinks = []
	lists = []
	underlined = []
	
	var parsed_text = content
	
	var regex = RegEx.new()
	
	
	
	
	
	
	regex.compile("\\*\\*(?<boldtext>(\\.|[^(\\*\\*)])*)\\*\\*")
	result = regex.search_all(content)
	if result:
		for res in result:
			parsed_text = parsed_text.replace("**" + res.get_string("boldtext") + "**", "[b]" + res.get_string("boldtext") + "[/b]")

	
	regex.compile("\\_\\_(?<underlinetext>.*)\\_\\_")
	result = regex.search_all(content)
	if result:
		for res in result:
			parsed_text = parsed_text.replace("__" + res.get_string("underlinetext") + "__", "[u]" + res.get_string("underlinetext") + "[/u]")
	
	
	regex.compile("\\*(?<italictext>[^\\*]*)\\*")
	result = regex.search_all(content)
	if result:
		for res in result:
			parsed_text = parsed_text.replace("*" + res.get_string("italictext") + "*", "[i]" + res.get_string("italictext") + "[/i]")

	
	
	regex.compile("~~(?<strikedtext>.*)~~")
	result = regex.search_all(content)
	if result:
		for res in result:
			parsed_text = parsed_text.replace("~~" + res.get_string("strikedtext") + "~~", "[s]" + res.get_string("strikedtext") + "[/s]")
	
	
	regex.compile("(([^`]`)|(```))(?<coded>[^`]+)(?(2)(`)|(```))")
	result = regex.search_all(content)
	if result:
		for res in result:
			if res.get_string().begins_with("```"):
				parsed_text = parsed_text.replace("```" + res.get_string("coded") + "```", "[indent][color=#" + accent_color.lightened(0.6).to_html() + "][code]" + res.get_string("coded") + "[/code][/color][/indent]")
			else:
				parsed_text = parsed_text.replace("`" + res.get_string("coded") + "`", "[color=#" + accent_color.lightened(0.6).to_html() + "][code]" + res.get_string("coded") + "[/code][/color]")
				
	
	
	
	regex.compile("\\n\\s*(?<symbol>[-+*])(?<element>\\s.*)")
	result = regex.search_all(parsed_text)
	if result:
		for res in result:
			var symbol = res.get_string("symbol")
			var element = res.get_string("element")
			if parsed_text.find(symbol + " " + element):
				parsed_text = parsed_text.replace(symbol + " " + element, "[indent]" + symbol + " " + element + "[/indent]")

	
	regex.compile("!\\[(?<imgname>.*)\\]\\((?<imglink>.*)\\)")
	result = regex.search_all(content)
	if result:
		for res in result:
			if res.get_string("imglink") != "":
				imagelinks.append(res.get_string("imglink"))
			if res.get_string("imgname") != "":
				imagenames.append(res.get_string("imgname"))

	
	regex.compile("[^!]\\[(?<linkname>[^\\[]+)\\]\\((?<link>[^\\)]*\\S*?)\\)")
	result = regex.search_all(content)
	if result:
		for res in result:
			if res.get_string("link") != "":
				links.append(res.get_string("link"))
			if res.get_string("linkname") != "":
				linknames.append(res.get_string("linkname"))
	
	
	regex.compile("(?:\\n|^)#(?<heading>[^#\\n]+[^\\n]+)")
	result = regex.search_all(content)
	if result:
		for res in result:
			var heading = res.get_string("heading")
			heading1s.append(heading)
			parsed_text = parsed_text.replace("#" + heading, "[color=#" + accent_color.lightened(0.2).to_html() + "][font=" + heading1_font + "]" + heading.strip_edges() + "[/font][/color]")
	
	
	regex.compile("(?:\\n|^)##(?<heading>[^#\\n]+[^\\n]+)")
	result = regex.search_all(content)
	if result:
		for res in result:
			var heading = res.get_string("heading")
			heading2s.append(heading)
			parsed_text = parsed_text.replace("\n##" + heading, "\n[color=#" + accent_color.lightened(0.5).to_html() + "][font=" + heading2_font + "]" + heading.strip_edges() + "[/font][/color]")
	
	
	regex.compile("(?:\\n|^)###(?<heading>[^#\\n]+[^\\n]+)")
	result = regex.search_all(content)
	if result:
		for res in result:
			var heading = res.get_string("heading")
			parsed_text = parsed_text.replace("\n###" + heading, "\n[color=#" + accent_color.lightened(0.7).to_html() + "][font=" + heading3_font + "]" + heading.strip_edges() + "[/font][/color]")
	
	
	regex.compile("(?:\\n|^)####(?<heading>[^#\\n]+[^\\n]+)")
	result = regex.search_all(content)
	if result:
		for res in result:
			var heading = res.get_string("heading")
			parsed_text = parsed_text.replace("\n####" + heading, "\n[color=#" + accent_color.lightened(0.85).to_html() + "][font=" + heading4_font + "]" + heading.strip_edges() + "[/font][/color]")
	
	
	
	regex.compile("(?:\\n|^)#####(?<heading>[^#\\n]+[^\\n]+)")
	result = regex.search_all(content)
	if result:
		for res in result:
			var heading = res.get_string("heading")
			parsed_text = parsed_text.replace("\n#####" + heading, "\n[color=#" + accent_color.lightened(0.85).to_html() + "][font=" + heading5_font + "]" + heading.strip_edges() + "[/font][/color]")

	for i in links.size():
		parsed_text = parsed_text.replace("[" + linknames[i] + "](" + links[i] + ")", "[color=#" + accent_color.to_html() + "][url=" + links[i] + "]" + linknames[i] + "[/url][/color]")
	
	for i in imagenames.size():
		var imagelink_to_use = imagelinks[i]
		if imagelink_to_use.begins_with("http"):
			var path_parts = imagelink_to_use.split("/Documentation/")
			if path_parts.size() > 1:
				imagelink_to_use = docs_path + "/" + path_parts[1]
			else:
				imagelink_to_use = "icon.png"
		if imagelink_to_use.begins_with(".") and file_path:
			imagelink_to_use = file_path.trim_suffix(file_path.get_file()).trim_suffix("/") + imagelink_to_use.trim_prefix(".")
		parsed_text = parsed_text.replace("![" + imagenames[i] + "](" + imagelinks[i] + ")", "[img=" + str(int(700 * editor_scale)) + "]" + imagelink_to_use + "[/img]")
	
	parsed_text += "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
	
	return parsed_text
