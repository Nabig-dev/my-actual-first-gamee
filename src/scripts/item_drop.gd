extends Node2D

var Mana = preload("res://src/game_objects/drop_items/mana.tscn")
var Coin = preload("res://src/game_objects/drop_items/money_coin.tscn")
var InventoryItem = preload("res://src/game_objects/drop_items/item_inventory.tscn")
var Alloy = preload("res://src/game_objects/drop_items/alloy_element.tscn")
var Equipment = preload("res://src/game_objects/drop_items/equipment_item.tscn")

var item_instance: Object = null

export var no_drop: bool = false

var drops_list: Dictionary = {
	"none": 0, 
	"mana": 0, 
	"mana_double": 0, 
	"coin_1": 0, 
	"coin_5": 0, 
	"coin_50": 0, 
	"coin_100": 0, 
}

var drops_list_from_db: String = "*"

func _ready() -> void :
	if drops_list_from_db == "*":
		update_drop_list()

func update_drop_list() -> void :
	
	if drops_list_from_db != "*":
		
		drops_list = {"none": 1}
		
		var dr_list: Array = drops_list_from_db.split(",")
		for dr_it in dr_list:
			var it: Array = dr_it.split(":")
			drops_list[String(it[0])] = int(it[1])
	
	else:
		drops_list["coin_1"] = 10
		drops_list["coin_5"] = 7
		drops_list["coin_50"] = 3
		drops_list["coin_100"] = 0

func drop() -> void :
	randomize()
	
	
	var bag: = RNGTools.WeightedBag.new()
	var picked: String = ""

	
	

	
	
	for it in drops_list.keys():
		bag.weights[it] = drops_list[it]
	
	picked = RNGTools.pick_weighted(bag)

	if bag.weights.size() == 0:
		return
	
	
	if (
		picked.begins_with("coin")
		and VarsGlobal.game_data["player_mp_now"] < VarsGlobal.game_data["player_mp_max"]
	):
		picked = "mana"
	
	
	if (
		picked.begins_with("mana")
		and VarsGlobal.game_data["player_mp_now"] == VarsGlobal.game_data["player_mp_max"]
	):
		picked = "none"
	
	if no_drop == true:
		picked = "none"
	
	
	
	if picked.begins_with("coin") == true:
		item_instance = Coin.instance()
		item_instance.money = picked.replace("coin_", "")
	
	
	elif picked.ends_with("_IN") == true:
		item_instance = InventoryItem.instance()
		item_instance.not_spawn_if_obtained = false
		
		item_instance.item = GVar.INVENTORY_ITEM.keys().find(
			picked.replace("_IN", "")
		)
	
	
	elif picked.ends_with("_EQ") == true:
		item_instance = Equipment.instance()
		item_instance.not_spawn_if_obtained = false
		
		item_instance.item = GVar.EQUIPMENT.keys().find(
			picked.replace("_EQ", "").to_upper()
		) - 1
	
	
	elif picked.ends_with("_AL") == true:
		item_instance = Alloy.instance()
		item_instance.not_spawn_if_obtained = false
		
		item_instance.element = GVar.ALLOYS.keys().find(
			picked.replace("_AL", "").to_upper()
		) - 1
	
	
	match picked:
		"none":
			item_instance = null
		"mana":
			item_instance = Mana.instance()
		"mana_double":
			item_instance = Mana.instance()
			item_instance._mana_double = true
	
	if item_instance != null:
		item_instance.global_position = global_position
		VarsGlobal.GameScenario.call_deferred("add_child", item_instance)

func get_property_names() -> Array:
	var property_list = get_script().get_script_property_list()
	var exported_names: = []

	for property in property_list:
		
		
		
		
		if str(property.name).begins_with("_"):
			exported_names.append(property.name)

	return exported_names
