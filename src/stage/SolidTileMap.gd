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
	
	var rect = map.get_used_rect()
	map.update_bitmask_region(rect.position, rect.end)
	
	var spikes = get_tree().get_nodes_in_group("spike")
	
	for i in spikes:
		var left = get_cellv(world_to_map(i.position + Vector2(-75, 75).rotated(deg2rad(i.dir * 90))))
		var right = get_cellv(world_to_map(i.position + Vector2(75, 75).rotated(deg2rad(i.dir * 90))))
		
		if left == -1:
			i.set_tile()
		if right == -1:
			i.set_tile(false)
