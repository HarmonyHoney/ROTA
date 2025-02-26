@tool
extends Node2D

@export var dir := 0: set = set_dir

func set_dir(arg):
	dir = posmod(arg, 4)
	rotation_degrees = dir * 90
