extends KinematicBody2D

signal teleported
signal explosion_exploted
signal battle_ended

var Rock = preload("res://src/game_objects/enemies_weapons/rock_random_fall.tscn")
var Explosion = preload("res://src/game_objects/enemies_weapons/explosion_annette.tscn")
var Spark = preload("res://src/game_objects/enemies_weapons/annette_spark_projectile.tscn")
var Pilar = preload("res://src/game_objects/enemies_weapons/annette_pilar.tscn")
var Pilar2 = preload("res://src/game_objects/enemies_weapons/annette_pilar_2.tscn")
var Sphere = preload("res://src/game_objects/enemies_weapons/annete_sphere_hydro.tscn")
var Bolt = preload("res://src/game_objects/enemies_weapons/bolt_hidro.tscn")
var Burst = preload("res://src/game_objects/enemies_weapons/burst.tscn")
var FireHydro = preload("res://src/game_objects/enemies_weapons/annette_fire_hydro.tscn")

export var positions_to_spawn: NodePath
export var spawn_rocks_on_explosion: bool = true

var velocity: = Vector2()

var gravity: int = 250

var speed: int = 20

export var limit_pos_l: float
export var limit_pos_r: float

var movements: Array = [
	
	[
		"sphere", "walls", "explosion", "spread"
	], 
	
	[
		["fastatk"], 
		["sphere", "walls"], 
		["spread", "explosion"], 
		["pilars"]
	]
]

var _next_atk: String

var _initial_position_onfloor: Vector2

var _move_x_enabled: bool = true

var _gravity_enabled: bool = true

var battle_phase: int = 0
var _current_move_phase: int = 0

onready var Enemy = $EnemyBase
onready var BossNode = $BossNode
onready var HurtboxEnemy = $Body / HurtboxEnemy

func _ready() -> void :
	_initial_position_onfloor = global_position
	Enemy.change_state("idle", true)

func next_move(skip_move: bool = false) -> void :
	randomize()
	
	if battle_phase == 0:
		_next_atk = RNGTools.pick(movements[battle_phase])
	
	else:
		if _current_move_phase > 3:
			_current_move_phase = 0
		_next_atk = RNGTools.pick(movements[1][_current_move_phase])
		_current_move_phase += 1
		
	

	
	

	
	
	
	if battle_phase > 1:
		if _next_atk in ["walls", ]:
			spawn_firehydro(true)

		elif _next_atk in ["spread"] and battle_phase < 2:
			spawn_firehydro(false)

	if _next_atk != "fastatk" and skip_move == false:
		Enemy.change_state("teleport")
		yield(self, "teleported")
	
	Enemy.change_state(_next_atk)
		

func start_battle() -> void :
	
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	
	BossNode.show_title_boss()
	Audio.play_music("annette_boss_theme", "high", 0)
	yield(get_tree().create_timer(1), "timeout")
	
	
	
	
	BossNode.start_battle()
	next_move()

func _physics_process(delta) -> void :
	
	if _move_x_enabled == true and is_on_floor() == false and Enemy.state == "dead":
		velocity.x = 40 * (Enemy.facing * - 1)
	
	if _gravity_enabled == true:
		velocity.y += gravity * delta
	
	velocity = move_and_slide(velocity, Vector2.UP, true)

func _enable_gravity(ena: bool) -> void :
	_gravity_enabled = ena

func _vibration() -> void :
	if Audio.sfx_is_playing("worm_rumble2") == false:
		Audio.play_sfx("worm_rumble2")
	VarsGlobal.GameScenario.CameraNode.start_shake(0.4, false, false)
	Gamepad.start_vibration(0, 0.4, 0.4, 0.5)

func _move_to_pos(randompos: bool = true) -> void :
	randomize()
	
	if randompos == true and positions_to_spawn.is_empty() == false:
	
		if _next_atk in ["walls"]:
			global_position = Vector2(
				rand_range(limit_pos_l, limit_pos_r), 
				_initial_position_onfloor.y
			)
		else:
			global_position = RNGTools.pick(
				get_node(positions_to_spawn).get_children()
			).global_position
	
	
	elif randompos == false:
		var newpos: Vector2 = Vector2(
			RNGTools.pick([
				VarsGlobal.GameScenario.CameraNode.get_limit_l(), 
				VarsGlobal.GameScenario.CameraNode.get_limit_r()
			]), 
			Enemy.get_player_position().y
		)
		global_position = newpos
		snd_teleportfast()

	Enemy.change_direction("to_player")
	
	if (
		battle_phase == 1
		and get_tree().get_nodes_in_group("annette_pilar1").size() < 2
	):
		pilar(Enemy.get_player_position(), 0)
	elif battle_phase == 2 and _next_atk != "pilars" and _next_atk != "fastatk":
		pilar2(RNGTools.pick([1, - 1]))
		

func jump() -> void :
	if is_on_floor() == true:
		velocity.y = - 100

func snd_prespawnspheres() -> void :
	Audio.play_sfx("crystal_soul_generating2")

func snd_prespawnbolts() -> void :
	Audio.play_sfx("spell_prepare")

func clear_firehydro() -> void :
	for n in get_tree().get_nodes_in_group("firehydro"):
		n.queue_free()

func spawn_firehydro(on_floor: bool = true, _pos: Vector2 = Vector2.ZERO) -> void :
	var ObjInstance: RigidBody2D
	
	if on_floor == true:
		var posx_to_spawn: float = limit_pos_l - 30
		while posx_to_spawn < limit_pos_r + 30:
			ObjInstance = FireHydro.instance()
			ObjInstance.global_position = Vector2(
				posx_to_spawn, 
				_initial_position_onfloor.y
			)
			ObjInstance.time_active = 10
			ObjInstance.add_to_group("firehydro")
			VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
			posx_to_spawn += 30
	else:
		ObjInstance = FireHydro.instance()
		ObjInstance.global_position = Enemy.get_player_position(Vector2(0, - 15))
		ObjInstance.time_active = 6
		ObjInstance.add_to_group("firehydro")
		VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
		
		ObjInstance = FireHydro.instance()
		ObjInstance.global_position = Enemy.get_player_position(Vector2(0, - 15))
		ObjInstance.global_position.x += 20
		ObjInstance.time_active = 6
		ObjInstance.add_to_group("firehydro")
		VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
		
		ObjInstance = FireHydro.instance()
		ObjInstance.global_position = Enemy.get_player_position(Vector2(0, - 15))
		ObjInstance.global_position.x -= 20
		ObjInstance.time_active = 6
		ObjInstance.add_to_group("firehydro")
		VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_spheres() -> void :
	

	if battle_phase > 1:
		spawn_firehydro(false)

	for Pos in $Body / SpheresPos.get_children():
		var ObjInstance = Sphere.instance()
		ObjInstance.add_to_group("annete_spheres")
		ObjInstance.global_position = $Body / Sprite.global_position
		ObjInstance.target_position = Pos.global_position
		ObjInstance.speed = 50
		ObjInstance._update_velocity()
		ObjInstance.adjust_angle()
		VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_burst() -> void :
	randomize()
	var ObjInstance = Burst.instance()
	var pos_to_spawn: = Vector2(
		rand_range(
			VarsGlobal.GameScenario.CameraNode.get_limit_l(), 
			VarsGlobal.GameScenario.CameraNode.get_limit_r()
		), 
		rand_range(
			_initial_position_onfloor.y, 
			_initial_position_onfloor.y - 120
		)
	)
	ObjInstance.global_position = pos_to_spawn
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_rocks_falling() -> void :
	if spawn_rocks_on_explosion == false:
		return
	randomize()
	for _n in range(5):
		var ObjInstance = Rock.instance()
		var pos_to_spawn: = Vector2(
			rand_range(
				VarsGlobal.GameScenario.CameraNode.get_limit_l(), 
				VarsGlobal.GameScenario.CameraNode.get_limit_r()
			), 
			rand_range(
				_initial_position_onfloor.y - 280, 
				_initial_position_onfloor.y - 250
			)
		)
		ObjInstance.global_position = pos_to_spawn
		VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
	
func spawn_pilars(offsetannette: float = 0) -> void :
	var pos_to_spawn: Vector2 = global_position
	pos_to_spawn.x += offsetannette
	pilar(pos_to_spawn)
	var offseting: float = 0
	for _n in range(20):
		offseting += 40
		pilar(pos_to_spawn + Vector2(offseting, 0))
		pilar(pos_to_spawn + Vector2(offseting * - 1, 0))

func start_spheres() -> void :
	Audio.play_sfx("lasershort4")
	Audio.play_sfx("ec_shoot")
	for Sphe in get_tree().get_nodes_in_group("annete_spheres"):
		Sphe.start_move(180)
		Sphe.remove_from_group("annete_spheres")

func spawn_bolts_h(targetnodename: String) -> void :
	Audio.play_sfx("spell_shoot")
	var ObjInstance = Bolt.instance()
	ObjInstance.auto_target = false
	ObjInstance.global_position = $Body / Sprite / ElementalCircuit.global_position
	ObjInstance.target_position = get_node("%" + targetnodename).global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_bolts_desperate(targetnodename: String) -> void :
	Audio.play_sfx("spell_shoot")
	var ObjInstance = Bolt.instance()
	ObjInstance.auto_target = true
	ObjInstance.speed = 300
	ObjInstance.global_position = get_node("Body/Sprite/CircuitsEnd/" + targetnodename).global_position
	ObjInstance.target_position = Enemy.get_player_position(Vector2(0, - 30))
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func explosion() -> void :
	var ObjInstance = Explosion.instance()
	ObjInstance.global_position = $Body / Sprite / ElementalCircuit.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	emit_signal("explosion_exploted")

func spark_projectile() -> void :
	var ObjInstance = Spark.instance()
	ObjInstance.dir = Enemy.facing
	ObjInstance.global_position = $Body / Sprite.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	pilar(Enemy.get_player_position(), 0.5)

func pilar_desperate() -> void :
	pilar(Enemy.get_player_position())

func pilar(postospawn: Vector2, delay: float = 0) -> void :
	var ObjInstance = Pilar.instance()
	ObjInstance.global_position = postospawn
	ObjInstance.delay_start = delay
	ObjInstance.add_to_group("annette_pilar1")
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func pilar2(dir: int = 0, limited: bool = true) -> void :
	
	if (
		get_tree().get_nodes_in_group("pilar2_annette").size() >= 2
		and limited == true
	):
		return
	
	randomize()
	
	var initial_y_pos: float = _initial_position_onfloor.y + 30

	var postospawn: = Vector2(
		global_position.x, 
		initial_y_pos
	)
	var ObjInstance = Pilar2.instance()
	
	
	
	
	if dir == 0:
		dir = RNGTools.pick([1, - 1])
	
	if dir == - 1:
		postospawn.x = VarsGlobal.GameScenario.CameraNode.get_limit_l()
	elif dir == 1:
		postospawn.x = VarsGlobal.GameScenario.CameraNode.get_limit_r()
	
	ObjInstance.dir = dir
	ObjInstance.global_position = postospawn
	ObjInstance.add_to_group("pilar2_annette")
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func snd_teleportfast() -> void :
	Audio.play_sfx("lasershort4")
func snd_explosion_pre() -> void :
	Audio.play_sfx("crystal_soul_generating2")
func snd_explosion_pre2() -> void :
	Audio.play_sfx("spell_prepare2")
func snd_teleport_in() -> void :
	$lasershort.play()
	$vlad_spawn_start.play()
func snd_teleport_out() -> void :
	$lasershort3.play()
	$vlad_spawn_end.play()

func _on_AreaDetectFloorDown_body_entered(_body: Node) -> void :
	if Enemy.state == "dead":
		velocity.x = 0
		_move_x_enabled = false
		$AnimationPlayer.play("crouch")

func _on_HurtboxEnemy_defeated() -> void :
	
	clear_firehydro()
	$AnimationPlayer.play("RESET")
	yield(get_tree(), "idle_frame")
	$AnimationPlayer.play("dead")
	VarsGlobal.Player.invencibility(3, false)
	_enable_gravity(true)
	if VarsGlobal.game_data["player_hp_now"] > 0:
		VarsGlobal.GameInterface.can_pause = false
		VarsGlobal.Player.set_enabled_input(false)
		VarsGlobal.Player.stop_move()
		yield(get_tree().create_timer(3), "timeout")
		Audio.play_music("after_cavendish")
		VarsGlobal.GameInterface.start_dialog("annie-defeated")
		yield(VarsGlobal.GameInterface, "dialog_ended")
	
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
	
	if (
		Config.get_value(
			"difficulty", "desperation_attack", true)
	) == true:
		$AnimationPlayer.play("bigexplosion")
	
	else:
		_on_desperate_end()

func _on_attack_finished() -> void :

	_enable_gravity(true)
	
	if battle_phase == 0:
		Enemy.change_state("idle")
		yield(get_tree().create_timer(2), "timeout")
	
	elif battle_phase == 1 or battle_phase == 2:
		Enemy.change_state("idle")
		yield(get_tree().create_timer(1), "timeout")
	
	elif battle_phase > 2 and Enemy.state == "spread":
		spawn_firehydro(false)

	next_move()

func _on_HurtboxEnemy_damaged() -> void :
	
	var hp_percent: = FuncsNumbers.get_percentage(
		HurtboxEnemy.hp_now, HurtboxEnemy.hp_max
	)
	
	if hp_percent >= 60 and hp_percent < 80 and battle_phase < 1:
		battle_phase = 1
		_current_move_phase = 0
	
	elif hp_percent < 60 and battle_phase < 2:
		battle_phase = 2
		_current_move_phase = 2
	
	elif (
		hp_percent <= 40
		and HurtboxEnemy.hp_now > 0
		and VarsGlobal.game_data["player_hp_now"] > 0
		and battle_phase < 3
	):
		battle_phase = 3
		_current_move_phase = 2

func _on_Annette1_explosion_exploted() -> void :
	
	spawn_rocks_falling()

func _on_desperate_end() -> void :
	_vibration()
	clear_firehydro()
	Audio.play_sfx("explosion_clean")
	Audio.play_sfx("explosion_grijayla_cinematic")
	snd_teleport_in()
	snd_teleport_out()
	VarsGlobal.GameInterface.show_flash("flash", Color.white)
	emit_signal("battle_ended")
	BossNode.unlock_boss_doors()
	queue_free()
