extends Node2D

var boxes := []


#var scene_goal = preload("res://src/actor/Goal.tscn")
#var scene_door = preload("res://src/actor/Door.tscn")


func _ready():
	
#	var exit
#	var player
#
#	var is_goal := false
#	var is_door := false
	
	for i in get_children():
		if i is Box:
			boxes.append(i)
		
#		if i.is_in_group("player"):
#			player = i
#		if i.is_in_group("exit"):
#			exit = i
#
#		if i.is_in_group("goal"):
#			is_goal = true
#		if i.is_in_group("door"):
#			is_door = true
	
#	if !is_door:
#		var d = scene_door.instance()
#		add_child(d)
#		d.owner = self
#		d.position = player.start_pos
#		d.dir = player.dir
#
#	if !is_goal:
#		var g = scene_goal.instance()
#		add_child(g)
#		g.owner = self
#		g.position = exit.position
#		exit.visible = false
