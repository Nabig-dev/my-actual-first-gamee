extends Control

func show_icon(type: String, idframe: int) -> void :
	$SpriteInv.visible = false
	$SpriteEquip.visible = false
	$SpriteTreasure.visible = false
	$SpriteKey.visible = false
	match type:
		"inventory_manager":
			$SpriteInv.visible = true
			$SpriteInv.frame = idframe
		"equip":
			$SpriteEquip.visible = true
			$SpriteEquip.frame = idframe
		"treasure":
			$SpriteTreasure.visible = true
			$SpriteTreasure.frame = idframe
		"key":
			$SpriteKey.visible = true
			$SpriteKey.frame = idframe
