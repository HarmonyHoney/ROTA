extends Area2D

var shape := Vector2.ONE
var margin := 10.0

func _ready():
	var s = get_parent()
	var r = s.get_used_rect()
	var cell = s.cell_size
	
	var half = r.size / 2.0
	position = (r.position + half) * cell
	shape = (half + (Vector2.ONE * margin)) * cell
	$CollisionShape2D.shape.extents = shape

func _on_Boundary_body_exited(body):
	if Engine.editor_hint: return
	
	var p = to_local(body.global_position)
	
	if abs(p.x) > shape.x or abs(p.y) > shape.y:
		if body.has_method("outside_boundary"):
			body.outside_boundary()
