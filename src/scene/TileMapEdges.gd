extends TileMap

onready var map = get_parent().get_node("SolidTileMap")

func _ready():
	map.visible = false
	make_tiles()

func make_tiles():
	for i in map.get_used_cells():
		for v in [Vector2.ZERO, Vector2.RIGHT, Vector2.DOWN, Vector2.ONE]:
			set_cellv((i * 2) + v, 3)
	
	var rect = get_used_rect()
	update_bitmask_region(rect.position, rect.end)
