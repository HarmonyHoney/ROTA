extends Node

var worlds_path := "res://src/map/worlds/"
var title_path := "res://src/menu/MenuTitle.tscn"
var start_path := "res://src/map/worlds/1/0_start.tscn"

var is_wipe := false

onready var csfn := get_tree().current_scene.filename
onready var last_scene := csfn
onready var next_scene := csfn

var screenshot_texture : ImageTexture

var goals_collected := []
var gem_count := 0

var boxes := []

var player
var door_destination
var goal

signal scene_changed
var is_reload := false

var volume = [100, 100, 100]

var is_gamepad := false
signal signal_gamepad(arg)

var default_keys := {}

var save_slot := -1
var save_dict := {0: {}, 1: {}, 2: {}}
var save_time := 0.0

signal signal_erase_slot(arg)

var auto_save_clock := 0.0
var auto_save_time := 60.0

func _ready():
	Wipe.connect("wipe_out", self, "wipe_out")
	#set_volume(0, 50)
	set_volume(1, 50)
	set_volume(2, 50)
	
	# get default key binds
	for i in InputMap.get_actions():
		default_keys[i] = InputMap.get_action_list(i)
	
	load_options()
	load_data()
	load_keys()

func _input(event):
	if event is InputEventKey and event.pressed and !event.is_echo():
		if event.scancode == KEY_F11:
			toggle_fullscreen()
	
	# gamepad signal
	if event.is_pressed():
		if is_gamepad and event is InputEventKey:
			is_gamepad = false
			emit_signal("signal_gamepad", is_gamepad)
			print("signal_gamepad")
		elif !is_gamepad and (event is InputEventJoypadButton or event is InputEventJoypadMotion):
			is_gamepad = true
			emit_signal("signal_gamepad", is_gamepad)
			print("signal_gamepad")

func _physics_process(delta):
	# recorded time
	save_time += delta
	
	# auto save
	auto_save_clock += delta
	if auto_save_clock > auto_save_time:
		auto_save_clock = 0.0
		save_data()

func wipe_scene(arg, last := csfn):
	if !is_wipe:
		is_wipe = true
		
		if arg != csfn:
			last_scene = last
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
	boxes.clear()
	
	Cutscene.end_all()
	
	is_reload = next_scene == csfn
	if is_reload:
		get_tree().reload_current_scene()
	else:
		csfn = next_scene
		get_tree().change_scene(next_scene)
		Cam.reset_zoom()
	
	BG.set_colors(0)
	
	emit_signal("scene_changed")
	
	save_data()

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

### Gems

func collect_gem():
	if is_instance_valid(goal) and goal.is_collected and !goals_collected.has(csfn):
		goals_collected.append(csfn)
		gem_count = goals_collected.size()
		Cutscene.is_collect = true
		
		save_data()


### Volume

func set_volume(bus = 0, vol = 0):
	volume[bus] = clamp(vol, 0, 100)
	AudioServer.set_bus_volume_db(bus, linear2db(volume[bus] / 100.0))
	#print("volume[", bus, "] ",AudioServer.get_bus_name(bus) ," : ", volume[bus])


### Exit Game

func quit():
	save_data()
	get_tree().quit()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		quit()

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

func file_save(path : String, content : String):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(content)
	file.close()

func file_save_json(path : String, dict : Dictionary):
	var j = JSON.print(dict, "\t")
	file_save(path, j)

func file_load(path : String) -> String:
	var content = ""
	
	var file = File.new()
	if file.file_exists(path):
		file.open(path, File.READ)
		content = file.get_as_text()
	file.close()
	
	return content

func save_data():
	if save_slot < 0: return
	
	save_dict[save_slot]["goals_collected"] = goals_collected
	save_dict[save_slot]["gem_count"] = gem_count
	save_dict[save_slot]["time"] = int(save_time)
	
	if "worlds" in csfn and "worlds" in last_scene:
		save_dict[save_slot]["csfn"] = csfn
		save_dict[save_slot]["last_scene"] = last_scene
	
	file_save_json("user://save_data.json", save_dict)
	
	auto_save_clock = 0.0

func load_data():
	var j = file_load("user://save_data.json")
	if j != "":
		var p = JSON.parse(j)
		if typeof(p.result) == TYPE_DICTIONARY:
			var data = p.result
			# convert keys to int
			for i in data.keys():
				save_dict[int(i)] = data[i]

func load_slot(arg := 0):
	save_slot = clamp(arg, 0, 2)
	print("Shared.save_slot: ", save_slot)
	
	if save_dict[save_slot].has("csfn"):
		next_scene = save_dict[save_slot]["csfn"]
		
		if save_dict[save_slot].has("last_scene"):
			last_scene = save_dict[save_slot]["last_scene"]
		
		if save_dict[save_slot].has("gem_count"):
			gem_count = save_dict[save_slot]["gem_count"]
			UI.gem_label.text = str(gem_count)
		
		if save_dict[save_slot].has("goals_collected"):
			goals_collected = save_dict[save_slot]["goals_collected"]
		
		if save_dict[save_slot].has("time"):
			save_time = save_dict[save_slot]["time"]
	else:
		Cutscene.is_start_game = true
		
		next_scene = start_path
		last_scene = start_path
		gem_count = 0
		UI.gem_label.text = str(gem_count)
		goals_collected = []
		save_time = 0.0
	
	Shared.wipe_scene(Shared.next_scene, Shared.last_scene)

func erase_slot(arg := 0):
	save_dict[arg] = {}
	emit_signal("signal_erase_slot", arg)

func save_options():
	var o := {}
	
	o["sounds"] = int(volume[1] / 10)
	o["music"] = int(volume[2] / 10)
	o["fullscreen"] = int(OS.window_fullscreen)
	o["vsync"] = int(OS.vsync_enabled)
	o["size_x"] = OS.window_size.x
	o["size_y"] = OS.window_size.y
	
	file_save_json("user://options.json", o)

func load_options():
	var j = file_load("user://options.json")
	if j != "":
		var p = JSON.parse(j)
		if typeof(p.result) == TYPE_DICTIONARY:
			var data : Dictionary = p.result
			
			if data.has("sounds"):
				set_volume(1, int(data["sounds"]) * 10)
			if data.has("music"):
				set_volume(2, int(data["music"]) * 10)
			if data.has("fullscreen"):
				OS.window_fullscreen = bool(int(data["fullscreen"]))
			if data.has("vsync"):
				OS.vsync_enabled = bool(int(data["vsync"]))
			if data.has("size_x") and data.has("size_y"):
				OS.window_size = Vector2(float(data["size_x"]), float(data["size_y"]))

func save_keys():
	var s_keys = SaveDict.new()
	for a in InputMap.get_actions():
		s_keys.dict[a] = InputMap.get_action_list(a)
	
	ResourceSaver.save("user://keys.tres", s_keys)

func load_keys(path := "user://keys.tres"):
	if !ResourceLoader.exists(path): return
	var r = load(path)
	
	if is_instance_valid(r) and r.has_meta("dict") and typeof(r.dict) == TYPE_DICTIONARY:
		for a in r.dict.keys():
			InputMap.action_erase_events(a)
			
			for e in r.dict[a]:
				InputMap.action_add_event(a, e)

