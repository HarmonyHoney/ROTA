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

func _input(event):
	if event.is_action_pressed("left") or event.is_action_pressed("right"):
		if is_level:
			pass
		else:
			var left = event.is_action_pressed("left")
			circles[cursor].scale = Vector2.ZERO
			cursor = posmod(cursor + (-1 if left else 1), size)
			print("cursor: ", cursor)
	elif event.is_action_pressed("jump"):
		is_level = true
		cam.position = Vector2(0, 590)
	elif event.is_action_pressed("action"):
		is_level = false
		cam.position = Vector2.ZERO

func _process(delta):
	for i in size:
		var w = worlds[i]
		
		if is_level and i == cursor:
			w.position = w.position.linear_interpolate(Vector2(380, cam.position.y), 0.1)
		else:
			w.position = w.position.linear_interpolate(pos_targets[(i - cursor) % size], 0.1)
			w.scale = Vector2.ONE - (Vector2.ONE * (min(0, w.position.y) / -400))
			w.z_index = w.position.y
		
		var c = circles[i]
		c.scale = c.scale.linear_interpolate(Vector2.ONE, 0.1)
		
	cursor_node.position = cursor_node.position.linear_interpolate(circles[cursor].position, 0.1)
