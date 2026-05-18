extends Node2D







onready var Coll = $Area2DCast / Collision
onready var AreaCast = $Area2DCast

var CollisionHurtBox: CollisionShape2D

func _ready() -> void :
	for n in get_parent().get_children():
		if n is CollisionShape2D:
			
			n.connect("item_rect_changed", self, "_onCollisionItemRectChanged")
			CollisionHurtBox = n
	
	_update_collision()

func _fix() -> void :
	
	
	if VarsGlobal.current_room_changer.empty() == false:
		return
	
	if VarsGlobal.Player.is_on_floor() == false:
		VarsGlobal.Player.global_position.y -= 1
	$TimerCheck.start(0.2)

func _update_collision() -> void :
	Coll.shape = CollisionHurtBox.shape
	Coll.position = CollisionHurtBox.position

func _onCollisionItemRectChanged() -> void :
	_update_collision()

func _on_TimerCheck_timeout() -> void :
	if AreaCast.is_colliding() == true:
		_fix()


func _on_Area2DCast_object_entered(_Obj) -> void :
	_fix()
