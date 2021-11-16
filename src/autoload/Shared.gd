extends Node

var is_reset := false
var is_level_select := false

var next_scene = ""

var scene_world_select := "res://src/menu/WorldSelect.tscn"

func _ready():
	Wipe.connect("wipe_out", self, "wipe_out")
	is_level_select = get_tree().current_scene.name == "WorldSelect"

func load_map():
	pass

func list_folder(path, include_extension := true):
	var dir = Directory.new()
	if dir.open(path) != OK:
		print("list_folder(): '", path, "' not found")
		return
	
	var list = []
	dir.list_dir_begin(true)
	
	var fname = dir.get_next()
	while fname != "":
		list.append(fname if include_extension else fname.split(".")[0])
		fname = dir.get_next()
	
	return list

func reset():
	if !is_reset:
		is_reset = true
		Wipe.start()

func change_scene(arg):
	next_scene = arg
	Wipe.start()

func wipe_out():
	Wipe.start(true)
	if is_reset:
		is_reset = false
		get_tree().reload_current_scene()
	else:
		is_level_select = next_scene == scene_world_select
		get_tree().change_scene(next_scene)

