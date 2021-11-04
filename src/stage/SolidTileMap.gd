extends TileMap

onready var auto : TileMap = $AutoTileMap

func _ready():
	get_parent().connect("ready", self, "parent_ready")

func parent_ready():
	make_tiles(auto)
	remove_child(auto)
	get_parent().add_child(auto)
	get_parent().move_child(auto, 0)
	visible = false

func make_tiles(map : TileMap):
	for i in get_used_cells():
		for v in [Vector2.ZERO, Vector2.RIGHT, Vector2.DOWN, Vector2.ONE]:
			map.set_cellv((i * 2) + v, 0)
	
	var spikes = get_tree().get_nodes_in_group("spike")
	
	for i in spikes:
		for v in [Vector2.ZERO, Vector2.RIGHT, Vector2.DOWN, Vector2.ONE]:
			var s = world_to_map(i.position - Vector2(10, 10)) * 2
			map.set_cellv(s + v, 0)
	
	var rect = map.get_used_rect()
	map.update_bitmask_region(rect.position, rect.end)
	
	for i in spikes:
		for v in [Vector2.ZERO, Vector2.RIGHT, Vector2.DOWN, Vector2.ONE]:
			var s = world_to_map(i.position - Vector2(10, 10)) * 2
			map.set_cellv(s + v, -1)
