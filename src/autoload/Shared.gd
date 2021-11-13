extends Node

var map_path : String = "res://src/map/"
var maps : Array = []

var current_map : int = 0 

var is_reset := false

var is_level_select := false

func _ready():
	print("Shared._ready(): ")
	
	get_maps()
	
	# current map
	for i in maps.size():
		if map_path + maps[i] + ".tscn" ==get_tree().current_scene.filename:
			current_map = i
			print("current map: ", current_map)
	
	Wipe.connect("wipe_out", self, "wipe_out")
	
	is_level_select = get_tree().current_scene.name == "LevelSelect"

func advance_map(arg):
	current_map = clamp(current_map + arg, 0, maps.size() - 1)

func load_map():
	get_tree().change_scene(map_path + maps[current_map] + ".tscn")
	is_level_select = get_tree().current_scene.name == "LevelSelect"

func list_folder(path):
	var dir = Directory.new()
	if dir.open(path) != OK:
		print("list_folder(): '", map_path, "' not found")
		return
	
	var list = []
	dir.list_dir_begin(true)
	
	var fname = dir.get_next()
	while fname != "":
		list.append(fname)
		fname = dir.get_next()
	
	return list

func get_maps():
	maps = []
	for i in list_folder(map_path):
		if i.ends_with(".tscn"):
			maps.append(i.trim_suffix(".tscn"))
	print("get_maps(): ", maps)

func reset():
	if !is_reset:
		is_reset = true
		Wipe.start()

func wipe_out():
	if is_reset:
		is_reset = false
		get_tree().reload_current_scene()
		Wipe.start(true)

