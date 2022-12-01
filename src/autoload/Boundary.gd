extends Node

var rect := Rect2()
var count := 0

func _ready():
	Shared.connect("scene_before", self, "scene_before")

func scene_before():
	count = 0
	rect = Rect2(0,0,0,0)

func add_shape(add : Rect2, cell : Vector2):
	rect = rect.merge(Rect2(add.position * cell, add.size * cell))
	
	count += 1

func is_outside(pos, margin := 10.0):
	return count > 0 and !rect.grow(margin * 100).has_point(pos)
