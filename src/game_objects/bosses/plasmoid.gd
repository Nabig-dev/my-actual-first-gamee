extends KinematicBody2D




var velocity: Vector2
var gravity: int = 500
var speed: int = 60

var moves: Array = ["atksmash", "atktail", "run"]

var Treasure = preload("res://src/game_objects/treasure_object.tscn")

var Spawner = preload("res://src/game_objects/enemies_weapons/plasmoid_slime_spawner.tscn")

onready var Enemy = $EnemyBase
onready var BossNode = $BossNode

func _ready() -> void :
	Enemy.change_state("sleeping")





func snd_tail() -> void :
	Audio.play_sfx("shine2")

func spawn_slimes() -> void :
	
	Audio.play_sfx("impact_earth2")
	VarsGlobal.GameScenario.CameraNode.start_shake(
		0.5, true, 
		true, false
	)
	Gamepad.start_vibration(0, 0.8, 0.8, 0.5)
	
	
	if get_tree().get_nodes_in_group("slime_spawned").size() > 5:
		return
	
	for _n in range(2):
		var ObjInstance = Spawner.instance()
		ObjInstance.global_position = $Sprite / Position2DSpawn.global_position
		ObjInstance.kick(Enemy.facing)
		VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)


func reset_cols_etc() -> void :
	$Sprite / HitboxEnemy / CollisionHead.set_deferred("disabled", true)
	$Sprite / HitboxEnemy / CollisionTail.set_deferred("disabled", true)
	$Sprite / PreAtk.modulate.a = 0

func prepare_next_move() -> void :
	randomize()
	var next_move: String = moves[randi() % moves.size()]
	
	
	if (
		next_move == "atktail"
		and Enemy.get_player_distance() > 100
	):
		next_move = "idle"
	
	Enemy.change_direction("to_player")
	Enemy.change_state(next_move)



func start_battle() -> void :
	Audio.play_sfx("toxic_release2")
	Enemy.change_state("wakeup")


func set_velocity_x(vel_x: int) -> void :
	velocity.x = vel_x * Enemy.facing

func _physics_process(delta: float) -> void :
	
	if Enemy.state == "run":
		velocity.x = speed * Enemy.facing
		if is_on_wall():
			Enemy.change_direction("inverse")
	elif Enemy.state == "atksmash":
		pass
	else:
		velocity.x = 0
	
	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void :
	
	if anim_name == "wakeup":
		Audio.play_music(BossNode.battle_song, "high", 0.0)
		BossNode.show_title_boss()
		yield(get_tree().create_timer(1), "timeout")
		BossNode.start_battle()
		Enemy.change_state("idle")
		$TimerNextMove.start()

	elif anim_name in ["atksmash", "atktail"]:
		Enemy.change_state("idle")

func _on_TimerNextMove_timeout() -> void :
	if Enemy.state in ["idle", "run"]:
		
		prepare_next_move()


func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state == "idle":
		Enemy.change_direction("to_player")


func _on_EnemyBase_state_changed(_state) -> void :
	reset_cols_etc()


func _on_HurtboxEnemy_defeated() -> void :
	for n in get_tree().get_nodes_in_group("slime_spawned"):
		n.get_node("HurtboxEnemy").queue_free()
		n.get_node("HitboxEnemy").queue_free()
		n.Enemy.change_state("dead")
		Audio.play_sfx("toxic_release2")


func _on_BossNode_defeated_with_no_damage() -> void :
	var ObjInstance = Treasure.instance()
	ObjInstance.global_position = $Sprite / HurtboxEnemy.global_position
	ObjInstance.item = GVar.TREASURES.DEMON_SKULL
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
