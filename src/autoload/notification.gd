extends CanvasLayer




var _start_pos_y = - 25
var _destiny_pos_y = 4

onready var Shadow = $ShadowTexture
onready var PanelNotif = $Control
onready var LblText = $Control / PanelContainer / Label
onready var TimeDuration = $Control / Timer
onready var TweenNode = $Control / Tween

var _reseted: bool = false

func _ready() -> void :
	_reset()

func show_notif(msg: String = "Hello;World", duration: int = 2) -> void :
	
	_reset()
	
	LblText.text = ""
	LblText.text = msg

	_activate_tween(
		Shadow, "modulate", Shadow.modulate, Color(1, 1, 1, 1), 0.5
	)
	_activate_tween(
		PanelNotif, "rect_position", PanelNotif.rect_position, 
		Vector2(PanelNotif.rect_position.x, _destiny_pos_y), 1, 
		Tween.TRANS_BOUNCE, Tween.EASE_OUT
	)
	
	yield(TweenNode, "tween_all_completed")
	TimeDuration.start(duration)

func _reset() -> void :
	_reseted = true
	TimeDuration.stop()
	TweenNode.stop_all()
	TweenNode.reset_all()
	Shadow.modulate.a = 0
	PanelNotif.rect_position.y = _start_pos_y
	_reseted = false

func hide_notif() -> void :
	_activate_tween(Shadow, "modulate", Shadow.modulate, Color(1, 1, 1, 0), 1.3)
	_activate_tween(
		PanelNotif, "rect_position", PanelNotif.rect_position, 
		Vector2(PanelNotif.rect_position.x, _start_pos_y), 1.2, 
		Tween.TRANS_CUBIC, Tween.EASE_IN
	)
	

func _activate_tween(obj, prop, init_val, final_val, duration, trans = Tween.TRANS_LINEAR, t_ease = Tween.EASE_IN_OUT) -> void :
	
	TweenNode.interpolate_property(obj, prop, init_val, final_val, duration, trans, t_ease)
	TweenNode.start()

func _on_Timer_timeout() -> void :
	hide_notif()



func _on_Tween_tween_all_completed() -> void :
	pass
