tool
extends Area2D

var tile := 100.0
export var size := 10.0 setget set_size

func set_size(arg):
	size = arg
	var shape = $CollisionShape2D
	if shape:
		shape.shape.extents = Vector2.ONE * size * tile
	update()

func _draw():
	if Engine.editor_hint:
		var r = Rect2(Vector2.ONE * -size * tile, Vector2.ONE * size * tile * 2.0)
		draw_rect(r, Color(0, 1, 0, 0.3), false, 10.0)

func _on_Boundary_body_exited(body):
	if body.has_method("outside_boundary"):
		body.outside_boundary()
