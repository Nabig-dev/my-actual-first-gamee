extends Node2D

signal interact_requested

export var active: bool = true setget _update_active

var opened_menu: bool

var map_interface_path: String = "res://stages/%s/map_full_travel.tscn" % [
	VarsGlobal.selected_stage
]


var go_to_train_event: bool

var MapTravelInterface: CanvasLayer

func _ready() -> void :
	
	
	VarsGlobal.GameInterface.enabled_quicksave = false
	
	if ResourceLoader.exists(map_interface_path):
		var MapTInterface = ResourceLoader.load(map_interface_path).instance()
		get_tree().current_scene.call_deferred("add_child", MapTInterface)
		yield(get_tree(), "idle_frame")

	for n in get_tree().get_nodes_in_group("map_full_travel_interface"):
		n.connect(
			"closed", self, "_on_travel_interface_closed"
		)
		MapTravelInterface = n

	_update_active(active)

func _update_active(act: bool) -> void :
	active = act
	$Door.visible = not active
	$InteractableArea2DIndicator / CollisionShape2D.disabled = not active


func _on_InteractableArea2DIndicator_interact_requested() -> void :
	if opened_menu == true or VarsGlobal.Player.enabled_input == false:
		return
	
	emit_signal("interact_requested")
	
	opened_menu = true
	
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	yield(get_tree().create_timer(0.8), "timeout")
	
	if go_to_train_event == true:
		VarsGlobal.add_flag("train_event")
		VarsGlobal.Player._change_sprite_facing(1)
		SceneChanger.change_scene("res://stages/oota/amerithia/train_event_1.tscn")
	else:
		MapTravelInterface.open()

func _on_travel_interface_closed() -> void :
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
	opened_menu = false
