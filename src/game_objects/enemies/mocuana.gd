extends KinematicBody2D

var Son = preload("res://src/game_objects/enemies/mocuana_dead_son.tscn")

var speed: int = 50
var velocity: Vector2

var _active: bool = false

var _is_player_on_area: bool

var _is_chasing: bool

onready var Enemy = $EnemyBase
onready var TimerPush = $TimerPush

onready var TimerNewAtk = $TimerNewAtk
onready var AnimPlayer2 = $AnimationPlayer2
onready var PosSon = $Sprite / PosSon

func _physics_process(_delta: float) -> void :
	
	if Enemy.state in ["dead", "shriek"]:
		return
	
	if _is_chasing == true and TimerPush.is_stopped() and Enemy.state == "fly":
		Enemy.change_direction("to_player")
		velocity = Vector2.ZERO
		velocity = global_position.direction_to(
			Enemy.get_player_position() - Vector2(0, 30)
		) * speed
		
	elif TimerPush.is_stopped() == true:
		velocity = velocity / 2

	velocity = move_and_slide(velocity)

func spawn_son() -> void :
	randomize()
	
	PosSon.rotation_degrees = rand_range(0, 360)
	
	var ObjInstance = Son.instance()
	ObjInstance.global_position = PosSon.get_node("Position2D").global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	

func _on_TimerActive_timeout() -> void :
	$Llorona.play()
	Enemy.change_state("fly")
	_is_chasing = true

func _on_EnemyBase_state_changed(state) -> void :
	
	Enemy.change_direction("to_player")
	
	if state == "fly":
		randomize()
		TimerNewAtk.start(rand_range(2, 4))
	
	
	if state in ["fly"]:
		AnimPlayer2.play("fly")
	else:
		AnimPlayer2.play("RESET")

func _on_TimerNewAtk_timeout() -> void :
	if Enemy.state == "fly":
		
		randomize()
		
		var atks: Array = [
			"atk_hair", 
			"atk_hair", 
			"atk_hair", 
			"atk_hair2", 
			"cry"
		]
		
		Enemy.change_state(
			RNGTools.pick(atks)
		)
		
		velocity = velocity / Vector2(4, 4)

func _on_TimerLloro_timeout() -> void :
	if Enemy.state == "fly":
		$Llorona.play()

func _on_Mocuana_tree_exiting() -> void :
	$Llorona.stop()

func _on_EnemyBase_enemy_defeated(_NodeEnemy) -> void :
	$Llorona.stop()
