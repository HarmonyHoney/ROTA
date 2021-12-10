tool
extends TileMap

export var is_update := false setget set_update

onready var map : TileMap = $Offset

func set_update(arg):
	is_update = arg
	set_tiles()

func set_tiles():
	map.clear()
#	for i in get_used_cells():
#		map.set_cellv(i, 0)
	
	
	for i in get_used_cells():
		for v in [Vector2.ZERO, Vector2.RIGHT, Vector2.DOWN, Vector2.ONE]:
			map.set_cellv(i + v, 0)
	
	var rect = map.get_used_rect()
	map.update_bitmask_region(rect.position, rect.end)
