tool
extends TileMap

var spike_scene = preload("res://src/actor/Spike.tscn")

var spikes = {}

func _ready():
	yield(get_parent(), "ready")
	tile_set.tile_set_modulate(0, Color(0, 0, 0, 0))
	make_tiles()

func set_cell(x, y, tile, flip_x=false, flip_y=false, transpose=false, autotile_coord=Vector2()):
	.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)
	
	remove_spike(x, y)
	
	if tile == 0:
		set_spike(Vector2(x, y))

func rot(vec = Vector2.ZERO, dir = 0):
	return vec.rotated(deg2rad(dir * 90)).round()

func make_tiles():
	spikes = {}
	
	for i in get_children():
		i.queue_free()
	
	for i in get_used_cells():
		set_spike(i)

func remove_spike(x : int, y : int):
	var key = str(x) + "," + str(y)
	
	if spikes.has(key) and is_instance_valid(spikes[key]):
		spikes[key].queue_free()
		spikes.erase(key)

func set_spike(i : Vector2):
	# instance spike
	var s = spike_scene.instance()
	add_child(s)
	spikes[str(i.x) + "," + str(i.y)] = s
	
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
