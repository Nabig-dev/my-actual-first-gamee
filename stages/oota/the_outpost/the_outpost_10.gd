extends Node

func _on_Area2DStartBatsAnim_area_entered(_area: Area2D) -> void :
	if VarsGlobal.has_flag("grijayla_bats_anim_started") == false:
		
		VarsGlobal.add_flag("grijayla_bats_anim_started")
		VarsGlobal.GameScenario.get_node("Decoration/CPUParticles2DBats").emitting = true
		
		VarsGlobal.GameScenario.get_node("Area2DStartBatsAnim/TimerEndBatsAnim").start(0.5)
		yield(
			VarsGlobal.GameScenario.get_node("Area2DStartBatsAnim/TimerEndBatsAnim"), "timeout"
		)
		
		Audio.play_sfx("bats_flap")

		VarsGlobal.GameScenario.get_node("Area2DStartBatsAnim/TimerEndBatsAnim").start(2.5)
		yield(
			VarsGlobal.GameScenario.get_node("Area2DStartBatsAnim/TimerEndBatsAnim"), "timeout"
		)
		
		VarsGlobal.GameScenario.get_node("Decoration/CPUParticles2DBats").emitting = false

func _on_PaperObject_obtained() -> void :
	
	
	
	
	

	
	
	
	
	
	
	
	
	
	

	
	VarsGlobal.GameInterface.start_dialog("the_outpost-map-get")
