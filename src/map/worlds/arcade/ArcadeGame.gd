extends Node2D

onready var cam := $Camera2D
onready var map_node := $Map

export var tile_size := 12.0

export(String, DIR) var folder := ""
onready var maps : Array = Shared.list_all_files(folder)
var map := 0
var map_ease := EaseMover.new(1.0)

var candies := []


func _ready():
	map_ease.clock = map_ease.time
	for i in Shared.get_all_children(map_node):
		if i.is_in_group("solid_map"):
			wrap_tiles(i)

func _physics_process(delta):
	if map_ease.is_less:
		var s = map_ease.count(delta, true, false)
		
		cam.zoom = Vector2.ONE * lerp(1.1, 3.0, ease(s, 1.8))
		
		if map_ease.is_complete:
			scene()

func wrap_tiles(_map):
	var tiles = _map.get_used_cells()
	
	for t in tiles:
		for x in [-1, 0, 1]:
			for y in [-1, 0, 1]:
				if !(x == 0 and y == 0) :
					var vec = t + (Vector2(x, y) * tile_size)
					_map.set_cell(vec.x, vec.y, 0)

func win():
	if candies.size() > 0: return
	
	map_ease.clock = 0.0
	map += 1

func scene():
	cam.zoom = Vector2.ONE * 1.1
	for i in map_node.get_children():
		i.queue_free()
	
	var m = load(maps[map % maps.size()]).instance()
	map_node.add_child(m)
	
	for i in m.get_children():
		if i.is_in_group("solid_map"):
			wrap_tiles(i)
		if i.is_in_group("back"):
			i.visible = false
	
	