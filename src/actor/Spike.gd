tool
extends Node2D

export var dir := 0 setget set_dir

func set_dir(arg):
	dir = posmod(arg, 4)
	rotation_degrees = dir * 90
