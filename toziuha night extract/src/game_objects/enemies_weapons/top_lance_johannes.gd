extends RigidBody2D

func _ready() -> void :
	$AnimationPlayer.play("show")
	yield($AnimationPlayer, "animation_finished")

func _on_TopLanceJohannes_body_shape_entered(_body_rid: RID, _body: Node, _body_shape_index: int, _local_shape_index: int) -> void :
	Audio.play_sfx("impact_iron_clang")
	$Timer.start(2)
	yield($Timer, "timeout")
	$AnimationPlayer.play("dissapear")
