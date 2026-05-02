extends Label

signal font_replaced

var fnt_replace = preload("res://assets/tres/fonts/venice_replace.tres")

export var outline_size: int = 1
export var outline_color: Color = Color.red

func _ready() -> void :
	
	var lang: String = Config.get_value("gameplay", "lang", "en")
	if lang != "en":
		fnt_replace = fnt_replace.duplicate()
		fnt_replace.outline_size = outline_size
		fnt_replace.outline_color = outline_color
		add_font_override("font", fnt_replace)
		emit_signal("font_replaced")
