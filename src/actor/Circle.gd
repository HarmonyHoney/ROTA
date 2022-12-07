tool
extends CanvasItem

export var radius := 50.0 setget set_radius
export var offset := Vector2.ZERO setget set_offset

func _draw():
	draw_circle(offset, radius, Color.white)

func set_radius(arg := radius):
	radius = abs(arg)
	update()

func set_offset(arg := offset):
	offset = arg
	update()
