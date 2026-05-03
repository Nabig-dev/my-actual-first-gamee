extends TextureButton

export (
	GVar.INVENTORY_ITEM
) var item = GVar.INVENTORY_ITEM.POTION_HEALTH

onready var Spr = $Sprite

func _ready() -> void :
	Spr.frame = item
	
	set_disabled(disabled)

func set_disabled(val: bool) -> void :
	if val == true:
		Spr.modulate.a = 0.4
	else:
		Spr.modulate.a = 1.0
