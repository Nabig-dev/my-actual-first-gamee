extends RigidBody2D

var texture_50 = preload("res://assets/sprites/coins_50.png")
var texture_100 = preload("res://assets/sprites/coins_100.png")

export (String, "1", "5", "50", "100", "500", "1000", "5000") var money = "5"

export var ide: String

func _ready() -> void :

	if (
		ide.empty() == false and 
		VarsGlobal.game_data["flags"].has(ide + "_money_obtained") == true
	):
		queue_free()
		return
	
	apply_impulse(Vector2.ZERO, Vector2(0, - 120))
	
	if money == "1":
		$Coin.visible = true
		$Sprite.visible = false
		$Bag.visible = false
	elif int(money) <= 100:
		$Coin.visible = false
		$Sprite.visible = true
		$Bag.visible = false
		$AnimationPlayer.play("show")
	else:
		$Coin.visible = false
		$Sprite.visible = false
		$Bag.visible = true
		$AnimationPlayer.play("show")

	if money == "50":
		$Sprite.texture = texture_50
	elif money == "100":
		$Sprite.texture = texture_100
	elif money == "1000":
		$Bag.frame = 1
	elif money == "5000":
		$Bag.frame = 2

	

func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	
	Audio.play_sfx("coin_get")
	
	VarsGlobal.game_data["player_money"] += int(money)
	
	VarsGlobal.GameInterface.show_notif_item_obtained("C$ " + str(money))
	
	if ide.empty() == false:
		VarsGlobal.game_data["flags"].append(ide + "_money_obtained")
	
	queue_free()
