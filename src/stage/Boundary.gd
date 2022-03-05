extends Area2D

onready var c0 := $C0
onready var c1 := $C1
onready var c2 := $C2
onready var c3 := $C3
onready var shapes = [c0, c1, c2, c3]
onready var shapes_size : int = shapes.size()
var active_shapes := 0

var margin = 10.0

func _ready():
	print(name, "._ready(): ")
	for i in shapes:
		print(i.name, " / extents: ", i.shape.extents)
	
	Shared.connect("scene_changed", self, "scene_changed")

func scene_changed():
	active_shapes = 0

func add_shape(rect, cell):
	var half = rect.size / 2.0
	shapes[active_shapes].global_position = (rect.position + half) * cell
	shapes[active_shapes].shape.extents = (half + (Vector2.ONE * margin)) * cell
	
	print(name, ".add_shape(): ")
	for i in shapes:
		print(i.name, " / extents: ", i.shape.extents)
	
	active_shapes = clamp(active_shapes + 1, 0, shapes_size)
	print("active_shapes: ", active_shapes)

func _on_Boundary_body_exited(body):
	var check = 0
	for i in shapes_size:
		if i > active_shapes:
			check +=1 
		else:
			var p = shapes[i].to_local(body.global_position)
			var s = shapes[i].shape.extents
			if abs(p.x) > s.x or abs(p.y) > s.y:
				check += 1
				print(shapes[i].name, ": out")
	
	if check == shapes_size:
		if body.has_method("outside_boundary"):
			body.outside_boundary()
		print(name, ": all out")
		
	
