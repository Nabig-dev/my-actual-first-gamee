extends KinematicBody2D

signal battle_ended
signal shield_broken
signal hit_received

var SpawnLance = preload("res://src/game_objects/enemies_weapons/lance_spawn_johannes.tscn")


var velocity: = Vector2()

var gravity: int = 600

var speed: int = 30

var current_hits: int = 0
var max_hits: int = 25

var _dashing: bool
var _defeated: bool

onready var Enemy = $EnemyBase
onready var BossNode = $BossNode
onready var DetectWallBack = $BossJohannes1 / DetectWallBack
onready var DetectWallFront = $BossJohannes1 / DetectWallFront
onready var TimerNextMove = $TimerNextMove
onready var AnimPlayer = $AnimationPlayer
onready var GhostTrail = $GhostTrail

func _physics_process(delta: float) -> void :
	
	if Enemy.state == "walk":
		velocity.x = (speed * 2) * Enemy.facing
	if Enemy.state == "shield":
		velocity.x = 0
	elif Enemy.state in ["idle", "idle2", "hurt"]:
		velocity.x = 0
	
	if _dashing == true:
		if Enemy.state.begins_with("atk"):
			velocity.x = (speed * 6) * Enemy.facing
	
	if Enemy.state == "walk" and DetectWallFront.is_colliding():
		Enemy.change_direction("inverse")
	elif Enemy.state == "walkinverse" and DetectWallBack.is_colliding():
		Enemy.change_state("walk")
	
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP, true)

func spawn_lance() -> void :
	if _defeated == true or VarsGlobal.game_data["difficulty_base"] == 0:
		return
	randomize()
	var ObjInstance = SpawnLance.instance()
	ObjInstance.add_to_group("johannes_lance")
	ObjInstance.global_position = Vector2(
		rand_range(
			VarsGlobal.GameScenario.CameraNode.limit_left + 30, 
			VarsGlobal.GameScenario.CameraNode.limit_right - 30
		), 
		global_position.y - 140
	)
	
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	

func sword_prepare() -> void :
	Audio.play_sfx("spell_prepare")
func bulletimpactsword() -> void :
	Audio.play_sfx("impact_iron_clang")

func set_dash(val: bool) -> void :
	_dashing = val

func snd_sword() -> void :
	Audio.play_sfx("sword_slash_slow")
func snd_prepare_megido() -> void :
	Audio.play_sfx("spell_prepare4")

func megido_crush() -> void :
	Audio.play_sfx("thunder_2")
	Audio.play_sfx("thunder_0")
	Audio.play_sfx("spell_shoot")
	Audio.play_sfx("impact_earth2")
	VarsGlobal.GameScenario.CameraNode.start_shake(0.4)
	Gamepad.start_vibration(0, 0.8, 0.8, 0.5)
	Engine.time_scale = 0.6
	VarsGlobal.GameInterface.can_pause = false

func start_battle() -> void :
	BossNode.show_title_boss()
	Audio.play_music("tension_battle", "high", 0)
	$KeyObject.queue_free()
	BossNode.start_battle()
	next_move()

func next_move() -> void :
	
	randomize()
	
	GhostTrail.stop_trail()
	Enemy.change_direction("to_player")
	Enemy.change_state("idle2")
	
	TimerNextMove.start(1)
	yield(TimerNextMove, "timeout")
	if _defeated == true: return
	
	Enemy.change_direction("to_player")
	Enemy.change_state("walk")
	TimerNextMove.start(rand_range(1.5, 2.5))
	yield(TimerNextMove, "timeout")
	if _defeated == true: return
	
	GhostTrail.start_trail(0, 0.05)
	velocity.x = 0
	Enemy.change_direction("to_player")
	Enemy.change_state(RNGTools.pick(["atk-a", "atk-b", "atk-c"]))
	yield(AnimPlayer, "animation_finished")
	GhostTrail.stop_trail()
	if _defeated == true: return
	
	if $TimerSpawnLance.is_stopped():
		$TimerSpawnLance.start()
	
	next_move()

func shield_advance() -> void :
	global_position.x += 2 * Enemy.facing

func _on_TimerSpawnLance_timeout() -> void :
	randomize()
	$TimerSpawnLance.start(rand_range(2, 4))
	spawn_lance()


func _on_HurtboxEnemy_area_entered(area: Area2D) -> void :
	if _defeated == true:
		return
	
	if area.identifier.begins_with("whip"):
		current_hits += 1
		if current_hits >= max_hits:
			VarsGlobal.GameScenario.get_node("CanvasLayer/Control/BatleProgressBar").visible = false
			_defeated = true
			velocity.x = 0
			_dashing = false
			GhostTrail.stop_trail()
			TimerNextMove.stop()
			get_tree().call_group("johannes_lance", "queue_free")
			
			set_physics_process(false)
			
			Engine.time_scale = 0.5
			VarsGlobal.GameInterface.can_pause = false
			Enemy.change_state("megido")
			yield(AnimPlayer, "animation_finished")
			
			emit_signal("battle_ended")
			VarsGlobal.GameInterface.show_flash()
			Engine.time_scale = 1
		else:
			emit_signal("hit_received")

func _on_shield_spawned() -> void :
	
	pass



func _on_HurtboxShield_area_entered(area: Area2D) -> void :
	if _defeated == false:
		return
	
	if area.identifier.begins_with("whip"):
		current_hits += 1
		if current_hits >= max_hits:
			$TimerToUltraMegido.stop()
			VarsGlobal.GameScenario.get_node("CanvasLayer/Control/BatleProgressBar").visible = false
			if $BossJohannes1 / HurtboxShield.is_connected("area_entered", self, "_on_HurtboxShield_area_entered") == true:
				$BossJohannes1 / HurtboxShield.disconnect("area_entered", self, "_on_HurtboxShield_area_entered")
			
			Enemy.change_state("defeated")
			$BossJohannes1 / ParticlesCharge.emitting = false
			$BossJohannes1 / ParticlesCharge2.emitting = false
			emit_signal("shield_broken")
		else:
			emit_signal("hit_received")


func _on_TimerToUltraMegido_timeout() -> void :
	Enemy.change_state("ultra_megido")
	if $BossJohannes1 / HurtboxShield.is_connected("area_entered", self, "_on_HurtboxShield_area_entered") == true:
		$BossJohannes1 / HurtboxShield.disconnect("area_entered", self, "_on_HurtboxShield_area_entered")
