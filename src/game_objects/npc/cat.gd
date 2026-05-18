extends KinematicBody2D

export var cat: int
export var dir: int = 1
export var auto_queue: bool = true

var rescued: bool

var cats_textures: Array = [
	preload("res://assets/sprites/npc/cat_0.png"), 
	preload("res://assets/sprites/npc/cat_1.png"), 
	preload("res://assets/sprites/npc/cat_2.png")
]

onready var AnimPlayer = $AnimationPlayer
onready var VisibNot = $VisibilityNotifier2D
onready var MeowSprite = $Sprite / Meow

var state: String

var _idecat: String

func _ready() -> void :
	_idecat = "sophiacat" + str(cat)
	
	if VarsGlobal.has_flag(_idecat) == true and auto_queue == true:
		queue_free()
	
	rescued = VarsGlobal.has_flag(_idecat)
	$Sprite.scale.x = dir
	$Sprite.texture = cats_textures[cat]
	change_state("idle")

func meow() -> void :
	if VisibNot.is_on_screen() == true:
		Audio.play_sfx("cat_meow")

func change_state(new_state: String) -> void :
	if state != new_state:
		MeowSprite.frame = 0
		state = new_state
		AnimPlayer.play(state)

func _on_TimerMeow_timeout() -> void :
	change_state("meow")

func _on_InteractableArea2DIndicator_interact_requested():
	
	if VarsGlobal.game_data["player_key_objects"].has(GVar.KEYS_OBJECTS.FISH_TOY) and rescued == false:
		VarsGlobal.add_flag(_idecat)
		Audio.play_sfx("cat_meow")
		VarsGlobal.GameInterface.show_quick_text(
			"IGOTYOU", VarsGlobal.Player
		)
		queue_free()
	
	else:
		
		VarsGlobal.GameInterface.show_quick_text(
			"HOWCUTE", VarsGlobal.Player
		)
		$InteractableArea2DIndicator / CollisionShape2D.queue_free()
