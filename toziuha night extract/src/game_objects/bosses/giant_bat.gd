extends KinematicBody2D

signal attack_finished

var Treasure = preload("res://src/game_objects/treasure_object.tscn")
var Plasma = preload("res://src/game_objects/enemies_weapons/bat_plasm.tscn")
var Bat = preload("res://src/game_objects/enemies/bat_chaser_small.tscn")

onready var Enemy = $EnemyBase
onready var BossNode = $BossNode
onready var TimerNextTween = $TimerNextTween
onready var GhostTrail = $GhostTrail

var velocity: Vector2
var speed: int = 80

var position_original: Vector2

var _chase: bool

var _defeated: bool

func _ready() -> void :
	position_original = global_position
	
	













func _physics_process(_delta: float) -> void :
	if Enemy.state == "fly" and _chase == true:
		
		velocity.x = 0
		velocity.x = global_position.direction_to(
			Enemy.get_player_position()
		).x * speed
		
		
	velocity = move_and_slide(velocity)

func start_battle() -> void :
	Audio.play_sfx("bats_flap")
	BossNode.start_battle()
	Enemy.change_state("show")
	yield($AnimationPlayer, "animation_finished")
	VarsGlobal.GameInterface.show_flash()
	BossNode.show_title_boss()
	Audio.play_sfx("ui_player_reborn2")
	Audio.stop_sfx("bats_flap")
	Enemy.change_state("fly")
	$TimerSpawnBat.start()
	yield(get_tree().create_timer(3), "timeout")
	next_move()

func next_move() -> void :
	randomize()
	_chase = true
	atk_shoot()
	yield(self, "attack_finished")
	Enemy.change_state("flyup", true)
	yield(self, "attack_finished")
	
	if randi() % 2 == 1:
		atk_shoot()
		yield(self, "attack_finished")
	
	if randi() % 2 == 1:
		atk_shoot()
		yield(self, "attack_finished")

	atk_tornado()
	yield(self, "attack_finished")
	
	next_move()

func atk_tornado() -> void :
	Audio.play_sfx("bat_shriek3")
	var target_pos: Vector2 = Enemy.get_player_position(Vector2(0, - 10))
	rotation_degrees = rad2deg(
		get_angle_to(target_pos)
	) - 90
	Enemy.change_state("pretornado")
	yield($AnimationPlayer, "animation_finished")
	Enemy.change_state("tornado", true)
	
	var Tw: SceneTreeTween
	
	Tw = create_tween()
	
	Tw.tween_property(
		self, "global_position", target_pos, 0.3
	)
	yield(Tw, "finished")
	
	rotation_degrees = 0
	Tw = create_tween()
	Tw.tween_property(
		self, "global_position", Enemy.get_player_position(), 2
	)
	yield(Tw, "finished")
	
	Tw = create_tween()
	rotation_degrees = 0
	Enemy.change_state("fly")
	Tw.tween_property(
		self, "global_position", position_original, 2
	)
	yield(Tw, "finished")
	
	Tw.stop()
	emit_signal("attack_finished")

func atk_shoot() -> void :
	$AnimAtk.play("shoot")
func _shoot() -> void :
	if $Sprite / HurtboxEnemy.hp_now < 1:
		return
	Audio.play_sfx("ec_shoot2")
	var ObjInstance = Plasma.instance()
	ObjInstance.global_position = $Flare.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func atk_side() -> void :
	var Tw: SceneTreeTween
	
	Audio.play_sfx("bat_shriek2")
	
	
	Tw = create_tween()
	Tw.tween_property(
		self, "global_position", 
		Vector2(global_position.x, VarsGlobal.GameScenario.CameraNode.limit_top - 50), 
		1
	)
	yield(Tw, "finished")
	if _defeated == true: return
	
	
	global_position = Vector2(
		VarsGlobal.GameScenario.CameraNode.limit_right + 50, 
		VarsGlobal.GameScenario.CameraNode.limit_bottom - 50
	)
	Enemy.change_direction("to_player")
	Enemy.change_state("flyside")
	TimerNextTween.start(0.1)
	yield(TimerNextTween, "timeout")
	if _defeated == true: return
	Tw = create_tween()
	Tw.tween_property(
		self, "global_position", 
		Vector2(
			VarsGlobal.GameScenario.CameraNode.limit_left - 50, 
			global_position.y
		), 
		1.5
	)
	GhostTrail.start_trail(0, 0.1)
	Audio.play_sfx("bat_shriek")
	yield(Tw, "finished")
	if _defeated == true: return
	
	GhostTrail.stop_trail()
	Enemy.change_state("fly", true)
	global_position = Vector2(
		position_original.x, 
		VarsGlobal.GameScenario.CameraNode.limit_bottom + 80
	)
	TimerNextTween.start(0.5)
	yield(TimerNextTween, "timeout")
	if _defeated == true: return
	Tw = create_tween()
	Tw.tween_property(
		self, "global_position", position_original, 2
	)
	yield(Tw, "finished")
	if _defeated == true: return

	Tw.stop()
	emit_signal("attack_finished")

func _snd_prepareshoot() -> void :
	Audio.play_sfx("spell_prepare4")

func _on_GiantBat_tree_exiting() -> void :
	Audio.stop_sfx("bats_flap")


func _on_EnemyBase_state_changed(state: String) -> void :
	if state == "show":
		return
	elif state == "flyside":
		$AnimBoxes.play("flyside")
	elif state in ["pretornado", "tornado"]:
		$AnimBoxes.play("tornado")
	else:
		$AnimBoxes.play("fly")
	
	if state == "dead":
		rotation_degrees = 0


func _on_TimerSpawnBat_timeout() -> void :
	if get_tree().get_nodes_in_group("bat_chaser_small").size() > 1:
		$TimerSpawnBat.start(1)
		return
	randomize()
	$TimerSpawnBat.start(rand_range(5, 7))
	var pos_to_spawn: Vector2 = position_original
	pos_to_spawn.x = rand_range(
		VarsGlobal.GameScenario.CameraNode.limit_left, 
		VarsGlobal.GameScenario.CameraNode.limit_right
	)
	var ObjInstance = Bat.instance()
	ObjInstance.add_to_group("bat_chaser_small")
	ObjInstance.global_position = pos_to_spawn
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)


func _on_HurtboxEnemy_defeated() -> void :
	get_tree().call_group("bat_chaser_small", "queue_free")
	$AnimAtk.stop()
	_defeated = true


func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state == "spin":
		velocity = Vector2.ZERO


func _on_BossNode_defeated_with_no_damage() -> void :
	var ObjInstance = Treasure.instance()
	ObjInstance.global_position = position_original
	ObjInstance.item = GVar.TREASURES.GIANTBATWING
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
