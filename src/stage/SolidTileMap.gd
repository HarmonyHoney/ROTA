extends TileMap

onready var auto : TileMap = $Offset
func _ready():
	get_parent().connect("ready", self, "parent_ready")

func parent_ready():
	tile_set.tile_set_modulate(0, Color(0, 0, 0, 0))
	make_tiles(auto)

func make_tiles(map : TileMap):
	map.clear()
	
	var r = get_used_rect()
	
	for x in range(r.position.x - 1, r.position.x + r.size.x + 1):
		for y in range(r.position.y - 1, r.position.y + r.size.y + 1):
			var up_left = int(get_cell(x, y) != -1)
			var up_right = int(get_cell(x + 1, y) != -1)
			var down_right = int(get_cell(x + 1, y + 1) != -1)
			var down_left = int(get_cell(x, y + 1) != -1)
			
			# Calculate the tile value
			var tile_value = up_left + (up_right * 2) + (down_right * 4) + (down_left * 8)
		
			# Create tile
			
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
			
			map.set_cell(x, y, tile, fx, fy, tr)



