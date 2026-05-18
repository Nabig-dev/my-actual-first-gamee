extends RigidBody2D

signal obtained


export var ide: String

export (
	GVar.INVENTORY_ITEM
) var item = 0

export var not_spawn_if_obtained: bool = true

func _ready() -> void :
	
	if (
		not_spawn_if_obtained == true and 
		VarsGlobal.game_data["flags"].has(ide + "_item_inventory_obtained") == true
	):
		queue_free()
		return
	
	$Sprite.frame = item

func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	Audio.play_sfx("item_pickup")
	
	
	if VarsGlobal.game_data["flags"].has(ide + "_item_inventory_obtained") == false:
		VarsGlobal.game_data["flags"].append(ide + "_item_inventory_obtained")
	
	
	
	if VarsGlobal.game_data["player_inventory"].keys().has(item) == false:
		VarsGlobal.game_data["player_inventory"][item] = 1
	
	
	else:
		VarsGlobal.game_data["player_inventory"][item] += 1
	
	VarsGlobal.GameInterface.show_notif_item_obtained(
		"%s: %s" % [
			tr("OBJECT"), tr(GVar.INVENTORY_ITEM.keys()[item] + "_TITLE")
		]
	)
	
	emit_signal("obtained")
	
	queue_free()
