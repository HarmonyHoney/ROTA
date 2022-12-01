extends Node

var is_playing := false

onready var goal_show := $GoalShow
var is_show_goal := false

onready var gem_collect := $GemCollect
var is_collect := false
var is_clock := false

onready var start_game := $StartGame
var is_start_game := false

func _enter_tree():
	Shared.connect("scene_changed", self, "scene_changed")

func start():
	is_playing = true
	Cam.set_process_input(false)
	Shared.map_clock = 0.0

func end():
	is_playing = false
	Cam.set_process_input(true)

func end_all():
	for i in [gem_collect, goal_show, start_game]:
		if i.is_playing:
			i.end()

func scene_changed():
	if is_show_goal:
		is_show_goal = false
		if is_instance_valid(Shared.goal):
			Cutscene.goal_show.begin()
	
	elif is_collect or Cutscene.is_clock:
		Cutscene.is_collect = false
		Cutscene.is_clock = false
		if is_instance_valid(Shared.door_in):
			Cutscene.gem_collect.begin()
	
	elif is_start_game:
		Cutscene.is_start_game = false
		Cutscene.start_game.begin()
