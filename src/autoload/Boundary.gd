extends Node

var rect := Rect2()
var count := 0

func _ready():
	Shared.connect("scene_changed", self, "scene_changed")

func scene_changed():
	count = 0

func add_shape(add : Rect2, cell : Vector2):
	var r = Rect2(add.position * cell, add.size * cell)
	
	if count == 0:
		rect = r
	else:
		rect = rect.merge(r)
	
	count += 1

func is_outside(pos, margin := 10.0):
	return count > 0 and !rect.grow(margin * 100).has_point(pos)
