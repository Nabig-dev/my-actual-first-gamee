extends Control

signal closed

var ButtonBuy = preload("res://src/ui_elements/_store_button_buy.tscn")

var current_func: String = "none"

var current_item_btn: Control

var current_player_stock: int = 0
var max_stock: int = 9

var opened: bool

var price_buy_multiplier: float = 1

var items_store: Dictionary = {
	"KEY_MAGIC_MEDALLION": [
		GVar.KEYS_OBJECTS.MAGIC_MEDALLION, 10, true
	], 
	
	"INV_POTION_HEALTH": [
		GVar.INVENTORY_ITEM.POTION_HEALTH, 500, true
	], 
	"INV_PAN": [
		GVar.INVENTORY_ITEM.PAN, 80, true
	], 
	"INV_POTION_MANA": [
		GVar.INVENTORY_ITEM.POTION_MANA, 300, true
	], 
	"INV_POTION_POISON": [
		GVar.INVENTORY_ITEM.POTION_POISON, 200, true
	], 
	"INV_FIRST_AID_KIT": [
		GVar.INVENTORY_ITEM.FIRST_AID_KIT, 200, true
	], 
	"INV_POTION_CURSE": [
		GVar.INVENTORY_ITEM.POTION_CURSE, 200, true
	], 
	"INV_CARPATITIA": [
		GVar.INVENTORY_ITEM.CARPATITIA, 100, true
	], 
	"INV_BEER": [
		GVar.INVENTORY_ITEM.BEER, 150, true
	], 
	"INV_ROTTEN_CHIKEN_LEG": [
		GVar.INVENTORY_ITEM.ROTTEN_CHIKEN_LEG, 10, false
	], 
	"INV_STINKING_FLESH": [
		GVar.INVENTORY_ITEM.STINKING_FLESH, 10, false
	], 

	"INV_PB_ELEMT": [
		GVar.INVENTORY_ITEM.PB_ELEMT, 500, false
	], 

	"INV_HG_ELEMT": [
		GVar.INVENTORY_ITEM.HG_ELEMT, 400, false
	], 

	"INV_AU_ELEMT": [
		GVar.INVENTORY_ITEM.AU_ELEMT, 900, false
	], 

	"INV_SN_ELEMT": [
		GVar.INVENTORY_ITEM.SN_ELEMT, 300, false
	], 

	"INV_AG_ELEMT": [
		GVar.INVENTORY_ITEM.AG_ELEMT, 700, false
	], 

	"INV_CU_ELEMT": [
		GVar.INVENTORY_ITEM.CU_ELEMT, 600, false
	], 

	"INV_FE_ELEMT": [
		GVar.INVENTORY_ITEM.FE_ELEMT, 200, false
	], 

	"INV_TEST_TUBE": [
		GVar.INVENTORY_ITEM.TEST_TUBE, 150, true
	], 

	"INV_MINERAL_FE": [
		GVar.INVENTORY_ITEM.MINERAL_FE, 50, false
	], 

	"INV_MINERAL_CU": [
		GVar.INVENTORY_ITEM.MINERAL_CU, 200, false
	], 

	"INV_MINERAL_AG": [
		GVar.INVENTORY_ITEM.MINERAL_AG, 250, false
	], 

	"INV_MINERAL_HG": [
		GVar.INVENTORY_ITEM.MINERAL_HG, 100, false
	], 

	"INV_MINERAL_AU": [
		GVar.INVENTORY_ITEM.MINERAL_AU, 350, false
	], 

	"INV_MINERAL_SN": [
		GVar.INVENTORY_ITEM.MINERAL_SN, 50, false
	], 

	"INV_MINERAL_PB": [
		GVar.INVENTORY_ITEM.MINERAL_PB, 150, false
	], 

	"EQUIP_SACUANJOCHE": [
		GVar.EQUIPMENT.SACUANJOCHE, 0, false
	], 
	"EQUIP_BATTLE_CLOTHES": [
		GVar.EQUIPMENT.BATTLE_CLOTHES, 400, false
	], 
	"EQUIP_WITCH_HAT": [
		GVar.EQUIPMENT.WITCH_HAT, 2000, true
	], 
	"EQUIP_BATTLE_BOOTS": [
		GVar.EQUIPMENT.BATTLE_BOOTS, 300, true
	], 
	"EQUIP_CHEAP_NECKLACE": [
		GVar.EQUIPMENT.CHEAP_NECKLACE, 350, false
	], 
	"EQUIP_RUSTY_HELMET": [
		GVar.EQUIPMENT.RUSTY_HELMET, 350, false
	], 
	"EQUIP_PIRATESCARF": [
		GVar.EQUIPMENT.PIRATESCARF, 550, false
	], 

	"TREASURE_FRAGANCE": [
		GVar.TREASURES.FRAGANCE, 2500, false
	], 
	"TREASURE_DEMON_SKULL": [
		GVar.TREASURES.DEMON_SKULL, 3000, false
	], 
	"TREASURE_WATERSWORD": [
		GVar.TREASURES.WATERSWORD, 3000, false
	], 
	"TREASURE_RUBY": [
		GVar.TREASURES.RUBY, 3000, false
	], 
	"TREASURE_CLOCKPOCKET": [
		GVar.TREASURES.CLOCKPOCKET, 4000, false
	], 
	"TREASURE_GIANTBATWING": [
		GVar.TREASURES.GIANTBATWING, 3000, false
	]
}

onready var AnimPlay = $AnimationPlayer

func _ready() -> void :
	if VarsGlobal.game_data.has("price_buy"):
		price_buy_multiplier = price_buy_multiplier * VarsGlobal.game_data["price_buy"]
	
	
	if (
		VarsGlobal.game_data["current_level"] <= 15
		and VarsGlobal.game_data["cycle_game"] == 1
		and VarsGlobal.game_data["difficulty_base"] == 1
	):
		items_store["INV_CANDYDIFF"] = [GVar.INVENTORY_ITEM.CANDYDIFF, 1000, true]
	
	hide_things()

func _process(_delta: float) -> void :
	
	if opened == false:
		return
	
	if Input.is_action_just_pressed("ui_accept"):
		_on_BtnBuy_pressed()
	elif Input.is_action_just_pressed("ui_cancel"):
		_on_BtnClose_pressed()
	elif Input.is_action_just_pressed("ui_left"):
		_on_btn_update_cant_buy( - 1)
	elif Input.is_action_just_pressed("ui_right"):
		_on_btn_update_cant_buy(1)
	

func hide_things() -> void :
	get_node("%LblShopSection").visible = false
	get_node("%ControlBuy").visible = false

func open() -> void :
	hide_things()
	get_node("%VBxOptionsMain").visible = false
	AnimPlay.play("open")
	yield(AnimPlay, "animation_finished")
	get_node("%VBxOptionsMain").visible = true
	get_node("%BtnBuy").grab_focus()
	opened = true

func list_buy_items() -> void :
	
	_update_buy_info()
	
	
	for n in get_node("%VBxBuyItemsButtons").get_children():
		n.queue_free()
	yield(get_tree(), "idle_frame")
	
	var dict_it: Dictionary = _get_dict_buy_items()
	for itdict in dict_it:
		var Btn = ButtonBuy.instance()
		Btn.set_data(dict_it[itdict])
		Btn.get_node("Button").connect(
			"focus_entered", self, "_on_btn_buy_focused", [Btn]
		)
		get_node("%VBxBuyItemsButtons").add_child(Btn)
	yield(get_tree(), "idle_frame")
	
	if get_node("%VBxBuyItemsButtons").get_children().size() > 0:
		get_node(
			"%VBxBuyItemsButtons"
		).get_children()[0].get_node("Button").grab_focus()

func _get_dict_buy_items() -> Dictionary:
	
	var dict: Dictionary
	var data_item: Dictionary

	match current_func:
		
		"buy":
			var prefixes: Array = ["INV_", "EQUIP_", "TREASURE_", "KEY_"]
			for i in items_store.keys():
				
				if (
					i.begins_with("KEY_") == true
					and _get_player_current_stock(items_store[i][0], "key") > 0
				):
					items_store[i][2] = false
				
				if items_store[i][2] == true:
					data_item = {}
					for p in prefixes:
						if i.begins_with(p):
							data_item["ide"] = items_store[i][0]
							data_item["name"] = tr(i.replace(p, "") + "_TITLE")
							data_item["desc"] = tr(i.replace(p, "") + "_DESC")
							data_item["price"] = int(items_store[i][1] * price_buy_multiplier)
							data_item["type"] = p.replace("_", "").to_lower()
					dict[i] = data_item
		
		"sell":
			
			
			var player_inv: Dictionary = VarsGlobal.game_data["player_inventory"]
			for inv_id in player_inv.keys():
				data_item = {}
				if player_inv[inv_id] > 0:
					var item_text_id: String = GVar.INVENTORY_ITEM.keys()[inv_id]
					data_item["ide"] = inv_id
					data_item["name"] = tr(item_text_id + "_TITLE")
					data_item["desc"] = tr(item_text_id + "_DESC")
					
					if items_store.keys().has("INV_" + item_text_id):
						data_item["price"] = items_store["INV_" + item_text_id][1]
						data_item["price"] = int(data_item["price"] / 2)
					else:
						data_item["price"] = 100
					
					data_item["type"] = "inventory_manager"
					dict["INV_" + str(inv_id)] = data_item
			
			
			var player_equips = FuncsArrays.get_array_unique(
				VarsGlobal.game_data["player_equip_items"]
			)
			for equip_id in player_equips:
				data_item = {}
				var item_text_id: String = GVar.EQUIPMENT.keys()[equip_id + 1]
				data_item["ide"] = equip_id
				data_item["name"] = tr(item_text_id + "_TITLE")
				data_item["desc"] = tr(item_text_id + "_DESC")
				
				if items_store.keys().has("EQUIP_" + item_text_id):
					data_item["price"] = items_store["EQUIP_" + item_text_id][1]
					data_item["price"] = int(data_item["price"] / 2)
				else:
					data_item["price"] = 200
				
				data_item["type"] = "equip"
				dict["EQUIP_" + str(equip_id)] = data_item
	
			
			var treasures: Dictionary = VarsGlobal.game_data["player_treasures"]
			for t_id in treasures:
				
				if treasures[t_id] == false:
					data_item = {}
					var item_text_id: String = GVar.TREASURES.keys()[t_id]
					data_item["ide"] = t_id
					data_item["name"] = tr(item_text_id + "_TITLE")
					data_item["desc"] = tr(item_text_id + "_DESC")
					
					if items_store.keys().has("TREASURE_" + item_text_id):
						data_item["price"] = items_store["TREASURE_" + item_text_id][1]
					else:
						data_item["price"] = 1000
					
					data_item["type"] = "treasure"
					dict["TREASURE_" + str(t_id)] = data_item
	
	return dict

func _update_buy_info(clear: bool = true) -> void :
	
	if clear == true:
		get_node("%IconStoreItem").show_icon("none", 0)
		get_node("%BtnBuyNow").disabled = true
		get_node("%LblBuyDesc").text = ""
		get_node("%LblCurrentMoneyNum").text = ""
		get_node("%LblBuyTotalPrice").text = ""
		get_node("%LblBuyCant").text = ""
		return
	
	var current_items_bought: int = _get_player_current_stock(
		current_item_btn.ide, 
		current_item_btn.type
	)

	if current_func == "buy":
		if current_item_btn.type == "key":
			max_stock = 1
		elif current_items_bought < 9:
			max_stock = 9
		else:
			max_stock = 0
	elif current_func == "sell":
		max_stock = current_items_bought
	
	if current_player_stock > max_stock:
		current_player_stock = max_stock
	elif current_player_stock < 0:
		current_player_stock = 0

	get_node("%BtnBuyNow").disabled = true
	get_node("%IconStoreItem").show_icon(current_item_btn.type, current_item_btn.ide)

	get_node("%LblBuyTotalPrice").text = "C$ %d" % [
		int(current_item_btn.price * current_player_stock)
	]
	get_node("%LblBuyDesc").text = current_item_btn.desc
	get_node("%LblBuyCant").text = "X %d" % [current_player_stock]
	
	get_node("%LblCurrentMoneyNum").text = "%s: %d - C$ %d" % [
		tr("OBTAINED"), current_items_bought, 
		VarsGlobal.game_data["player_money"]
	]
	
	if current_func == "buy":
		get_node("%BtnBuyNow").text = tr("BUY")
		
		
		if (
			current_items_bought < current_player_stock + current_items_bought
			and VarsGlobal.game_data["player_money"] >= int(
				current_item_btn.price * current_player_stock
			)
			and (current_items_bought + current_player_stock) < max_stock + 1
		):
			get_node("%BtnBuyNow").disabled = false
	
	elif current_func == "sell":
		get_node("%BtnBuyNow").text = tr("SELL")
		
		if current_items_bought >= current_player_stock:
			get_node("%BtnBuyNow").disabled = false

func _get_player_current_stock(ide_item: int, type: String) -> int:
	var stock_return: int = 0
	match type:
		"inventory_manager":
			if VarsGlobal.game_data["player_inventory"].has(ide_item) == true:
				stock_return = VarsGlobal.game_data[
					"player_inventory"
				][ide_item]
		"equip":
			stock_return = VarsGlobal.game_data["player_equip_items"].count(ide_item)
		"treasure":
			if VarsGlobal.game_data["player_treasures"].has(ide_item) == true:
				
				if VarsGlobal.game_data["player_treasures"][ide_item] == false:
					stock_return = 1
				else:
					stock_return = 0
		"key":
			if VarsGlobal.game_data["player_key_objects"].has(ide_item):
				stock_return = 1

	return stock_return

func close() -> void :
	get_node("%BtnClose").release_focus()
	AnimPlay.play_backwards("open")
	yield(AnimPlay, "animation_finished")
	visible = false
	emit_signal("closed")
	opened = false

func _on_btn_buy_focused(whatbtn: Node) -> void :
	current_item_btn = whatbtn
	current_player_stock = 1
	_update_buy_info(false)

func _on_btn_update_cant_buy(num: int) -> void :
	
	if (
		get_node("%VBxOptionsMain").visible == true
		or get_node("%VBxBuyItemsButtons").get_children().size() <= 0
	):
		return

	Audio.play_sfx("ui_changed_value")
	
	current_player_stock += num
	
	if current_player_stock <= 0:
		current_player_stock = 1
	
	_update_buy_info(false)

func _open_function(what: String = "buy") -> void :
	current_func = what
	Audio.play_sfx("ui_accept")
	get_node("%VBxOptionsMain").visible = false
	
	if what == "buy":
		get_node("%TextureBG").modulate = Color("8ad0e6")
		get_node("%LblShopSection").text = "%s » %s" % [
			tr("SHOP"), tr("BUY")
		]
	elif what == "sell":
		get_node("%TextureBG").modulate = Color("e6a28a")
		get_node("%LblShopSection").text = "%s » %s" % [
			tr("SHOP"), tr("SELL")
		]
	
	get_node("%LblShopSection").visible = true
	get_node("%ControlBuy").visible = true
	list_buy_items()
	
	get_node("%BtnClose").text = tr("RETURN")

func _on_BtnClose_pressed() -> void :
	
	Audio.play_sfx("ui_cancel")

	if get_node("%VBxOptionsMain").visible == true:
		close()
	else:
		get_node("%TextureBG").modulate = Color("ffffff")
		current_func = "none"
		hide_things()
		get_node("%LblShopSection").visible = false
		get_node("%VBxOptionsMain").visible = true
		get_node("%BtnBuy").grab_focus()
		get_node("%BtnClose").text = tr("CLOSE")

func _on_BtnBuy_pressed() -> void :
	
	if (
		get_node("%VBxOptionsMain").visible == true
		or get_node("%VBxBuyItemsButtons").get_children().size() <= 0
	):
		return
	
	yield(get_tree(), "idle_frame")
	
	if (
		get_node("%BtnBuyNow").disabled == true
		or current_player_stock <= 0
		or (current_func == "sell" and current_item_btn.price < 1)
	):
		Audio.play_sfx("ui_incorrect")
		return

	if current_func == "buy":
		
		
		VarsGlobal.game_data["player_money"] -= int(
			current_player_stock * current_item_btn.price
		)
		
		if current_item_btn.type == "inventory_manager":
			for _n in range(current_player_stock):
				if (
					VarsGlobal.game_data["player_inventory"].keys().has(current_item_btn.ide)
				) == true:
					VarsGlobal.game_data["player_inventory"][
						current_item_btn.ide
					] += 1
				else:
					VarsGlobal.game_data["player_inventory"][current_item_btn.ide] = 1
		elif current_item_btn.type == "equip":
			for _n in range(current_player_stock):
				VarsGlobal.game_data["player_equip_items"].append(current_item_btn.ide)
		elif current_item_btn.type == "key":
			if VarsGlobal.game_data["player_key_objects"].has(current_item_btn.ide) == false:
				VarsGlobal.game_data["player_key_objects"].append(current_item_btn.ide)
			current_player_stock = 0
	
	elif current_func == "sell":
		
		
		VarsGlobal.game_data["player_money"] += int(
			current_player_stock * current_item_btn.price
		)
		
		if current_item_btn.type == "inventory_manager":
			var player_stock: int = _get_player_current_stock(
				current_item_btn.ide, 
				current_item_btn.type
			)
			
			player_stock = FuncsNumbers.decrease_value(
				current_player_stock, player_stock
			)
			VarsGlobal.game_data["player_inventory"][current_item_btn.ide] = player_stock
		
		elif current_item_btn.type == "equip":
			
			var equip_items: Array
			
			var arr_restock: Array
			var _player_stock: int = _get_player_current_stock(
				current_item_btn.ide, 
				current_item_btn.type
			)

			
			_player_stock = FuncsNumbers.decrease_value(
				current_player_stock, _player_stock
			)
			
			for n in VarsGlobal.game_data["player_equip_items"]:
				if n != current_item_btn.ide:
					equip_items.append(n)

			
			arr_restock.resize(_player_stock)
			arr_restock.fill(current_item_btn.ide)

			VarsGlobal.game_data["player_equip_items"] = []
			VarsGlobal.game_data["player_equip_items"].append_array(equip_items)
			VarsGlobal.game_data["player_equip_items"].append_array(arr_restock)

			
			
			if arr_restock.size() <= 0:
				
				for n in range(4):
					var i: int = 0
					
					for n2 in VarsGlobal.game_data["player_equip_" + str(n)]:
						
						if n2 == current_item_btn.ide:
							VarsGlobal.game_data["player_equip_" + str(n)][i] = - 1
						i += 1
				current_player_stock = 0
			
			else:
				current_player_stock = 1

		elif current_item_btn.type == "treasure":
			VarsGlobal.game_data["player_treasures"][current_item_btn.ide] = true
			
			current_player_stock = 0
		
	Audio.play_sfx("ui_success")
	_update_buy_info(false)
