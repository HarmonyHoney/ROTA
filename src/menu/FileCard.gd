extends Control

export var slot := 0

onready var label := $Label

onready var new_game := $NewGame
onready var items := $Items

onready var gem_label := $Items/Gem/Label
onready var time_label := $Items/Time/Label

func _ready():
	set_card()

func set_card():
	
	var d = Shared.save_dict
	
	if d.has(slot) and d[slot].has("gem_count") and d[slot].has("time"):
		new_game.visible = false
		items.visible = true
		
		# gem
		gem_label.text = str(d[slot]["gem_count"])
		
		# time
		var t = int(d[slot]["time"])
		
		var s_hour = str(t / 3600)
		var s_min = str(t / 60).pad_zeros(2)
		var s_sec = str(t % 60).pad_zeros(2)
		
		time_label.text = s_hour + ":" + s_min + ":" + s_sec
	else:
		new_game.visible = true
		items.visible = false
