extends Node

var is_playing := false

var is_show_goal := false
var is_collect := false

onready var gem_collect := $GemCollect
onready var goal_show := $GoalShow


func start():
	is_playing = true
	Cam.set_process_input(false)

func end():
	is_playing = false
	Cam.set_process_input(true)
