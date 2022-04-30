extends Node

var is_playing := false

onready var goal_show := $GoalShow
var is_show_goal := false

onready var gem_collect := $GemCollect
var is_collect := false

onready var start_game := $StartGame
var is_start_game := false


func start():
	is_playing = true
	Cam.set_process_input(false)

func end():
	is_playing = false
	Cam.set_process_input(true)

func end_all():
	for i in [gem_collect, goal_show, start_game]:
		if i.is_playing:
			i.end()
