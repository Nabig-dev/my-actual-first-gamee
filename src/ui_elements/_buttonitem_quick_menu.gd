tool 

extends TextureButton

export var item_ide: int = 0 setget update_ide

var amount_item: int = 0

func _ready() -> void :
	
	
	_on_ButtonItem_focus_exited()

func update_ide(ideitem: int) -> void :
	item_ide = ideitem
	get_node("%InventoryItems").frame = item_ide

func update_amount() -> void :

	if VarsGlobal.game_data["player_inventory"].keys().has(item_ide):
		amount_item = VarsGlobal.game_data["player_inventory"][item_ide]
	else:
		amount_item = 0
	
	get_node("%LblAmount").text = str(amount_item)

func _on_ButtonItem_focus_entered() -> void :
	get_node("%InventoryItems").modulate.a = 1
	get_node("%BgUnfocused").visible = false
	
	Audio.play_sfx("ui_changed_value")

func _on_ButtonItem_focus_exited() -> void :
	get_node("%InventoryItems").modulate.a = 0.5
	get_node("%BgUnfocused").visible = true
	
