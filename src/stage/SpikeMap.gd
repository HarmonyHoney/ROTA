tool
extends TileMap

var spike_scene = preload("res://src/actor/Spike.tscn")

var solid : TileMap

func rot(vec = Vector2.ZERO, dir = 0):
	return vec.rotated(deg2rad(dir * 90)).round()

func _ready():
	yield(get_parent(), "ready")
	tile_set.tile_set_modulate(0, Color(0, 0, 0, 0))
	solid = get_parent().get_node("SolidTileMap")
	make_tiles()

func set_cell(x, y, tile, flip_x=false, flip_y=false, transpose=false, autotile_coord=Vector2()):
	.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)
	if tile == 0:
		set_spike(Vector2(x, y))
	else:
		for i in get_children():
			if i.position == (Vector2(x, y) + Vector2.ONE / 2) * cell_size:
				i.queue_free()

func make_tiles():
	for i in get_children():
		i.queue_free()
	
	for i in get_used_cells():
		set_spike(i)

func set_spike(i : Vector2):
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

