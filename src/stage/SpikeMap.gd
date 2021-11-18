extends TileMap

var spike_scene = preload("res://src/actor/Spike.tscn")

func rot(vec = Vector2.ZERO, dir = 0):
	return vec.rotated(deg2rad(dir * 90)).round()

func _ready():
	tile_set.tile_set_modulate(0, Color(0, 0, 0, 0))
	
	var solid = get_parent().get_node("SolidTileMap")
	
	for i in get_used_cells():
		# instance spike
		var s = spike_scene.instance()
		add_child(s)
		
		# set pos
		s.position = (i + Vector2.ONE / 2) * cell_size
		
		# set dir
		var t = is_cell_transposed(i.x, i.y)
		var y = is_cell_y_flipped(i.x, i.y)
		
		if t and y:
			s.dir = 3
		elif t:
			s.dir = 1
		elif y:
			s.dir = 2
		
		# set spike floor
		var left = i + rot(Vector2(-1, 1), s.dir)
		var right = i + rot(Vector2(1, 1), s.dir)
		
		if get_cellv(left) == -1 and solid.get_cellv(left) == -1:
			s.set_tile(true)
		if get_cellv(right) == -1 and solid.get_cellv(right) == -1:
			s.set_tile(false)

