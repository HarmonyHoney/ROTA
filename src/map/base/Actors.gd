extends Node2D

var boxes := []

func _ready():
	for i in get_children():
		if i is Box:
			boxes.append(i)
