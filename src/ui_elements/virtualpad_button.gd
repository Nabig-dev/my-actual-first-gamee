extends TouchScreenButton

func _ready() -> void :
	for c in get_children():
		if c is CollisionPolygon2D:
			shape = ConvexPolygonShape2D.new()
			shape.points = c.polygon
