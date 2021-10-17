extends Node

var map_path : String = "res://src/map/"
var maps : Array = []

var current_map : int = 0 

func _ready():
	print("Shared._ready(): ")
	
	get_maps()
	
	# current map
	for i in maps.size():
		if map_path + maps[i] + ".tscn" ==get_tree().current_scene.filename:
			current_map = i
			print("current map: ", current_map)

func advance_map(arg):
	current_map = clamp(current_map + arg, 0, maps.size() - 1)

func load_map():
	get_tree().change_scene(map_path + maps[current_map] + ".tscn")

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
