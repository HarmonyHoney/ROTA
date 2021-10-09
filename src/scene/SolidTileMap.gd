extends TileMap

onready var map = $AutoTileMap

func _ready():
	tile_set.tile_set_modulate(0, Color(1, 1, 1, 0))
	make_tiles()

func make_tiles():
	for i in get_used_cells():
		for v in [Vector2.ZERO, Vector2.RIGHT, Vector2.DOWN, Vector2.ONE]:
			map.set_cellv((i * 2) + v, 3)
	
	var rect = map.get_used_rect()
	map.update_bitmask_region(rect.position, rect.end)
