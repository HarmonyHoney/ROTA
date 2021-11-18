extends TileMap

onready var auto : TileMap = $AutoTileMap

func _ready():
	get_parent().connect("ready", self, "parent_ready")

func parent_ready():
	tile_set.tile_set_modulate(0, Color(0, 0, 0, 0))
	make_tiles(auto)

func make_tiles(map : TileMap):
	for i in get_used_cells():
		for v in [Vector2.ZERO, Vector2.RIGHT, Vector2.DOWN, Vector2.ONE]:
			map.set_cellv((i * 2) + v, 0)
	
	var rect = map.get_used_rect()
	map.update_bitmask_region(rect.position, rect.end)
