extends KinematicBody2D

var Spear = preload("res://src/game_objects/enemies_weapons/goblinbomb.tscn")


var velocity: = Vector2()

var gravity: int = 450

var speed: int = 85

onready var Enemy = $EnemyBase
onready var AreaPlayerRange = $Sprite / AreaPlayerRange
onready var Position2DSpear = $Sprite / Position2DSpear
onready var VisibleBody = $VisibleBody

func _ready() -> void :
	Enemy.change_state("idle", true)

func _physics_process(delta) -> void :

	if Enemy.state in ["idle", "attack", "dead"] and is_on_floor():
		velocity.x = 0
	elif Enemy.state == "walk":
		velocity.x = speed * Enemy.facing
	elif Enemy.state == "walk-inverse":
		
		velocity.x = (speed / 2) * (Enemy.facing * - 1)

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	if Enemy.state == "walk" and is_on_wall():
		Enemy.change_direction("inverse")
	elif Enemy.state == "walk-inverse" and is_on_wall():
		_on_TimerEndWalkInverse_timeout()

func _snd_ignite() -> void :
	Audio.play_sfx("ignite_bomb")

func make_attack() -> void :
	if Enemy.state in ["attack", "dead"]:
		return
	var pos_player: = Vector2(
		Enemy.get_player_position().x, 
		global_position.y
	)
	var distance_x: float = global_position.distance_to(pos_player)
	if distance_x > 60:
		Audio.play_sfx("goblin_laugh")
		Enemy.change_state("throw")
		Enemy.state = "attack"
	else:
		Audio.play_sfx("goblin_grunt")
		Enemy.change_state("attack")
		if is_on_floor():
			velocity.y = - 180
		$TimerMoveAfterJump.start(0.1)

func play_throw_snd() -> void :
	if VisibleBody.is_on_screen() == false:
		return
	Audio.play_sfx("woosh_throw")

func spawn_spear() -> void :
	if (
		VarsGlobal.game_data["player_hp_now"] < 1
		or VisibleBody.is_on_screen() == false
	):
		return
	Audio.stop_sfx("ignite_bomb")
	var SpearInstance = Spear.instance()
	SpearInstance.global_position = Position2DSpear.global_position
	SpearInstance.direction = Enemy.facing
	SpearInstance.target_position = Enemy.get_player_position(Vector2(0, - 32))




	VarsGlobal.GameScenario.add_child(SpearInstance)


func _on_SpearThrowed() -> void :
	if (
		AreaPlayerRange.is_colliding() and VisibleBody.is_on_screen()
		and velocity.x == 0
	):
		randomize()
		if randi() % 2 == 0:
			
			if rand_range(1, 2) > 0.5 and is_on_floor():
				velocity.y = - 120
				$TimerMoveAfterJump.start(0.1)
			Enemy.change_state("attack", true)
		
		else:
			$TimerEndWalkInverse.start(rand_range(0.5, 2))
			Enemy.change_state("walk-inverse")
		
	else:
		Enemy.change_state("walk")


func _on_AreaPlayerRange_object_entered(_Obj) -> void :
	if VisibleBody.is_on_screen() == true:
		Enemy.change_direction("to_player")
		Enemy.change_direction("to_player")
		make_attack()


func _on_VisibilityNotifierCameraArea_screen_entered() -> void :
	Enemy.change_direction("to_player")
	if Enemy.state == "idle":
		Enemy.change_state("walk")

func _on_VisibilityNotifierCameraArea_screen_exited() -> void :
	Audio.stop_sfx("ignite_bomb")
	if Enemy.state in ["walk", "walk-inverse"]:
		Enemy.change_state("idle")


func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state in ["idle", "walk", "walk-inverse"]:
		Enemy.change_direction("to_player")


func _on_AreaPlayerRange_object_exited(_Obj) -> void :
	Enemy.change_direction("to_player")


func _on_AreaBack_object_entered(_Obj) -> void :
	if Enemy.state in ["idle", "walk", "walk-inverse"]:
		Enemy.change_direction("to_player")


func _on_TimerEndWalkInverse_timeout() -> void :
	if Enemy.state != "walk-inverse":
		return
	if AreaPlayerRange.is_colliding() and VisibleBody.is_on_screen():
		make_attack()
	else:
		Enemy.change_state("walk")


func _on_DetectNoFloor_object_exited(_Obj) -> void :
	if Enemy.state in ["walk", "walk-inverse"] and is_on_floor():
		velocity.y = - 200


func _on_TimerMoveAfterJump_timeout() -> void :
	if Enemy.state == "attack" and is_on_floor() == false:
		randomize()
		var velx: float
		if $AnimationPlayer.current_animation == "attack":
			velx = 80 * Enemy.facing
		else:
			velx = RNGTools.pick([ - 40, 40])
		velocity.x = velx


func _on_EnemyBase_state_changed(state: String) -> void :
	Audio.stop_sfx("ignite_bomb")
	if state == "attack":
		Enemy.change_direction("to_player")
