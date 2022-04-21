extends Node

onready var audio_coin := $Audio/Coin
onready var audio_collect := $Audio/Collect

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

func end_all():
	for i in [gem_collect, goal_show]:
		if i.is_playing:
			i.end()
