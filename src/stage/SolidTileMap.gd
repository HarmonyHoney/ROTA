tool
extends TileMap

onready var auto = get_child(0)

func _ready():
	yield(get_parent(), "ready")
	tile_set.tile_set_modulate(0, Color(0, 0, 0, 0))
	make_tiles(auto)

func set_cell(x, y, tile, flip_x=false, flip_y=false, transpose=false, autotile_coord=Vector2()):
	.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)
	for _x in range(x - 1, x + 2):
		for _y in range(y - 1, y + 2):
			set_tile(_x, _y, auto)

func make_tiles(map : TileMap):
	map.clear()
	var r = get_used_rect()
	for x in range(r.position.x - 1, r.position.x + r.size.x + 1):
		for y in range(r.position.y - 1, r.position.y + r.size.y + 1):
			set_tile(x, y, auto)

func set_tile(x : int, y : int, map):
	var up_left = int(get_cell(x, y) != -1)
	var up_right = int(get_cell(x + 1, y) != -1)
	var down_right = int(get_cell(x + 1, y + 1) != -1)
	var down_left = int(get_cell(x, y + 1) != -1)
	
	# calculate tile value
	var tile_value = up_left + (up_right * 2) + (down_right * 4) + (down_left * 8)

	# create tile
	var tile = -1
	var fx := false
	var fy := false
	var tr := false
	
	var solid = 0
	var corner = 1
	var flat = 2
	var inside = 3
	var meeting = 4
	
	match tile_value:
		1:
			tile = corner
			fx = true
			fy = true
		2:
			tile = corner
			fy = true
		3:
			tile = flat
			fy = true
		4:
			tile = corner
		5:
			tile = meeting
			fx = true
		6:
			tile = flat
			tr = true
			fy = true
		7:
			tile = inside
			fy = true
		8:
			tile = corner
			fx = true
		9:
			tile = flat
			tr = true
			fx = true
		10:
			tile = meeting
		11:
			tile = inside
			fx = true
			fy = true
		12:
			tile = flat
		13:
			tile = inside
			fx = true
		14:
			tile = inside
		15:
			tile = solid
	
	if !map: map = get_child(0)
	map.set_cell(x, y, tile, fx, fy, tr)

