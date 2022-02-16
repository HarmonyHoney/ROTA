extends Area2D

var margin = 15

func _ready():
	var s = get_parent()
	var r = s.get_used_rect()
	var cell = s.cell_size
	
	var center = (r.position + (r.size / 2)) * cell
	position = center
	
	var c = get_children()
	for i in c.size():
		c[i].position = (Vector2(0, margin) * cell).rotated(i * deg2rad(90))
		c[i].shape.extents = Vector2(margin, 1) * cell
		c[i].rotation_degrees = i * 90
	
	visible = true

func _on_Boundary_body_entered(body):
	if Engine.editor_hint: return
	if body.has_method("outside_boundary"):
		body.outside_boundary()
