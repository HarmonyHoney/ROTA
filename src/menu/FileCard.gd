extends Control

export var slot := 0

onready var new_game := $NewGame
onready var items := $Items

onready var gem_label := $Items/Goals/Gems/Label
onready var clocks := $Items/Goals/Clocks
onready var clock_label := $Items/Goals/Clocks/Label
onready var time_label := $Items/Time/Label

var is_new := true

func _ready():
	set_card()
	
	Shared.connect("signal_erase_slot", self, "erase_slot")

func set_card():
	var d = Shared.save_dict
	
	if d.has(slot) and d[slot].has("goals") and d[slot].has("time"):
		is_new = false
		
		gem_label.text = str(d[slot]["goals"].size())
		clock_label.text = str(Shared.collect_clocks(d[slot]["goals"]))
		clocks.visible = clock_label.text != "0"
		
		# time
		time_label.text = Shared.time_string(d[slot]["time"], false, true)
	else:
		is_new = true
	
	new_game.visible = is_new
	items.visible = !is_new

func erase_slot(arg):
	set_card()
