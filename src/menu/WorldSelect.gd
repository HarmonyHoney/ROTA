extends Node2D

var preview_path = "res://src/map/preview/"
var preview_scenes := []
var level_scenes := []
var worlds_path := "res://src/map/worlds/"

var worlds := []
var world_size := 0
var world_cursor := 0
onready var worlds_node = $Worlds
onready var preview = $Worlds/Preview.duplicate()

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
var level_size := 0
var level_cursor := 0
var level_width := 5
var level_height := 1
onready var level_select_node = $LevelSelect
onready var levels_node = $LevelSelect/Levels
onready var level = $LevelSelect/Levels/Level
onready var level_cursor_node = $LevelSelect/Cursor

var orb_viewport
var is_opening := false

onready var debug_corner = $LevelSelect/debugCorner

func _ready():
	for i in Shared.world_size.size():
		# create worlds and cursor circles
		if i > 0:
			worlds_node.add_child(preview.duplicate())
			circles_node.add_child(circle.duplicate())
		
		# fill arrays with scenes to be instanced
		preview_scenes.append(load(preview_path + str(i + 1) + ".tscn"))
		level_scenes.append([])
		for j in Shared.world_size[i] + 1:
			level_scenes[i].append(load(worlds_path + str(i + 1) + "/" + str(j + 1) + ".tscn"))
	
	# get children and size
	worlds = worlds_node.get_children()
	world_size = worlds.size()
	circles = circles_node.get_children()
	
	for i in world_size:
		# instance previews
		worlds[i].get_node("ViewportContainer/Viewport").add_child(preview_scenes[i].instance())
		worlds[i].get_node("ViewportContainer/Viewport/Node2D/Camera2D").zoom = Vector2.ONE
		worlds[i].get_node("Locked").visible = Shared.unlocked[i] < 0
		# set cursor circles position
		circles[i].position.x = (i - (world_size - 1) / 2.0) * 100
	
	# create level nodes
	for i in 19:
		levels_node.add_child(level.duplicate())
	levels = levels_node.get_children()
	
	# resume WorldSelect on world and level
	if Shared.world > -1:
		world_cursor = Shared.world
		if Shared.level > -1:
			open_world()
			level_cursor = Shared.level
			preview_level()

func _input(event):
	var left = event.is_action_pressed("left")
	var right = event.is_action_pressed("right")
	var up = event.is_action_pressed("up")
	var down = event.is_action_pressed("down")
	var enter = event.is_action_pressed("jump")
	var back = event.is_action_pressed("action")
	
	if up or down or left or right:
		if is_level:
			var diff = (-1 if left else 1) if left or right else (-level_width if up else level_width)
			var last = level_cursor
			level_cursor = clamp(level_cursor + diff, 0, level_size - 1)
			if level_cursor != last:
				preview_level()
				levels[last].scale = Vector2.ZERO
		elif left or right:
			circles[world_cursor].scale = Vector2.ZERO
			world_cursor = posmod(world_cursor + (-1 if left else 1), world_size)
	elif enter:
		if is_level:
			open_level()
		else:
			open_world()
	elif back:
		if is_level:
			close_world()

func open_world():
	if Shared.unlocked[world_cursor] < 0:
		print("World ", world_cursor + 1, " locked")
		#return
	
	is_level = true
	cam.position = Vector2(0, level_select_node.position.y - 45)
	level_cursor = 0
	
	level_size = Shared.world_size[world_cursor] + 1
	
	level_width = 3 if level_size < 10 else 4 if level_size < 13 else 5
	level_height = ceil(float(level_size) / float(level_width))
	var start = Vector2(level_width, level_height) - Vector2.ONE
	
	var spacing = 150
	
	levels_node.position = (-start * spacing) / 2.0
	debug_corner.position = levels_node.position
	
	for i in levels.size():
		var l = levels[i]
		
		if i > level_size - 1:
			l.visible = false
		else:
			l.visible = true
			l.position = Vector2(i % level_width, floor(i / level_width)) * spacing
			
			l.get_node("Label").text = "" if i > Shared.unlocked[world_cursor] else str(i + 1)
			l.get_node("Locked").visible = i > Shared.unlocked[world_cursor]
	
	orb_viewport = worlds[world_cursor].get_node("ViewportContainer/Viewport")
	preview_level()

func close_world():
	is_level = false
	cam.position = Vector2.ZERO
	
	for i in orb_viewport.get_children():
		orb_viewport.remove_child(i)
	orb_viewport.add_child(preview_scenes[world_cursor].instance())
	orb_viewport.get_node("Node2D/Camera2D").zoom = Vector2.ONE
	worlds[world_cursor].get_node("Locked").visible = Shared.unlocked[world_cursor] < 0

func preview_level():
	for i in orb_viewport.get_children():
		orb_viewport.remove_child(i)
	orb_viewport.add_child(level_scenes[world_cursor][level_cursor].instance())
	orb_viewport.get_node("Node2D/Camera2D").zoom = Vector2.ONE
	worlds[world_cursor].get_node("Locked").visible = level_cursor > Shared.unlocked[world_cursor]

func open_level():
	if level_cursor > Shared.unlocked[world_cursor]:
		print("Level ", world_cursor + 1, "-", level_cursor + 1, " locked")
		#return
	
	Shared.change_scene(worlds_path + str(world_cursor + 1) + "/" + str(level_cursor + 1) + ".tscn")
	set_process_input(false)
	is_opening = true
	Shared.world = world_cursor
	Shared.level = level_cursor

func _process(delta):
	if is_opening:
		var w = worlds[world_cursor]
		w.position = w.position.linear_interpolate(Vector2(0, level_select_node.position.y), 0.1)
		level_select_node.position = level_select_node.position.linear_interpolate(Vector2(-610, 640), 0.1)
		return
	
	for i in world_size:
		var w = worlds[i]
		
		if is_level and i == world_cursor:
			w.position = w.position.linear_interpolate(Vector2(380, level_select_node.position.y), 0.1)
		else:
			w.position = w.position.linear_interpolate(pos_targets[(i - world_cursor) % world_size], 0.1)
			w.scale = Vector2.ONE - (Vector2.ONE * (min(0, w.position.y) / -400))
			w.z_index = w.position.y
		
		var c = circles[i]
		c.scale = c.scale.linear_interpolate(Vector2.ONE, 0.1)
	
	if is_level:
		for i in level_size:
			var l = levels[i]
			l.scale = l.scale.linear_interpolate(Vector2.ONE, 0.1)
	
	cursor_node.position = cursor_node.position.linear_interpolate(circles[world_cursor].position, 0.1)
	level_cursor_node.position = level_cursor_node.position.linear_interpolate(levels_node.position + levels[level_cursor].position, 0.1)
	
	
	
