class_name Trail3D, "../icons/icon_trail_3d.svg"
extends ImmediateGeometry







export (float) var length = 10.0
export var max_radius = 0.5
export (int) var density_lengthwise = 25
export (int) var density_around = 5
export (float, EASE) var shape

var points = []
var segment_length = 1.0

func _ready():
	if length <= 0:
		length = 2
	if density_around < 3:
		density_around = 3
	if density_lengthwise < 2:
		density_lengthwise = 2

	segment_length = length / density_lengthwise
	for i in range(density_lengthwise):
		points.append(global_transform.origin)


func _process(_delta):
	update_trail()
	render_trail()


func update_trail():
	var ind = 0
	var last_p = global_transform.origin
	for p in points:
		var dis = p.distance_to(last_p)
		var seg_len = segment_length
		if ind == 0:
			seg_len = 0.05
		if dis > seg_len:
			p = last_p + (p - last_p) / dis * seg_len
		last_p = p
		points[ind] = p
		ind += 1


func render_trail():
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var local_points = []
	for p in points:
		local_points.append(p - global_transform.origin)
	var last_p = Vector3()
	var verts = []
	var ind = 0
	var first_iteration = true
	var last_first_vec = Vector3()
	
	for p in local_points:
		var new_last_points = []
		var offset = last_p - p
		if offset == Vector3():
			continue
		
		var y_vec = offset.normalized()
		var x_vec = Vector3()
		if first_iteration:
			
			x_vec = y_vec.cross(y_vec.rotated(Vector3.RIGHT, 0.3))
		else:
			
			x_vec = y_vec.cross(last_first_vec).cross(y_vec).normalized()
		var width = max_radius
		if shape != 0:
			width = (1 - ease((ind + 1.0) / density_lengthwise, shape)) * max_radius
		var seg_verts = []
		var f_iter = true
		for i in range(density_around):
			var new_vert = p + width * x_vec.rotated(y_vec, i * TAU / density_around).normalized()
			if f_iter:
				last_first_vec = new_vert - p
				f_iter = false
			seg_verts.append(new_vert)
		verts.append(seg_verts)
		last_p = p
		ind += 1
		first_iteration = false

	
	for j in range(len(verts) - 1):
		var cur = verts[j]
		var nxt = verts[j + 1]
		var uv = (j + 1.0) / (len(verts) + 1);
		var uvnxt = (j + 2.0) / (len(verts) + 1);
		for i in range(density_around):
			var nxt_i = (i + 1) % density_around
			
			set_uv(Vector2(uv, 0.0))
			add_vertex(cur[i])
			add_vertex(cur[nxt_i])
			set_uv(Vector2(uvnxt, 0.0))
			add_vertex(nxt[i])
			set_uv(Vector2(uv, 0.0))
			add_vertex(cur[nxt_i])
			set_uv(Vector2(uvnxt, 0.0))
			add_vertex(nxt[nxt_i])
			add_vertex(nxt[i])

	if verts.size() > 1:
		
		for i in range(density_around):
			var nxt = (i + 1) % density_around
			set_uv(Vector2(0, 0))
			add_vertex(verts[0][i])
			add_vertex(Vector3())
			add_vertex(verts[0][nxt])

		
		for i in range(density_around):
			var nxt = (i + 1) % density_around
			set_uv(Vector2(1, 0))
			add_vertex(verts[verts.size() - 1][i])
			add_vertex(verts[verts.size() - 1][nxt])
			add_vertex(last_p)
	end()
