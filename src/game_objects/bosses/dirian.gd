extends KinematicBody2D

var Hadouken = preload("res://src/game_objects/enemies_weapons/dirian_magma_ball.tscn")
var MagmaSkyBall = preload("res://src/game_objects/enemies_weapons/dirian_magma_ball_sky.tscn")
var PreFireRain = preload("res://src/game_objects/enemies_weapons/dirian_sky_fire_pre.tscn")
var FirePilarDoble = preload("res://src/game_objects/enemies_weapons/dirian_pilar_fire_double.tscn")
var FireFloor = preload("res://src/game_objects/enemies_weapons/dirian_fire_floor.tscn")


var velocity: = Vector2()

var gravity: int = 600

var speed: int = 30

var _dashing: bool

var _2nd_phase: bool

var _next_move_yield

var _sky_magmaball_positions: Array

var _spawned_firerain: int
var _limit_spawn_firerain: int = 20

var _defeated: bool

onready var Enemy = $EnemyBase
onready var BossNode = $BossNode
onready var HurtboxEnemy = $HurtboxEnemy
onready var TimerNextMove = $TimerNextMove
onready var AnimPlayer = $AnimationPlayer
onready var DetectWallBack = $Sprite / DetectWallBack
onready var DetectWallFront = $Sprite / DetectWallFront

func _ready() -> void :
	Enemy.change_state("stand", true)
	










func _physics_process(delta) -> void :
	
	if _dashing == true:
		
		match Enemy.state:
			"walk", "hadouken":
				velocity.x = (speed * 2) * Enemy.facing
			"walkinverse":
				velocity.x = (speed) * (Enemy.facing * - 1)
			"kick":
				velocity.x = (speed * 4) * Enemy.facing
			"kick2", "kick3":
				velocity.x = (speed * 8) * Enemy.facing
			"firekick":
				velocity.x = (speed * 8) * Enemy.facing
			"spinkick":
				velocity.x = (speed * 6) * Enemy.facing
			"backdash":
				velocity.x = (speed * 8) * (Enemy.facing * - 1)
			"backdash2":
				velocity.x = (speed * 10) * (Enemy.facing * - 1)
			"dodge":
				velocity.x = (speed * 5) * Enemy.facing
			_:
				velocity.x = 0
	
	if _dashing == false or Enemy.state in ["idle", "stand", "prespinkick", "dead"]:
		velocity.x = 0
	
	if Enemy.state == "walk" and DetectWallFront.is_colliding():
		Enemy.change_direction("inverse")
	elif Enemy.state == "walkinverse" and DetectWallBack.is_colliding():
		Enemy.change_state("walk")
	
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP, true)

func start_battle() -> void :
	
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	
	BossNode.show_title_boss()
	Audio.play_music("dirian_boss_theme", "high", 0)
	yield(get_tree().create_timer(1), "timeout")

	BossNode.start_battle()
	_next_move_yield = next_move()

func next_move() -> void :

	if Enemy.state == "dead" or Enemy.state == "backdash2":
		return
	
	randomize()
	
	if _2nd_phase == false:
	
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		
		TimerNextMove.start(1)
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["walk", "walkinverse"]))
		TimerNextMove.start(rand_range(1.5, 2.5))
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return

		if randi() % 2 == 1:
			Enemy.change_state("idle")
			TimerNextMove.start(1)
			yield(TimerNextMove, "timeout")
			if _2nd_phase == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["kick", "hadouken", "firekick"]))
		
		yield(AnimPlayer, "animation_finished")
		if _2nd_phase == true: return
		
		_limit_spawn_firerain = 4
		Enemy.change_state("firerain")
		yield(AnimPlayer, "animation_finished")
		if _2nd_phase == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(4)
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return
		
		spawn_firepilardouble(0.5)
		Enemy.change_direction("to_player")
		Enemy.change_state("backdash")
		yield(AnimPlayer, "animation_finished")
		if _2nd_phase == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(2)
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["walk", "walkinverse"]))
		TimerNextMove.start(rand_range(1.5, 2.5))
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return
		
		Enemy.change_direction("to_player")
		
		if randi() % 2 == 1:
			Enemy.change_state("kick")
			yield(AnimPlayer, "animation_finished")
			if _2nd_phase == true: return

		elif DetectWallBack.is_colliding() == false:
			Enemy.change_state("backdash")
			yield(AnimPlayer, "animation_finished")
			if _2nd_phase == true: return
		
		elif DetectWallFront.is_colliding() == false:
			Enemy.change_state("dodge")
			yield(AnimPlayer, "animation_finished")
			if _2nd_phase == true: return
		
		else:
			Enemy.change_state(RNGTools.pick(["walk", "walkinverse"]))
			TimerNextMove.start(rand_range(2, 3))
			yield(TimerNextMove, "timeout")
			if _2nd_phase == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(2)
		yield(TimerNextMove, "timeout")
		if _2nd_phase == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["hadouken", "firekick"]))
		yield(AnimPlayer, "animation_finished")
		if _2nd_phase == true: return
		
		Enemy.change_direction("to_player")
		if DetectWallFront.is_colliding() == false:
			Enemy.change_state("prespinkick")
		else:
			next_move()
	
	
	else:
		
		Enemy.change_state("idle", true)
		
		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["walk", "walkinverse"]))
		TimerNextMove.start(rand_range(1.5, 2.5))
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(0.8)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		Enemy.change_direction("to_player")
		
		if randi() % 2 == 1:
			Enemy.change_state("kick")
			yield(AnimPlayer, "animation_finished")
			if _defeated == true: return

		elif DetectWallBack.is_colliding() == false:
			Enemy.change_state("backdash")
			yield(AnimPlayer, "animation_finished")
			if _defeated == true: return
		
		elif DetectWallFront.is_colliding() == false:
			Enemy.change_state("dodge")
			yield(AnimPlayer, "animation_finished")
			if _defeated == true: return
		
		else:
			Enemy.change_state(RNGTools.pick(["walk", "walkinverse"]))
			TimerNextMove.start(rand_range(2, 3))
			yield(TimerNextMove, "timeout")
			if _defeated == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["kick2", "hadouken"]))
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("firekick")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(2)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["walk", "walkinverse"]))
		TimerNextMove.start(rand_range(1.5, 2.5))
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		
		Enemy.change_direction("to_player")
		Enemy.change_state("hadouken", true)
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return
		Enemy.change_direction("to_player")
		Enemy.change_state("hadouken", true)
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return
		Enemy.change_direction("to_player")
		Enemy.change_state("hadouken", true)
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state("backdash")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return
		
		spawn_firepilardouble(6)
		
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(1)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		_limit_spawn_firerain = 10
		Enemy.change_state("firerain")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("backdash")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(4)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state("firekick")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(2)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		
		Enemy.change_direction("to_player")
		Enemy.change_state("kick3")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("firekick")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(2)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		_limit_spawn_firerain = 6
		Enemy.change_state("firerain")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state("walkinverse")
		TimerNextMove.start(2)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(3)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state("hadouken", true)
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(1)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		if DetectWallFront.is_colliding() == false:
			Enemy.change_state("prespinkick")
		else:
			next_move()

func set_dash(val: bool) -> void :
	_dashing = val

func snd(val: String) -> void :
	Audio.play_sfx(val)

func jump(vel: float = 100) -> void :
	Audio.play_sfx("woosh_jump")
	velocity.y -= vel

func get_player_x_distance() -> float:
	var pos_a: Vector2 = global_position
	var pos_b: = Vector2(Enemy.get_player_position().x, pos_a.y)
	return pos_a.distance_to(pos_b)

func spawn_hadouken() -> void :
	Audio.play_sfx("spell_shoot")
	var ObjInstance = Hadouken.instance()
	ObjInstance.dir = Enemy.facing
	ObjInstance.global_position = $Sprite / PositionHadouken.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _spawn_fire_on_spinkick() -> void :
	spawn_fire(4, global_position - Vector2(0, 30))

func _spawn_fire_on_floor() -> void :
	if _2nd_phase == false:
		return
	var spawned_count: int = 0
	var offset_pos: float = 0
	spawn_fire(0.5, global_position)
	while spawned_count < 30:
		spawned_count += 1
		offset_pos += 20
		var pos: = global_position
		var pos_r: Vector2 = pos + Vector2(offset_pos, 0)
		var pos_l: Vector2 = pos - Vector2(offset_pos, 0)
		if pos_r.x < VarsGlobal.GameScenario.CameraNode.limit_right:
			spawn_fire(0.5, pos_r)
		if pos_l.x > VarsGlobal.GameScenario.CameraNode.limit_left:
			spawn_fire(0.5, pos_l)
		yield(get_tree().create_timer(0.2), "timeout")

func spawn_fire(duration: float = 1, pos_to_spawn: Vector2 = global_position) -> void :
	if _2nd_phase == false:
		return
	var ObjInstance = FireFloor.instance()
	ObjInstance.global_position = pos_to_spawn
	ObjInstance.time_active = duration
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	

func spawn_firepilardouble(duration: float = 3) -> void :
	
	if get_tree().get_nodes_in_group("dirianfirepilar").size() > 0:
		return
	
	var ObjInstance = FirePilarDoble.instance()
	ObjInstance.time_active = duration
	ObjInstance.global_position = Vector2(
		Enemy.get_player_position().x, 
		global_position.y
	)
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	

func spawn_magmaskyball() -> void :
	randomize()
	var pos_to_spawn: Vector2 = global_position - Vector2(0, 250)
	
	Enemy.change_direction("to_player")
	if Enemy.facing == 1:
		pos_to_spawn.x = VarsGlobal.GameScenario.CameraNode.get_limit_l()
	else:
		pos_to_spawn.x = VarsGlobal.GameScenario.CameraNode.get_limit_r()
	
	Audio.play_sfx("fireball_large")
	Audio.play_sfx("spell_shoot")
	
	var ObjInstance = MagmaSkyBall.instance()
	ObjInstance.dir = Enemy.facing
	
	if _sky_magmaball_positions.empty() == true:
		if Enemy.facing == - 1:
			_sky_magmaball_positions = [210, - 10, 110, - 110]
		else:
			_sky_magmaball_positions = [ - 210, 10, - 110, 110]
	
	
	
	
	var new_pos_x: float = _sky_magmaball_positions[0]
	_sky_magmaball_positions.remove(0)
	
	pos_to_spawn.x += new_pos_x
	
	ObjInstance.speed += rand_range(0, 50)
	ObjInstance.global_position = pos_to_spawn
	
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_pre_firerain() -> void :
	var ObjInstance = PreFireRain.instance()
	ObjInstance.global_position = $Sprite / PositionFirerain.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_firerain() -> void :
	randomize()
	var rand_pos_x: float = Enemy.get_player_position().x + rand_range( - 50, 50)
	var ObjInstance = PreFireRain.instance()
	ObjInstance.auto_target = false
	ObjInstance.speed = 200
	
	ObjInstance.global_position = Vector2(
		rand_pos_x, 
		VarsGlobal.GameScenario.CameraNode.limit_top - 50
	)
	
	
	ObjInstance.target_position = Vector2(
		rand_pos_x, 
		ObjInstance.global_position.y + 300
	)
	
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _rumble() -> void :
	Audio.play_sfx("explosion_light2")
	VarsGlobal.GameScenario.CameraNode.start_shake(0.4, false, false)
	Gamepad.start_vibration(0, 0.4, 0.4, 0.5)

func _on_DetectWallBack_object_entered(_Obj) -> void :
	if Enemy.state == "walkinverse":
		Enemy.change_state("walk")


func _on_DetectWallFront_object_entered(_Obj) -> void :
	if Enemy.state == "walk":
		Enemy.change_direction("inverse")
	if Enemy.state == "spinkick":
		_next_move_yield = next_move()


func _on_EnemyBase_state_changed(state: String) -> void :
	
	if state == "kick" and get_player_x_distance() > 40 and _2nd_phase == false:
		Enemy.change_state("kick2")
	
	elif state == "walkinverse" and DetectWallBack.is_colliding():
		Enemy.change_state("walk")
	
	elif state == "walk" and DetectWallFront.is_colliding():
		Enemy.change_direction("inverse")
	
	elif state == "spinkick" and DetectWallFront.is_colliding():
		_next_move_yield = next_move()


func _on_AreaDetectPlayerFacing_area_exited(_area: Area2D) -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")
	elif Enemy.state == "walkinverse":
		Enemy.change_state("walk")


func _on_HurtboxEnemy_damaged() -> void :
	
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")
		
	if _defeated == true:
		return
		
	var hp_percent: = FuncsNumbers.get_percentage(
		HurtboxEnemy.hp_now, HurtboxEnemy.hp_max
	)
	
	if (
		hp_percent <= 30
		and HurtboxEnemy.hp_now > 0
		and VarsGlobal.game_data["player_hp_now"] > 0
		and _2nd_phase == false
	):
		
		_2nd_phase = true
		$Sprite / LightBody.visible = true
		TimerNextMove.stop()
		AnimPlayer.play("RESET")
		yield(get_tree(), "idle_frame")
		
		
		$HurtboxEnemy / CollisionShape2D.disabled = true
		$HitboxEnemy / CollisionShape2D.disabled = true
		
		Enemy.change_direction("to_player")
		Enemy.change_state("idle", true)
		Enemy.state = "dead"

		yield(get_tree().create_timer(1), "timeout")
		Enemy.state = "backdash2"
		AnimPlayer.play("backdash")
		yield(AnimPlayer, "animation_finished")
		AnimPlayer.play("backdash")
		yield(AnimPlayer, "animation_finished")
		AnimPlayer.play("backdash")
		yield(AnimPlayer, "animation_finished")
		
		Enemy.state = "recover"
		AnimPlayer.play("recover")
		yield(get_tree().create_timer(4), "timeout")
		
		var hp_to_recover: int = int(
			(HurtboxEnemy.hp_max / 2) / 15
		)
		for _n in range(10):
			Audio.play_sfx("ui_item_use")
			HurtboxEnemy.hp_now += hp_to_recover
			VarsGlobal.GameScenario.show_damage_number(
				hp_to_recover, HurtboxEnemy.global_position, "green"
			)
			BossNode._on_enemy_damaged()
			yield(get_tree().create_timer(0.3), "timeout")

	
	if HurtboxEnemy.hp_now < 1:
		_2nd_phase = true
		
		Audio.stop_music()
		Enemy.change_state("defeated")

func _on_TimerSpawnFireRain_timeout() -> void :
	if _spawned_firerain > _limit_spawn_firerain:
		_spawned_firerain = 0
		$TimerSpawnFireRain.stop()
		return
	_spawned_firerain += 1
	spawn_firerain()


func _on_HurtboxEnemy_defeated() -> void :
	_defeated = true
	$TimerSpawnFireRain.stop()
	get_tree().call_group("dirianfirepilar", "queue_free")
