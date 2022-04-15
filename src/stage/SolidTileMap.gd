tool
extends TileMap

onready var auto = get_child(0)
export var detail := 0 setget set_tileset

var sets = [preload("res://src/stage/tileset/TileSet0.tres"),preload("res://src/stage/tileset/TileSet1.tres"),
preload("res://src/stage/tileset/TileSet2.tres"),preload("res://src/stage/tileset/TileSet3.tres"),
preload("res://src/stage/tileset/TileSet4.tres"),preload("res://src/stage/tileset/TileSet5.tres")]

export var bg_palette := 0

func _ready():
	set_tileset()
	
	tile_set.tile_set_modulate(0, Color(0, 0, 0, 0))
	make_tiles()
	
	if !Engine.editor_hint:
		if get_used_rect() != Rect2(0, 0, 0, 0):
			Boundary.add_shape(get_used_rect(), cell_size)
		
		if bg_palette > 0:
			BG.set_colors(bg_palette)

func set_tileset(arg := detail):
	detail = posmod(int(arg), 6)
	if auto and detail < sets.size():
		if sets[detail] is TileSet:
			auto.tile_set = sets[detail]
			auto.update()

func set_cell(x, y, tile, flip_x=false, flip_y=false, transpose=false, autotile_coord=Vector2()):
	.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)
	
	# larger range while in game
	var n = 1 if Engine.editor_hint else 2
	
	# set tile range
	for _x in range(x - n, x + n):
		for _y in range(y - n, y + n):
			set_tile(_x, _y)

func make_tiles():
	auto.clear()
	var r = get_used_rect()
	for x in range(r.position.x - 1, r.position.x + r.size.x + 1):
		for y in range(r.position.y - 1, r.position.y + r.size.y + 1):
			set_tile(x, y)

func set_tile(x : int, y : int):
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
	
	if !auto: auto = get_child(0)
	auto.set_cell(x, y, tile, fx, fy, tr)

