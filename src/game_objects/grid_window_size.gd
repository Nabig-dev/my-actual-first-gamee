tool 
extends TextureRect

signal current_pos_updated

export var vertical: int = 1 setget update_vertical
export var horizontal: int = 1 setget update_horizontal

var current_position: int = - 1

func _ready() -> void :
	if Engine.is_editor_hint() == false:
		
		add_areas()

func update_vertical(ver: int) -> void :
	if ver < 1:
		ver = 1
	vertical = ver
	update_size()
func update_horizontal(hor: int) -> void :
	if hor < 1:
		hor = 1
	horizontal = hor
	update_size()

func update_size() -> void :
	rect_size = rect_min_size
	rect_size.x = rect_size.x * horizontal
	rect_size.y = rect_size.y * vertical
	$GridContainer.columns = horizontal

func add_areas() -> void :

	for c in range(horizontal * vertical):
		
		var area_name: String = "Area" + str(c)
		var NewArea: Area2D = $Area2D.duplicate()
		var NewCenterContainer: = CenterContainer.new()
		
		NewCenterContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		NewCenterContainer.rect_min_size = Vector2(341, 192)
		NewArea.visible = true
		NewArea.name = area_name
		
		NewCenterContainer.add_child(NewArea)
		
		NewCenterContainer.get_node(area_name + "/CollisionShape2D").disabled = false
		
		$GridContainer.add_child(NewCenterContainer)
		
		NewCenterContainer.get_node(area_name).connect(
			"area_entered", self, "_on_player_entered_area", [c]
		)
		
		$Area2D.queue_free()

func _on_player_entered_area(_area: Area2D, what_area: int) -> void :
	current_position = what_area
	emit_signal("current_pos_updated")

func _on_GridWindowSize_resized() -> void :
	pass
	
