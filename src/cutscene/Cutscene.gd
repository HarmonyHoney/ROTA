extends Node

var is_playing := false setget set_is_playing
signal playing

onready var goal_show := $GoalShow
var is_show_goal := false

onready var gem_collect := $GemCollect
var is_collect := false

onready var clock := $Clock
var is_clock := false

onready var start_game := $StartGame
var is_start_game := false

onready var door_unlock := $DoorUnlock
var is_door_unlock := false

func _enter_tree():
	Shared.connect("scene_changed", self, "scene_changed")

func scene_changed():
	if is_playing: return
	
	if is_show_goal:
		is_show_goal = false
		goal_show.act()
		
	elif is_collect:
		is_collect = false
		gem_collect.act()
		
	elif is_clock:
		is_clock = false
		clock.act()
		
	elif is_start_game:
		is_start_game = false
		start_game.act()

func set_is_playing(arg := is_playing):
	is_playing = arg
	emit_signal("playing", is_playing)
