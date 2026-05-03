extends Node2D




var Mana = preload("res://src/game_objects/drop_items/mana.tscn")

var _mana_instance: Object = null

var _player_entered: bool

var _destroyed: bool

onready var HelperIconBtn = $HelperIconBtn
onready var SpriteStatue = $Sprite
onready var ManaPosition = $Position2D
onready var TimerSpawn = $TimerSpawn
onready var Anim = $AnimationPlayer

func _ready() -> void :
	HelperIconBtn.visible = false
	SpriteStatue.frame = 0
	$Particles.emitting = true

func _process(_delta: float) -> void :
	
	if (
		Input.is_action_just_pressed("ui_down") and _player_entered == true
		and _destroyed == false
	):
		TimerSpawn.start()
	
	if Input.is_action_just_released("ui_down"):
		TimerSpawn.stop()

func _on_AreaDetectPlayer_body_entered(_body: Node) -> void :
	_player_entered = true
	if _destroyed == false:
		HelperIconBtn.visible = true

func _on_AreaDetectPlayer_body_exited(_body: Node) -> void :
	_player_entered = false
	TimerSpawn.stop()
	HelperIconBtn.visible = false


func _on_TimerSpawn_timeout() -> void :
	_mana_instance = Mana.instance()
	_mana_instance.mana_double = true
	_mana_instance.global_position = ManaPosition.global_position
	VarsGlobal.GameScenario.add_child(_mana_instance)


func _on_HurtboxEnemySimple_damaged() -> void :
	SpriteStatue.frame += 1

func _on_HurtboxEnemySimple_defeated() -> void :
	_destroyed = true
	Anim.play("destroyed")
	HelperIconBtn.visible = false
	
	VarsGlobal.game_data["player_hp_now"] = VarsGlobal.game_data["player_hp_max"]
	VarsGlobal.GameInterface.update_hud_values()
	Notification.show_notif(tr("HEALTH_RECOVERED"))




func _on_InteractableArea2DIndicator_interact_requested() -> void :
	pass
