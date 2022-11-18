extends Control

export var slot := 0

onready var new_game := $NewGame
onready var items := $Items

onready var gem_label := $Items/Gem/Label
onready var time_label := $Items/Time/Label

var is_new := true

func _ready():
	set_card()
	
	Shared.connect("signal_erase_slot", self, "erase_slot")

func set_card():
	var d = Shared.save_dict
	
	if d.has(slot) and (d[slot].has("goals") or d[slot].has("gem_count")) and d[slot].has("time"):
		is_new = false
		
		# gem
		gem_label.text = str(d[slot]["goals"].size() if d[slot].has("goals") else d[slot]["gem_count"])
		
		# time
		var t = int(d[slot]["time"])
		
		var s_hour = str(t / 3600)
		var s_min = str((t / 60) % 60).pad_zeros(2)
		var s_sec = str(t % 60).pad_zeros(2)
		
		time_label.text = s_hour + ":" + s_min + ":" + s_sec
	else:
		is_new = true
	
	new_game.visible = is_new
	items.visible = !is_new

func erase_slot(arg):
	set_card()
