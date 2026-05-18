extends KinematicBody2D

var velocity: = Vector2()

var gravity: int = 250

var speed: int = 40

onready var Enemy = $EnemyBase
onready var Spr = $PossesedGirlCursed
onready var SkeletonBoat = $SkeletonBoat
onready var TimerDirCoolDown = $TimerDirCoolDown

onready var AreaDetectPlayerFront = $PossesedGirlCursed / AreaDetectPlayerFront
onready var AreaDetectPlayerBack = $PossesedGirlCursed / AreaDetectPlayerBack

var _original_hurtbox_def: int

func _ready() -> void :
	Enemy.change_state("idle", true)
	_original_hurtbox_def = $HurtboxEnemy.defense_rating
	
	
	if $PutEnemyHere.get_children().size() > 0:
		var EnemyScene = $PutEnemyHere.get_children()[0]
		if EnemyScene.get_node_or_null("EnemyBase") != null:
			$HurtboxEnemy.defense_rating = 9999999999
			$HurtboxEnemy.data_enemy["defense_rating"] = 9999999999
			EnemyScene.get_node("EnemyBase").connect(
				"enemy_defeated", self, "_on_carried_enemy_defeated"
			)
		

func _physics_process(delta: float) -> void :
	
	SkeletonBoat.scale.x = Spr.scale.x
	
	if Enemy.state == "walk":
		velocity.x = speed * Enemy.facing
	elif Enemy.state == "walk-inverse":
		
		velocity.x = speed * (Enemy.facing * - 1)

	if Enemy.state in ["idle", "dead"]:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)

	if is_on_floor() and Enemy.state == "walk" and is_on_wall():
		Enemy.change_direction("inverse")
	elif is_on_floor() and Enemy.state == "walk-inverse" and is_on_wall():
		Enemy.change_state("walk")

func _on_carried_enemy_defeated(_EnemyNode) -> void :
	$HurtboxEnemy.defense_rating = _original_hurtbox_def
	$HurtboxEnemy.data_enemy["defense_rating"] = _original_hurtbox_def

func _on_VisibilityNotifier2D_screen_entered() -> void :
	Enemy.change_state("walk")
	Enemy.change_direction("to_player")

func _on_AreaDetectPlayerFront_object_entered(_Obj) -> void :
	if TimerDirCoolDown.is_stopped() == false:
		return
	Enemy.change_state("walk-inverse")
	TimerDirCoolDown.start(0.5)

func _on_AreaDetectPlayerFront_object_exited(_Obj) -> void :
	if TimerDirCoolDown.is_stopped() == false:
		return
	Enemy.change_state("walk")
	TimerDirCoolDown.start(0.5)

func _on_AreaDetectPlayerBack_object_entered(_Obj) -> void :
	if TimerDirCoolDown.is_stopped() == false:
		return
	Enemy.change_direction("to_player")
	TimerDirCoolDown.start(0.5)

func _on_HurtboxEnemy_damaged() -> void :
	if AreaDetectPlayerFront.is_colliding() and Enemy.state in ["walk", "idle"]:
		Enemy.change_state("walk-inverse")
		Enemy.change_direction("to_player")
	if AreaDetectPlayerBack.is_colliding():
		Enemy.change_direction("to_player")
