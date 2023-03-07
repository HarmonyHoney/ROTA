extends Node2D

onready var hide := $Hide
onready var cloud := $Hide/Cloud
onready var color_rect := $Hide/ColorRect

onready var center := $Center
onready var clouds := $Center/Clouds
onready var stars := $Center/Stars
onready var sun := $Center/Stars/Sun
onready var moon := $Center/Stars/Moon

export var cloud_speed := 1.0
export var star_speed := 0.5
var cloud_dir := 1.0
var star_dir := 1.0

var length = 100.0
var dir := 1.0
var speed_mod := 1.0

func _enter_tree():
	Shared.connect("scene_changed", self, "scene")

func _ready():
	hide.visible = false

func scene():
	var start = Vector2.ONE * 900
	var end = Vector2.ONE * -900

	for i in get_tree().get_nodes_in_group("solid_map"):
		for c in i.get_used_cells():
			start.x = min(start.x, c.x)
			start.y = min(start.y, c.y)
			end.x = max(end.x, c.x)
			end.y = max(end.y, c.y)
	
	global_position = (start.linear_interpolate(end, 0.5) + (Vector2.ONE * 0.5)) * 100.0
	color_rect.rect_size = ((end - start) + Vector2.ONE) * 100.0
	color_rect.rect_position = -color_rect.rect_size / 2.0
	length = max(color_rect.rect_size.x, color_rect.rect_size.y) / 2.0
	
	sun.position = Vector2(length + 650, 0)
	moon.position = sun.position
	sun.visible = BG.colors == 0 or BG.colors == 3
	moon.visible = !sun.visible
	moon.scale.x = -1 if randf() < 0.5 else 1.0
	stars.rotation = rand_range(0.0, TAU)
	
	print("start: ", start, " end: ", end, " length: ", length, " global_position: ", global_position)
	
	cloud_dir = (-1.0 if randf() > 0.5 else 1.0) * rand_range(0.6, 1.0)
	star_dir = (-1.0 if randf() > 0.5 else 1.0) * rand_range(0.6, 1.0)
	#speed_mod = rand_range(0.6, 1.0) * dir
	create_clouds()

func _physics_process(delta):
	clouds.rotate(deg2rad(cloud_speed * delta * cloud_dir))
	stars.rotate(deg2rad(star_speed * delta * -star_dir))

func create_clouds():
	var i = 0
	var gc = clouds.get_children()
	var gcs = gc.size()
	
	for x in (length / 50.0) + 5:
		for y in max(3, x):
			var c = null
			if i < gcs:
				c = gc[i]
			else:
				c = cloud.duplicate()
				clouds.add_child(c)
			c.owner = clouds
			c.position = Vector2(((x + 2) * 200) + rand_range(0.0, 100.0), 0).rotated(rand_range(0.0, TAU))
			c.scale = Vector2.ONE * rand_range(0.25, 2.0)
			c.rotation = randf() * TAU
			c.visible = true
			if c.position.length() > length + 500:
				#c.color.a = lerp(c.color.a, 1.0, clamp((c.position.length() - (length + 700)) / 500.0, 0, 1))
				c.color.a = 0.8
			i += 1
	
	if i < gcs:
		for a in range(i, gcs):
			gc[a].visible = false
	
