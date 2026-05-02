extends TextureRect

export (int, "Active", "Enabled", "Disabled") var type

export (
	GVar.ATTRB_PHYSICAL
) var attrb_physical

onready var SprColor = $Color
onready var SprColorIcon = $ColorIcon
onready var SprGray = $Gray

func _ready() -> void :
	update_icon()

func update_icon() -> void :
	
	SprColor.visible = false
	SprColorIcon.visible = false
	SprGray.visible = false
	
	SprColor.frame = attrb_physical
	SprColorIcon.frame = attrb_physical
	SprGray.frame = attrb_physical
	
	match type:
		0:
			SprColor.visible = true
		1:
			SprColorIcon.visible = true
		2:
			SprGray.visible = true
