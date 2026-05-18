tool 
extends Node2D

export (
	String, 
	"Gabriel", "Margaret", "Waitress", "Alessa", 
	"Isabel", "Evelyn", "Kalev", "Aura"
) var character = "Gabriel" setget _update_spriteframes
export var anim: String = "idle"

export var auto_facing: bool = true

var _spriteframes: Dictionary = {
	"Gabriel": preload("res://src/game_objects/npc/gabriel_spriteframes.tres"), 
	"Margaret": preload("res://src/game_objects/npc/margaret_spriteframes.tres"), 
	"Waitress": preload("res://src/game_objects/npc/waitress_spriteframes.tres"), 
	"Alessa": preload("res://src/game_objects/npc/alessa_spriteframes.tres"), 
	"Isabel": preload("res://src/game_objects/npc/isabel_spriteframes.tres"), 
	"Evelyn": preload("res://src/game_objects/npc/evelyn_spriteframes.tres"), 
	"Kalev": preload("res://src/game_objects/npc/kalev_spriteframes.tres"), 
	"Aura": preload("res://src/game_objects/npc/aura_spriteframes.tres")
}

onready var AnmSprite = $AnimatedSprite

func _ready() -> void :
	_update_spriteframes(character)
	if Engine.is_editor_hint() == false:
		play()

func facing_to_player() -> void :
	var player_pos: float = VarsGlobal.Player.global_position.x
	var npc_pos: float = global_position.x
	if player_pos < npc_pos:
		face_to( - 1)
	else:
		face_to(1)

func face_to(facing: int = - 1) -> void :
	scale.x = facing

func _update_spriteframes(ch: String) -> void :
	$AnimatedSprite.stop()
	character = ch
	name = "NPC" + ch
	$AnimatedSprite.frames = _spriteframes[ch]

func play(anima: String = anim) -> void :
	if AnmSprite.frames.has_animation(anima) == true:
		AnmSprite.play(anima)


func _on_TimerAutoFacing_timeout() -> void :
	if auto_facing == false:
		return
	facing_to_player()


func _on_AreaDetectPlayer_area_exited(_area: Area2D) -> void :
	if auto_facing == false:
		return
	facing_to_player()


func _on_VisibilityNotifier2D_screen_entered() -> void :
	facing_to_player()
