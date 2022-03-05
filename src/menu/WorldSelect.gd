extends Node2D

var preview_path = "res://src/map/preview/"
var worlds_path := "res://src/map/worlds/"

var worlds := []
var world_size := 0
var world_cursor := 0
onready var worlds_node = $Worlds
onready var preview = $Worlds/Preview.duplicate()

var p_back := Vector2(350, -150)

var pos_targets = [Vector2(-600, 0),
Vector2(-200, 0),
Vector2(200, 0),
Vector2(600, 0),
Vector2(1000, 0)]

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

onready var debug_corner = $LevelSelect/debugCorner

var is_opening := false
var orb_sprite : Sprite

func _ready():
	for i in Shared.world_size.size():
		# create worlds and cursor circles
		if i > 0:
			worlds_node.add_child(preview.duplicate())
			circles_node.add_child(circle.duplicate())
	
	# get children and size
	worlds = worlds_node.get_children()
	world_size = worlds.size()
	circles = circles_node.get_children()
	
	for i in world_size:
		preview_world(i)
		
		# set cursor circles position
		circles[i].position.x = (i - (world_size - 1) / 2.0) * 100
	
	# create level nodes
	for i in 29:
		levels_node.add_child(level.duplicate())
	levels = levels_node.get_children()
	
	# resume WorldSelect on world and level
	if Shared.world > -1:
		world_cursor = clamp(Shared.world, 0, world_size - 1)
		if Shared.level > -1:
			open_world()
			#level_cursor = Shared.level
			level_cursor = clamp(Shared.level, 0, level_size - 1)
			preview_level()
			worlds[world_cursor].position = Vector2(380, level_select_node.position.y)
	
	# delay input
	set_process_input(false)
	yield(get_tree().create_timer(0.5),"timeout")
	set_process_input(true)

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
		else:
			set_process_input(false)
			Shared.wipe_scene(Shared.scene_title)

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
	
	preview_level()

func close_world():
	is_level = false
	cam.position = Vector2.ZERO
	preview_world()

func preview_level(w := world_cursor, l := level_cursor):
	var p = worlds_path + str(w + 1) + "/" + str(l + 1) + ".tscn"
	if Shared.map_textures.has(p):
		worlds[w].get_node("Sprites/Map").texture = Shared.map_textures[p]
	
	worlds[w].get_node("Sprites/Lock").visible = level_cursor > Shared.unlocked[w]

func preview_world(w := world_cursor):
	var p = preview_path + str(w + 1) + ".tscn"
	if Shared.map_textures.has(p):
		worlds[w].get_node("Sprites/Map").texture = Shared.map_textures[p]
	
	worlds[w].get_node("Sprites/Lock").visible = Shared.unlocked[w] < 0

func open_level():
	if level_cursor > Shared.unlocked[world_cursor]:
		print("Level ", world_cursor + 1, "-", level_cursor + 1, " locked")
		#return
	
	set_process_input(false)
	is_opening = true
	Shared.world = world_cursor
	Shared.level = level_cursor
	var p = (worlds[world_cursor].global_position - cam.global_position) * (1 / cam.zoom.x)
	Shared.last_orb_pos = p
	
	HUD.show("none")
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	Shared.start_scale = worlds[world_cursor].get_node("Sprites").scale.y / cam.zoom.y
	
	var map = worlds[world_cursor].get_node("Sprites/Map")
	var from = map.material.get_shader_param("radius")
	var factor = (map.global_scale.x * map.get_rect().size.x) / (cam.zoom.x * 1280)
	CircleZoom.zoom(from * factor, CircleZoom.out, 1.0, Vector2.ZERO)
	Shared.last_orb_radius = from * factor
	
	yield(get_tree(), "idle_frame")
	
	get_tree().change_scene(worlds_path + "/" + str(world_cursor + 1) + "/" + str(level_cursor + 1) + ".tscn")
	#Shared.is_level_select = false
	
	HUD.show("game")

func _process(delta):
	if is_opening:
		var w = worlds[world_cursor]
		#w.position = w.position.linear_interpolate(Vector2(0, level_select_node.position.y), 0.1)
		w.global_position = w.global_position.linear_interpolate(cam.global_position, 0.1)
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
	
	
	
