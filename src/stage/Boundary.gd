extends Area2D

var margin = 6

func _ready():
	var s = get_parent()
	var r = s.get_used_rect()
	
	var center = (r.position + (r.size / 2)) * s.cell_size
	position = center
	
	$CollisionShape2D.shape.extents = ((r.size / 2) + (Vector2.ONE * margin)) * s.cell_size
	$CollisionShape2D.visible = true

func _on_Boundary_body_exited(body):
	if !Shared.is_level_select and body.has_method("outside_boundary"):
		body.outside_boundary()
