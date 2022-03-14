extends Node

var scene_splash := "res://src/menu/Splash.tscn"
var scene_title := "res://src/menu/Title.tscn"
var scene_select := "res://src/menu/WorldSelect.tscn"
var scene_options := "res://src/menu/Options.tscn"

var is_wipe := false

var last_scene := ""
var next_scene := ""
onready var csfn := get_tree().current_scene.filename

var worlds_path := "res://src/map/worlds/"

var map_textures := {}
var start_scale := 1.0
var last_orb_radius := 0.0
var last_orb_pos := Vector2.ZERO

var screenshot_texture : ImageTexture

var goals_collected := []
var is_collect := false
var is_show_goal := false

var player
var camera
var door_goal
var door_destination
var goal
var slab

var slabs_completed = []

signal scene_changed

func _ready():
	Wipe.connect("wipe_out", self, "wipe_out")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_F11:
			toggle_fullscreen()

func wipe_scene(arg):
	if !is_wipe:
		is_wipe = true
		last_scene = csfn
		next_scene = arg
		Wipe.start()

func wipe_out():
	if is_wipe:
		Wipe.start(true)
		change_scene()

func reset():
	wipe_scene(csfn)

func change_scene():
	is_wipe = false
	if next_scene == csfn:
		get_tree().reload_current_scene()
	else:
		csfn = next_scene
		get_tree().change_scene(next_scene)
	
	match next_scene:
		scene_splash: HUD.show("none")
		scene_title: HUD.show("title")
		scene_select: HUD.show("title")
		scene_options: HUD.show("title")
		_: HUD.show("game")
	
	emit_signal("scene_changed")

func toggle_fullscreen():
	OS.window_fullscreen = !OS.window_fullscreen
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN if OS.window_fullscreen else Input.MOUSE_MODE_VISIBLE)

func take_screenshot():
	var image = get_tree().root.get_texture().get_data()
	image.flip_y()
	
	var it = ImageTexture.new()
	it.create_from_image(image)
	
	screenshot_texture = it
	return screenshot_texture




### Files and Directory Funcs ###

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
	
	dir.list_dir_end()
	return list

func list_all_files(path, is_ext := true):
	var folders = [path]
	var files = []
	
	while !folders.empty():
		var s = folders.pop_back()
		
		var ex = list_folders_and_files(s, is_ext)
		folders.append_array(ex[0])
		files.append_array(ex[1])
	
	return files

func list_folders_and_files(path, is_ext := true):
	var dir = Directory.new()
	if dir.open(path) != OK:
		print("list_folder(): '", path, "' not found")
		return
	
	dir.list_dir_begin(true)
	var fname = dir.get_next()
	var files := []
	var folders := []
	
	while fname != "":
		var s = dir.get_current_dir() + "/" + (fname if is_ext else fname.split(".")[0])
		folders.append(s) if dir.current_is_dir() else files.append(s)
		fname = dir.get_next()
	
	dir.list_dir_end()
	return [folders, files]

