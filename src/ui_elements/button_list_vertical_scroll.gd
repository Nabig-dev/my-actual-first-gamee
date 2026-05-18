extends VBoxContainer

export var input_enabled: bool = true



var item_current_id: String



export (Array, Array, String) var items

var _selected_item: = 0

onready var Label1: = $Label1
onready var Label2: = $Label2
onready var Label3: = $Label3
onready var Label4: = $Label4
onready var Label5: = $Label5

func _ready() -> void :
	item_current_id = items[_selected_item][0]
	_update_list()
	
func _process(_delta: float):
	
	if input_enabled == false:
		return
	
	if Input.is_action_just_pressed("ui_up"):
		_selected_item = FuncsArrays.get_new_position_on_array(items, _selected_item, "prev")
		_update_list()
		Audio.play_sfx("ui_big_btn_focused")
		
	
	elif Input.is_action_just_pressed("ui_down"):
		_selected_item = FuncsArrays.get_new_position_on_array(items, _selected_item, "next")
		_update_list()
		Audio.play_sfx("ui_big_btn_focused")

func remove_by_id(ide: String) -> void :
	var i: int = 0
	for it in items:
		if it[0] == ide:
			items.remove(i)
			_update_list()
		i += 1

func _update_list():
	
	item_current_id = items[_selected_item][0]
	
	var idx_prev: int = _selected_item
	
	for it in [Label2, Label1]:
		idx_prev = FuncsArrays.get_new_position_on_array(items, idx_prev, "prev")
		it.text = items[idx_prev][1]
	
	
	Label3.text = items[_selected_item][1]
	
	var idx_next: int = _selected_item
	
	for it in [Label4, Label5]:
		idx_next = FuncsArrays.get_new_position_on_array(items, idx_next, "next")
		it.text = items[idx_next][1]
