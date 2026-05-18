extends KinematicBody2D

var velocity: = Vector2()

var gravity: int = 350

var speed: int = 80

var _revived: bool

var _can_revive: bool = true

onready var Enemy = $EnemyBase
onready var AreaNoFloor = $Sprite / DetectNoFloor

func _ready() -> void :
	Enemy.change_state("walk", true)

func _physics_process(delta) -> void :
	
	if Enemy.state == "walk":
		velocity.x = speed * Enemy.facing

	if Enemy.state in ["idle", "dead"]:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	if (is_on_floor() and Enemy.state == "walk") and (is_on_wall() or AreaNoFloor.is_colliding() == false):
		Enemy.change_direction("inverse")

func snd_revive() -> void :
	Audio.play_sfx("skeleton_reborn")

func _on_TimerToRevive_timeout() -> void :
	if _can_revive == true:
		_revived = true
		Enemy.state = "idle"
		$HurtboxEnemy.hp_now = $HurtboxEnemy.hp_max
		Enemy.change_direction("to_player")
		Enemy.change_state("revive", true)

func _on_HurtboxEnemy_defeated() -> void :
	randomize()
	$TimerToRevive.start(
		rand_range(3, 4)
	)

func _on_EnemyBase_state_changed(state) -> void :
	if state == "walk" and _revived == true:
		_revived = false
		$HurtboxEnemy.set_enabled_hurtbox(true)
		$HitboxEnemy.set_deferred("monitorable", true)

func _on_HurtboxEnemy_defeated_by_weakness() -> void :
	_can_revive = false
	$HurtboxEnemy.add_to_death_count_on_defeat = true
	$HurtboxEnemy.emit_signal("defeated")
	if VarsGlobal.add_exp($HurtboxEnemy.exp_val) == true:
		VarsGlobal.GameInterface.show_levelup_reached()

func _on_HurtboxEnemy_damaged() -> void :
	if AreaNoFloor.is_colliding() == true and Enemy.state != "dead":
		velocity.x = 0
		Enemy.change_direction("to_player")

func _on_AreaDetectPlayerExited_area_exited(_area: Area2D) -> void :
	_on_HurtboxEnemy_damaged()
