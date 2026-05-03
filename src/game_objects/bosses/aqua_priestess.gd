extends KinematicBody2D

signal ready_for_next_atk

var Treasure = preload("res://src/game_objects/treasure_object.tscn")
var AquaShoot = preload("res://src/game_objects/enemies_weapons/aqua_ball_shoot.tscn")
var WaterBall = preload("res://src/game_objects/enemies_weapons/water_ball.tscn")


export var side_l: int
export var side_r: int

export var position_center: Vector2

var speed: int = 100
var velocity: Vector2

var _chase_y_player: bool
var _dashing: bool
var _defeated: bool

onready var Enemy = $EnemyBase
onready var TimerNextMove = $TimerNextMove
onready var AnimPlayer = $AnimationPlayer








func _physics_process(_delta: float) -> void :
	
	if _chase_y_player == true:
		Enemy.change_direction("to_player")
		velocity.y = global_position.direction_to(
			Enemy.get_player_position(Vector2(0, - 20))
		).y * speed
		if Enemy.state == "lance":
			velocity.y *= 4
	
	if _dashing == true:
		velocity.x = (speed * 2) * Enemy.facing
	else:
		velocity.x = 0

	
	velocity = move_and_slide(velocity)
	

func next_move() -> void :
	
	
	
	
	
	
	
	
	randomize()
	
	Enemy.change_state("idle", true)
	_set_chase_y(true)
	
	_move_to_side()
	yield(self, "ready_for_next_atk")
	if _defeated == true: return
	
	TimerNextMove.start(0.5)
	yield(TimerNextMove, "timeout")
	if _defeated == true: return
	
	_set_chase_y(false)
	Enemy.change_state(RNGTools.pick(["lance", "lance", "ball", "spikes"]), true)
	yield(AnimPlayer, "animation_finished")
	if _defeated == true: return
	
	Enemy.change_state("idle", true)
	_set_chase_y(true)
	_move_to_side()
	yield(self, "ready_for_next_atk")
	if _defeated == true: return
	
	_set_chase_y(false)
	Enemy.change_state(RNGTools.pick(["triball", "ball", "spikes"]), true)
	if Enemy.state == "spikes":
		_set_chase_y(true)
	yield(AnimPlayer, "animation_finished")
	if _defeated == true: return
	
	Enemy.change_state("idle", true)
	_set_chase_y(false)
	_atk_watergun()
	yield(self, "ready_for_next_atk")
	if _defeated == true: return
	
	Enemy.change_state("idle", true)
	_set_chase_y(true)
	_move_to_side()
	yield(self, "ready_for_next_atk")
	if _defeated == true: return
	
	Enemy.change_state("idle", true)
	_move_to_side()
	yield(self, "ready_for_next_atk")
	if _defeated == true: return
	
	
	
	next_move()

func _set_dash(val: bool) -> void :
	_dashing = val

func _set_chase_y(val: bool) -> void :
	_chase_y_player = val
	if val == false:
		velocity.y = 0

func start_battle() -> void :
	$BossNode.show_title_boss()
	Audio.play_music("prepare_for_war", "high", 0)
	Enemy.change_state("show")
	yield($AnimationPlayer, "animation_finished")
	Enemy.change_state("idle")
	$BossNode.start_battle()
	next_move()

func snd(snd: String) -> void :
	Audio.play_sfx(snd)

func _update_rotation_laser() -> void :
	var direction_to_player: Vector2 = Enemy.get_player_position(Vector2(0, - 30)) - $BossAquapriestess / Laser.global_position
	var rotation_to_player: float = direction_to_player.angle()
	$BossAquapriestess / Laser.rotation_degrees = rad2deg(rotation_to_player)
	if Enemy.facing == - 1:
		$BossAquapriestess / Laser.scale.x = - 1
		$BossAquapriestess / Laser.rotation_degrees *= - 1
	else:
		$BossAquapriestess / Laser.scale.x = 1

func _atk_watergun() -> void :

	if global_position != position_center:
		var Tw: SceneTreeTween = create_tween()
		Tw.tween_property(
			self, "global_position", position_center, 2
		).set_trans(Tween.TRANS_BACK)
		yield(Tw, "finished")
	
	Enemy.change_state("watergun", true)

	
	randomize()
	
	var rand_rotation: int = rand_range(0, 45)
	$BossAquapriestess / WaterGunPositions.rotation_degrees = rand_rotation

func _teleport_prelancehorizontal() -> void :
	randomize()
	global_position.y = Enemy.get_player_position().y + rand_range( - 30, 30)
	global_position.x = position_center.x


func _start_watergun() -> void :
	
	var rotation_end: int = RNGTools.pick([360, - 360])
	
	randomize()
	_on_TimerShootWaterGun_timeout()
	var Tw: SceneTreeTween = create_tween()
	Tw.tween_property(
		$BossAquapriestess / WaterGunPositions, 
		"rotation_degrees", 
		$BossAquapriestess / WaterGunPositions.rotation_degrees + rotation_end, 
		15
	)
	$TimerShootWaterGun.start(0.08)

func _spawn_shoot(target_node: Node2D) -> void :
	if _defeated == true:
		return
	var ObjInstance = AquaShoot.instance()
	ObjInstance.target = target_node.global_position
	ObjInstance.add_to_group("waterballaquapriestess")
	ObjInstance.global_position = $BossAquapriestess / WaterGunPositions.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _spawn_waterball(position_node: Node2D = null) -> void :
	var ObjInstance = WaterBall.instance()
	if position_node == null:
		ObjInstance.global_position = $BossAquapriestess / TriballGlow.global_position
	else:
		ObjInstance.global_position = position_node.global_position
	randomize()
	ObjInstance.add_to_group("waterballaquapriestess")
	ObjInstance.speed += rand_range( - 20, 20)
	ObjInstance.offsetpos_y += rand_range( - 30, 30)
	ObjInstance.offsetpos_x += rand_range( - 10, 10)
	ObjInstance.get_node("HurtboxEnemySimple").max_hits = 1
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	Audio.play_sfx("ec_pasive_activate")

func _move_to_side(side: int = 0, duration_move: int = 4) -> void :
	var Tw: SceneTreeTween
	var pos_to_move: int
	
	Tw = create_tween()
	
	if global_position.x == side_l:
		pos_to_move = side_r
	elif global_position.x == side_r:
		pos_to_move = side_l
	elif side == 0:
		randomize()
		pos_to_move = RNGTools.pick([side_l, side_r])
	elif side == 1:
		pos_to_move = side_r
	elif side == - 1:
		pos_to_move = side_l
	
	Tw.tween_property(
		self, "global_position:x", pos_to_move, duration_move
	).set_trans(Tween.TRANS_BACK)
	yield(Tw, "finished")
	emit_signal("ready_for_next_atk")

func _on_TimerShootWaterGun_timeout() -> void :
	_spawn_shoot($BossAquapriestess / WaterGunPositions / PosL)
	_spawn_shoot($BossAquapriestess / WaterGunPositions / PosR)
	_spawn_shoot($BossAquapriestess / WaterGunPositions / PosU)
	_spawn_shoot($BossAquapriestess / WaterGunPositions / PosD)


func _on_HurtboxEnemy_defeated() -> void :
	_defeated = true
	
	get_tree().call_group("waterballaquapriestess", "queue_free")
	pass


func _on_BossNode_defeated_with_no_damage() -> void :
	var ObjInstance = Treasure.instance()
	ObjInstance.global_position = $BossAquapriestess.global_position
	ObjInstance.item = GVar.TREASURES.WATERSWORD
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
