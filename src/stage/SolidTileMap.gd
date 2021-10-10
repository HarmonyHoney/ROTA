extends TileMap

const auto = preload("res://src/stage/AutoTileMap.tscn")

func _ready():
	get_parent().connect("ready", self, "parent_ready")

func parent_ready():
	var map = auto.instance()
	make_tiles(map)
	get_parent().add_child(map)
	visible = false

func make_tiles(map : TileMap):
	for i in get_used_cells():
		for v in [Vector2.ZERO, Vector2.RIGHT, Vector2.DOWN, Vector2.ONE]:
			map.set_cellv((i * 2) + v, 3)
	
	var rect = map.get_used_rect()
	map.update_bitmask_region(rect.position, rect.end)
