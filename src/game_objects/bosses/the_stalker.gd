extends KinematicBody2D

signal damaged
signal floor_impacted

var Treasure = preload("res://src/game_objects/treasure_object.tscn")
var FireBall = preload("res://src/game_objects/enemies_weapons/witiko_fireball.tscn")
var Rock = preload("res://src/game_objects/enemies_weapons/rock_random_fall.tscn")

var velocity: = Vector2()

var gravity: int = 250

var speed: int = 25

var patterns: Array = [
	"jump", "idle", "fast_atk", "laser", "fireball"
]

var _was_on_floor: bool
var _initial_position_onfloor: Vector2
var _last_atk: String

var spawn_rocks_on_fall: bool

onready var Enemy = $EnemyBase
onready var HurtboxEnemy = $Sprite / HurtboxEnemy
onready var Position2DFireBall = $Sprite / Position2DFireBall
onready var TimerDamaged = $TimerDamaged

onready var ParticlesRocks = $ParticlesRocks

var _attacks_made: int = 0

func _ready() -> void :
	HurtboxEnemy.set_enabled_hurtbox(false)
	if $BossNode.boss_ide == "boss_witiko2":
		HurtboxEnemy.blood_drop = 1

func _physics_process(delta) -> void :
	

	_was_on_floor = is_on_floor()

	if is_on_floor() and Enemy.state in ["idle", "dead"]:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)

	if _was_on_floor == false and is_on_floor() == true:
		spawn_rocks_falling()
		earth_shake()

func spawn_rocks_falling() -> void :
	if spawn_rocks_on_fall == false or VarsGlobal.game_data["difficulty_base"] == 0:
		return
	randomize()
	var rocks_num: int = 4
	if $BossNode.boss_ide == "boss_witiko":
		rocks_num = 3
	for _n in range(rocks_num):
		var ObjInstance = Rock.instance()
		var pos_to_spawn: = Vector2(
			rand_range(
				VarsGlobal.GameScenario.CameraNode.get_limit_l(), 
				VarsGlobal.GameScenario.CameraNode.get_limit_r()
			), 
			rand_range(
				_initial_position_onfloor.y - 230, 
				_initial_position_onfloor.y - 200
			)
		)
		ObjInstance.global_position = pos_to_spawn
		VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
func earth_shake() -> void :
	_initial_position_onfloor = global_position
	ParticlesRocks.emitting = true
	Audio.play_sfx("explosion_grijayla_cinematic")
	Audio.play_sfx("impact_earth2")
	velocity.x = 0
	VarsGlobal.GameScenario.CameraNode.start_shake(0.4)
	Gamepad.start_vibration(0, 0.8, 0.8, 0.5)
	emit_signal("floor_impacted")

func start_battle() -> void :
	
	spawn_rocks_on_fall = true
	Enemy.change_state("startbattle", true)
	
func _on_StartBattleEnd() -> void :
	$BossNode.start_battle()
	HurtboxEnemy.set_enabled_hurtbox(true)
	Enemy.change_state("idle", true)
	$TimerChangeMove.start(1)

func get_player_pos() -> Vector2:
	randomize()
	var pos: Vector2 = VarsGlobal.Player.global_position
	pos.y -= RNGTools.randi_range(10, 35)
	return pos

func _play_slash_snd() -> void :
	Audio.play_sfx("sword_slash_slow")

func _start_fire_snd() -> void :
	Audio.play_sfx("fire_burning_loop", true, 0.3)
func _stop_fire_snd() -> void :
	Audio.stop_sfx("fire_burning_loop", true)

func _spawn_fireball() -> void :
	Audio.play_sfx("shoot_projectile")
	Enemy.change_direction("to_player")
	var rotation_obj: float = rad2deg(
		Position2DFireBall.global_position.angle_to_point(get_player_pos())
	) - 90
	var ObjInstance = FireBall.instance()
	ObjInstance.global_position = Position2DFireBall.global_position
	ObjInstance.rotation_degrees = rotation_obj
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _jump() -> void :
	velocity.y -= 150
	velocity.x = 200 * Enemy.facing

func _play_growl() -> void :
	Audio.play_sfx("monster_growl_0")

func _low_rumble() -> void :
	VarsGlobal.GameScenario.CameraNode.start_shake(0.2)
	Gamepad.start_vibration(0, 0.3, 0.3, 0.2)

func _rumble() -> void :
	VarsGlobal.GameScenario.CameraNode.start_shake(0.3, true, true)
	Gamepad.start_vibration(0, 0.8, 0.8, 0.4)

func _show_radial_lines() -> void :
	VarsGlobal.GameInterface.show_radial_lines(2.8)

func _on_HurtboxEnemy_damaged() -> void :
	emit_signal("damaged")
	TimerDamaged.start(0.5)
	if Enemy.state == "idle":
		Enemy.change_direction("to_player")

func _on_HurtboxEnemy_defeated() -> void :
	_laser_stop()
	_stop_fire_snd()
	$HurtboxEnemyInvincible.queue_free()

func _on_TimerChangeMove_timeout() -> void :
	if Enemy.state == "dead" or is_on_floor() == false:
		return
	randomize()
	if Enemy.state == "idle":
		var new_st: String = patterns[randi() % patterns.size() - 1]
		

		
		if _attacks_made > 3:
			_attacks_made = 0
			new_st = "jump"
		
		Enemy.change_state(new_st)
		_last_atk = new_st
		_attacks_made += 1
	

	if _last_atk == "jump":
		$TimerChangeMove.start(4)
	else:
		$TimerChangeMove.start(1)

func _on_EnemyBase_state_changed(state: String) -> void :
	$Sprite / HitboxEnemyLaser / CollisionShape2D.set_deferred("disabled", true)
	$Sprite / HitboxEnemyArm / CollisionShape2D.set_deferred("disabled", true)
	if state == "idle":
		Enemy.change_direction("to_player")
	if state in ["laser", "fireball"]:
		Audio.play_sfx("monster_little_roar")

func _on_HurtboxEnemyInvincible_area_entered(_area: Area2D) -> void :
	if TimerDamaged.is_stopped() == true:
		Audio.play_sfx("ui_incorrect")

func _on_Witiko_tree_exiting() -> void :
	Audio.stop_sfx("fire_burning_loop")

func _on_HurtboxEnemy_area_entered(area: Area2D) -> void :
	if "identifier" in area and Enemy.state != "dead":
		
		if area.identifier == "whip_h":
			$TimerChangeMove.stop()
			Audio.play_sfx("monster_growl_1_death")
			Audio.stop_sfx("monster_little_roar")
			Enemy.change_state("damaged", true)
			
			$TimerChangeMove.start(3)
			_laser_stop()

func _laser_stop() -> void :
	
	_stop_fire_snd()
	$Sprite / SpriteLaser.visible = false
	$Sprite / HitboxEnemyLaser / CollisionShape2D.set_deferred("disabled", true)
	$Sprite / LaserCPUParticles2D.emitting = false
	$Sprite / FireCPUParticles2D.emitting = false
	$Sprite / FireCPUParticles2D2.emitting = false
	$Sprite / FireCPUParticles2D3.emitting = false

func _on_BossNode_defeated_with_no_damage() -> void :
	if VarsGlobal.has_flag("prologue_finished") == false:
		return
	var ObjInstance = Treasure.instance()
	ObjInstance.global_position = $Sprite / HurtboxEnemy.global_position
	ObjInstance.item = GVar.TREASURES.RUBY
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
