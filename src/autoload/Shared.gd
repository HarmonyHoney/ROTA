extends Node

var worlds_path := "res://src/map/worlds/"
var title_path := "res://src/menu/MenuTitle.tscn"
var start_path := "res://src/map/worlds/1/0_start.tscn"

var is_wipe := false

onready var csfn := get_tree().current_scene.filename
onready var last_scene := csfn
onready var next_scene := csfn
var map_name := ""

var screenshot_texture : ImageTexture

var gem_count := 0
var goals := {}
var speedruns := {
	"1/2": 60,
	"1/3": 60,
	"1/4": 60,
	"1/5": 60,
	"1/6": 60,
	"1/7": 60,
	
	"2/1": 60,
	"2/2": 60,
	"2/3": 60,
	"2/4": 60,
	"2/5": 60,
	
	"2A/1": 60,
	"2A/2": 60,
	"2A/3": 60,
	"2A/4": 60,
	"2A/5": 60,
	"2A/6": 60,
	"2A/7": 60,
	
	"2B/1": 60,
	"2B/2": 60,
	"2B/3": 60,
	"2B/4": 60,
	"2B/5": 60,
	"2B/6": 60,
	
	"2C/1": 60,
	"2C/2": 60,
	"2C/3": 60,
	"2C/4": 60,
	"2C/5": 60,
	"2C/6": 60,
	
	"3/1": 60,
	"3/2": 60,
	"3/3": 60,
	"3/4": 60,
	"3/5": 60,
	"3/6": 60,
	"3/7": 60,
	
	"3A/1": 60,
	"3A/2": 60,
	"3A/3": 60,
	"3A/4": 60,
	"3A/5": 60,
	"3A/6": 60,
	
	"3B/1": 60,
	"3B/2": 60,
	"3B/3": 60,
	"3B/4": 60,
	"3B/5": 60,
	"3B/6": 60,
	"3B/7": 60,
	"3B/8": 60,
}

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
var map_clock := 0.0

signal signal_erase_slot(arg)

var auto_save_clock := 0.0
var auto_save_time := 60.0

var win_size := Vector2(1280, 720)
var win_sizes := [Vector2(640, 360), Vector2(960, 540), Vector2(1280, 720), Vector2(1600, 900),
Vector2(1920, 1080), Vector2(2560, 1440), Vector2(3840, 2160)]

var is_demo := false

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
	
	# setup window
	if OS.window_fullscreen:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		if OS.window_size in win_sizes:
			win_size = OS.window_size
		
		# center window
		set_window_size()
	
	# demo check
	var f = File.new()
	var fe = f.file_exists("res://src/map/worlds/2A/0_hub.tscn")
	f.close()
	is_demo = !fe

func _input(event):
	if event is InputEventKey and event.pressed and !event.is_echo():
		if event.scancode == KEY_F11:
			toggle_fullscreen()
	
#	if Input.is_action_just_pressed("ui_end"):
#		burst_screenshot()
	
	# gamepad signal
	if event.is_pressed():
		if is_gamepad and event is InputEventKey:
			is_gamepad = false
			emit_signal("signal_gamepad", is_gamepad)
			print("signal_gamepad: ", is_gamepad)
		elif !is_gamepad and (event is InputEventJoypadButton or event is InputEventJoypadMotion):
			is_gamepad = true
			emit_signal("signal_gamepad", is_gamepad)
			print("signal_gamepad: ", is_gamepad)

func _physics_process(delta):
	# recorded time
	save_time += delta
	map_clock += delta
	
	# auto save
	auto_save_clock += delta
	if auto_save_clock > auto_save_time:
		auto_save_clock = 0.0
		save_data()

func wipe_scene(arg, last := csfn):
	var f = File.new()
	var fe = f.file_exists(arg)
	f.close()
	
	if !is_wipe and fe:
		is_wipe = true
		
		if arg != csfn:
			last_scene = last
			next_scene = arg
		
		Wipe.start()
		return true
	
	return false

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
	
	map_name = csfn.lstrip(worlds_path).rstrip(".tscn") if csfn.begins_with(worlds_path) else ""
	
	BG.set_colors(0)
	emit_signal("scene_changed")
	save_data()
	try_achievement()
	map_clock = 0.0

func toggle_fullscreen():
	OS.window_fullscreen = !OS.window_fullscreen
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN if OS.window_fullscreen else Input.MOUSE_MODE_VISIBLE)
	if !OS.window_fullscreen:
		set_window_size()

func set_window_size(arg : Vector2 = win_size):
	win_size = arg
	# specific fix for borderless fullscreen
	var b = OS.window_borderless and win_size == OS.get_screen_size()
	OS.window_size = win_size + Vector2(0, 1 if b else 0)
	OS.window_position = Vector2.ZERO if b else (OS.get_screen_size() * 0.5) - (OS.window_size * 0.5)

func burst_screenshot(count := 30, viewport := get_tree().root):
	var dir := Directory.new()
	if !dir.dir_exists("user://snap"):
		dir.make_dir("user://snap")
	
	var images = []
	
	for i in count:
		var image = viewport.get_texture().get_data()
		image.flip_y()
		images.append(image)
		yield(get_tree(), "idle_frame")
	
	var d = OS.get_datetime()
	d.erase("dst")
	var s = ""
	
	for i in (d.values()):
		s += str(i) + " "
	
	for i in images.size():
		images[i].save_png("user://snap/" + s + "snap" + str(i) + ".png")
		yield(get_tree(), "idle_frame")

### Gems

func collect_gem():
	if is_instance_valid(goal) and goal.is_collected:
		Cutscene.is_clock = !goals.has(map_name) or (goals[map_name] == 0 or map_clock < goals[map_name])
		Cutscene.is_collect = !goals.has(map_name) or Cutscene.is_clock
		if Cutscene.is_collect:
			goals[map_name] = map_clock
		
		gem_count = goals.size()
		save_data()

### Volume

func set_volume(bus = 0, vol = 0):
	volume[bus] = clamp(vol, 0, 100)
	AudioServer.set_bus_volume_db(bus, linear2db(volume[bus] / 100.0))
	#print("volume[", bus, "] ",AudioServer.get_bus_name(bus) ," : ", volume[bus])

### Exit Game

func quit():
	save_data()
	save_options()
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

func file_load_json_dict(path : String):
	var d := {}
	
	var j = file_load(path)
	if j != "":
		var p = JSON.parse(j)
		if typeof(p.result) == TYPE_DICTIONARY:
			d = p.result
	
	return d

func save_data():
	if save_slot < 0: return
	auto_save_clock = 0.0
	
	save_dict[save_slot]["time"] = int(save_time)
	if "worlds" in csfn and "worlds" in last_scene:
		save_dict[save_slot]["csfn"] = csfn
		save_dict[save_slot]["last_scene"] = last_scene
	save_dict[save_slot]["goals"] = goals
	
	for i in save_dict[save_slot].keys():
		if not i in "time, csfn, last_scene, goals":
			save_dict[save_slot].erase(i)
	
	file_save_json("user://save_data.json", save_dict)

func load_data():
	var d = file_load_json_dict("user://save_data.json")
	# convert keys to int
	for i in d.keys():
		save_dict[int(i)] = d[i]

func erase_slot(arg := 0):
	save_dict[arg] = {}
	emit_signal("signal_erase_slot", arg)

func load_slot(arg := 0):
	save_slot = clamp(arg, 0, 2)
	print("Shared.save_slot: ", save_slot)
	
	if save_dict[save_slot].has("csfn"):
		next_scene = save_dict[save_slot]["csfn"]
		
		if save_dict[save_slot].has("last_scene"):
			last_scene = save_dict[save_slot]["last_scene"]
		
		goals = {}
		# open new saves
		if save_dict[save_slot].has("goals"):
			goals = save_dict[save_slot]["goals"]
		# convert old saves
		elif save_dict[save_slot].has("goals_collected"):
			for i in save_dict[save_slot]["goals_collected"]:
				goals[i.lstrip(worlds_path).rstrip(".tscn")] = 0.0
		
		# gems
		gem_count = goals.size()
		UI.gem_label.text = str(gem_count)
		
		if save_dict[save_slot].has("time"):
			save_time = save_dict[save_slot]["time"]
	else:
		Cutscene.is_start_game = true
		
		next_scene = start_path
		last_scene = start_path
		gem_count = 0
		UI.gem_label.text = str(gem_count)
		goals = {}
		save_time = 0.0
	
	return Shared.wipe_scene(Shared.next_scene, Shared.last_scene)

func save_options():
	var o := {}
	
	o["sounds"] = int(volume[1] / 10)
	o["music"] = int(volume[2] / 10)
	o["mouse"] = bool(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE)
	
	file_save_json("user://options.json", o)
	
	# override
	var s = "[display/window]\n\n"
	if win_size != Vector2(1280, 720):
		s += "size/test_width=" + str(win_size.x) + "\n"
		s += "size/test_height=" + str(win_size.y) + "\n"
	s += "size/borderless=" + str(OS.window_borderless).to_lower() + "\n"
	s += "size/fullscreen=" + str(OS.window_fullscreen).to_lower() + "\n"
	s += "vsync/use_vsync=" + str(OS.vsync_enabled).to_lower() + "\n"
	
	file_save("user://override.cfg", s)

func load_options():
	var d = file_load_json_dict("user://options.json")
	
	if d.has("sounds"):
		set_volume(1, int(d["sounds"]) * 10)
	if d.has("music"):
		set_volume(2, int(d["music"]) * 10)
	if d.has("mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if bool(d["mouse"]) else Input.MOUSE_MODE_HIDDEN

func save_keys(path := "user://keys.tres"):
	var s_keys = SaveDict.new()
	for a in InputMap.get_actions():
		s_keys.dict[a] = InputMap.get_action_list(a)
	
	ResourceSaver.save(path, s_keys)

func load_keys(path := "user://keys.tres"):
	if !ResourceLoader.exists(path): return
	var r = load(path)
	
	if r is SaveDict:
		for a in r.dict.keys():
			InputMap.action_erase_events(a)
			
			for e in r.dict[a]:
				InputMap.action_add_event(a, e)

### Steam ###

func try_achievement():
	if !Steam.is_init(): return
	
	var map := ""
	
	match csfn:
		"res://src/map/worlds/1/0_hub.tscn":
			map = "grass1"
		"res://src/map/worlds/2/0_hub.tscn":
			map = "stone1"
		"res://src/map/worlds/3/0_hub.tscn":
			map = "cacti1"
		"res://src/map/worlds/2A/0_hub.tscn":
			map = "snow1"
		
		"res://src/map/worlds/3A/0_hub.tscn":
			map = "grass2"
		"res://src/map/worlds/2B/0_hub.tscn":
			map = "stone2"
		"res://src/map/worlds/3B/0_hub.tscn":
			map = "cacti2"
		"res://src/map/worlds/2C/0_hub.tscn":
			map = "snow2"
	
	if map != "":
		Steam.set_achievement(map)
	
	if gem_count > 49:
		Steam.set_achievement("gem50")
	
	if csfn == "res://src/menu/Ending.tscn" and save_time < 3600:
		Steam.set_achievement("speedrun")

### Demo ###

func store_page():
	if Steam.is_init:
		Steam.friends.activate_game_overlay_to_store(1993830, Steam.OverlayToStoreFlag.None)
	else:
		OS.shell_open("https://store.steampowered.com/app/1993830/ROTA/")
