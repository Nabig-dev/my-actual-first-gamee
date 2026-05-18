extends TextureRect

var TextureRed = preload("res://assets/sprites/attributes/elemental_red.png")
var TextureBlue = preload("res://assets/sprites/attributes/elemental_blue.png")
var TextureGray = preload("res://assets/sprites/attributes/elemental_gray.png")
var TextureGreen = preload("res://assets/sprites/attributes/elemental_green.png")

export (int, "None", "Weak", "Strong", "Invulnerable", "Absorb", "Selected") var type

export (
	GVar.ATTRB_ELEMENTAL
) var attrb_elemental

onready var Spr = $Sprite

func _ready() -> void :
	update_icon()

func update_icon() -> void :
	
	Spr.frame = attrb_elemental
	
	match type:
		0:
			Spr.frame = 7
		1:
			Spr.texture = TextureRed
		2:
			Spr.texture = TextureBlue
		3:
			Spr.texture = TextureGray
		4:
			Spr.texture = TextureGreen
		5:
			pass
		
