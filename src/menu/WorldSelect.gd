extends Node2D

var world_scenes = [preload("res://src/map/preview/1.tscn"),
	preload("res://src/map/preview/2.tscn"),
	preload("res://src/map/preview/3.tscn"),
	preload("res://src/map/preview/4.tscn"),
	preload("res://src/map/preview/5.tscn"),
	preload("res://src/map/preview/6.tscn")]

onready var worlds_node = $Worlds
onready var preview = $Worlds/Preview.duplicate()
var worlds = []
var size := 0

var cursor := 0

var p_back := Vector2(0, -230)
var p_one := Vector2(440, p_back.y * (1.0/3.0))
var p_two := Vector2(p_one.x / 2.0, p_back.y * (2.0/3.0))

var pos_targets = [Vector2.ZERO,
	p_one,
	p_two,
	p_back,
	p_two * Vector2(-1, 1),
	p_one * Vector2(-1, 1)]

var circles = []
onready var circles_node = $Picker/Circles
onready var circle = $Picker/Circles/Circle
onready var cursor_node = $Picker/Cursor

var is_level := false
onready var cam = $Camera2D

var levels := []
onready var level_select_node = $LevelSelect
onready var levels_node = $LevelSelect/Levels
onready var level = $LevelSelect/Levels/Level
var level_cursor := 0
onready var level_cursor_node = $LevelSelect/Cursor
var level_size := 0

var level_width := 5
var level_height := 1

var worlds_path := "res://src/map/worlds/"

var level_scenes := []

var orb_viewport

var is_opening := false

func _ready():
	for i in world_scenes.size() - 1:
		worlds_node.add_child(preview.duplicate())
		circles_node.add_child(circle.duplicate())
	
	worlds = worlds_node.get_children()
	size = worlds.size()
	
	circles = circles_node.get_children()
	
	for i in size:
		worlds[i].get_node("ViewportContainer/Viewport").add_child(world_scenes[i].instance())
		circles[i].position.x = (i - (size - 1) / 2.0) * 100
		print(circles[i].position.x)
	print(worlds)
	
	levels.append(level)
	
	for i in size:
		level_scenes.append([])
		var p = worlds_path + str(i + 1) + "/"
		var list = Shared.list_folder(p, false)
		list.sort_custom(self, "sort_levels")
		for j in list:
			level_scenes[i].append(load(p + str(j) + ".tscn"))

func sort_levels(a, b):
	if int(a) < int(b):
		return true
	return false

func _input(event):
	var left = event.is_action_pressed("left")
	var right = event.is_action_pressed("right")
	var up = event.is_action_pressed("up")
	var down = event.is_action_pressed("down")
	var enter = event.is_action_pressed("jump")
	var back = event.is_action_pressed("action")
	
	if up or down or left or right:
		if is_level:
			levels[level_cursor].scale = Vector2.ZERO
			var diff = (-1 if left else 1) if left or right else (-level_width if up else level_width)
			var last = level_cursor
			level_cursor = clamp(level_cursor + diff, 0, level_size - 1)
			if level_cursor != last:
				preview_level()
			print("level_cursor: ", level_cursor)
		elif left or right:
			circles[cursor].scale = Vector2.ZERO
			cursor = posmod(cursor + (-1 if left else 1), size)
			print("cursor: ", cursor)
	elif enter:
		if is_level:
			open_level()
		else:
			open_world()
	elif back:
		if is_level:
			close_world()

func open_world():
	is_level = true
	cam.position = Vector2(0, level_select_node.position.y - 45)
	level_cursor = 0
	
	level_size = level_scenes[cursor].size()
	#print(level_size, " levels in ", worlds_path + str(cursor + 1) + "/")
	
	for i in level_size - levels.size():
		levels_node.add_child(level.duplicate())
	levels = levels_node.get_children()
	#print("levels.size(): ", levels.size())
	#print("levels: ", levels)
	
	level_width = 3 if level_size < 10 else 4 if level_size < 13 else 5
	level_height = ceil(float(level_size) / float(level_width))
	var start = Vector2(level_width, level_height) - Vector2.ONE
	
	var spacing = 150
	
	levels_node.position = (-start * spacing) / 2.0
	$LevelSelect/debugCorner.position = levels_node.position
	
	for i in levels.size():
		var l = levels[i]
		
		if i > level_size - 1:
			l.visible = false
		else:
			l.visible = true
			l.get_node("Label").text = str(i + 1)
			
			var p = Vector2(i % level_width, floor(i / level_width))
			l.position = p * spacing
	
	orb_viewport = worlds[cursor].get_node("ViewportContainer/Viewport")
	preview_level()

func close_world():
	is_level = false
	cam.position = Vector2.ZERO
	
	for i in orb_viewport.get_children():
		orb_viewport.remove_child(i)
	orb_viewport.add_child(world_scenes[cursor].instance())

func preview_level():
	for i in orb_viewport.get_children():
		orb_viewport.remove_child(i)
	orb_viewport.add_child(level_scenes[cursor][level_cursor].instance())

func open_level():
	Shared.change_scene(worlds_path + str(cursor + 1) + "/" + str(level_cursor + 1) + ".tscn")
	set_process_input(false)
	is_opening = true

func _process(delta):
	if is_opening:
		var w = worlds[cursor]
		w.position = w.position.linear_interpolate(Vector2(0, level_select_node.position.y), 0.1)
		level_select_node.position = level_select_node.position.linear_interpolate(Vector2(-610, 640), 0.1)
		return
	
	for i in size:
		var w = worlds[i]
		
		if is_level and i == cursor:
			w.position = w.position.linear_interpolate(Vector2(380, level_select_node.position.y), 0.1)
		else:
			w.position = w.position.linear_interpolate(pos_targets[(i - cursor) % size], 0.1)
			w.scale = Vector2.ONE - (Vector2.ONE * (min(0, w.position.y) / -400))
			w.z_index = w.position.y
		
		var c = circles[i]
		c.scale = c.scale.linear_interpolate(Vector2.ONE, 0.1)
	
	if is_level:
		for i in level_size:
			var l = levels[i]
			l.scale = l.scale.linear_interpolate(Vector2.ONE, 0.1)
	
	cursor_node.position = cursor_node.position.linear_interpolate(circles[cursor].position, 0.1)
	level_cursor_node.position = level_cursor_node.position.linear_interpolate(levels_node.position + levels[level_cursor].position, 0.1)
	
	
	
