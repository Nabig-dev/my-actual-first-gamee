extends Reference

class_name PhysicsHelper

static func calculate_arc_vel(
	point_a: Vector2, point_b: Vector2, arc_height: float, 
	up_gravity: float = 5, down_gravity = null
):
	
	if down_gravity == null:
		down_gravity = up_gravity
		
	var velocity = Vector2()
	
	var displacement = point_b - point_a
	
	if displacement.y > arc_height:
		var time_up = sqrt( - 2 * arc_height / up_gravity)
		var time_down = sqrt(2 * (displacement.y - arc_height) / float(down_gravity))
		
		velocity.y = - sqrt( - 2 * up_gravity * arc_height)
		velocity.x = displacement.x / float(time_up + time_down)
	
	return velocity
