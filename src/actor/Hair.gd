tool
extends Node2D

export var width := 50.0
export var end_scale := 0.75
export var length = 25
export var point_count := 3 setget _set_points

export var gravity = 200.0
export var sitting_angle = 15.0
export var lerp_weight := 0.3
export var reload := false setget set_reload

var hair_end = Vector2(-150, 150)
var last_pos := Vector2.ZERO

var p = []

export var color := Color("00fff9") # 00fff9 ff007e

func _physics_process(delta):
	
	# move end
	hair_end -= hair_end - to_local(last_pos)
	
	# gravity
	hair_end += Vector2.DOWN * gravity * delta
	
	# keep hair behind back
	var a = rad2deg(hair_end.angle()) - 90
	if abs(a) < sitting_angle:
		var diff = (sitting_angle - abs(a)) * global_scale.x
		var l = lerp(0,  deg2rad(diff), lerp_weight)
		hair_end = hair_end.rotated(l)
	
	# keep length
	if hair_end.length() > length:
		hair_end = hair_end.normalized() * length
	
	# set points
	for i in p.size():
		p[i] = hair_end.normalized() * hair_end.length() * (float(i) / (p.size() - 1))
	
	
	last_pos = to_global(hair_end)
	update()

func set_reload(arg):
	reload = arg
	_set_points()

func _set_points(arg := point_count):
	point_count = max(2, arg)
	
	p = []
	for i in point_count:
		p.append(Vector2.ZERO)
	
	update()

func _draw():
	for i in p.size():
		var w = (width * 0.5) * lerp(1.0, end_scale, i / float(p.size() - 1))
		draw_circle(p[i], w, color) 
	
	if Engine.editor_hint:
		for i in p.size():
			draw_circle(p[i], 1, Color.white)
