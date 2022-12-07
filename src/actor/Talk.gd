extends Node2D

onready var arrow := $Arrow

onready var audio := $Audio

var queue := []
export(Array, AudioStream) var clips := []
export(Array, String, MULTILINE) var text := []

export(Array, String) var menu := []

var player
var is_talking := false
var leash_range := 300.0

onready var door := get_parent().get_node_or_null("Door")

func _enter_tree():
	UI.connect("dialog_accept", self, "accept")
	UI.connect("dialog_closed", self, "close")

func _physics_process(delta):
	if is_talking and is_instance_valid(player) and global_position.distance_to(player.global_position) > leash_range:
		is_talking = false
		close()

func _on_Arrow_open():
	arrow.is_locked = true
	player = Shared.player
	is_talking = true
	pick_line()

func close():
	is_talking = false
	arrow.is_locked = false
	say_line(0)

func accept():
	match menu[UI.dialog_menu.cursor]:
		"Talk":
			pick_line()
			is_talking = true
		"Shop":
			say_line(0)
			is_talking = true
		"Makeover":
			door.visible = true
			door.arrow.is_locked = false

func say_line(arg := 0):
	audio.stream = clips[arg]
	audio.play()
	
	UI.caption_label.text = text[arg]
	UI.caption.show = true
	if UI.dialog_menu.is_open:
		UI.dialog_menu.is_open = false
	
	yield(audio, "finished")
	UI.caption.show = false
	
	if is_talking and menu.size() > 0:
		UI.dialog_menu.is_open = true
		UI.dialog_menu.write(menu)

func pick_line():
	if queue.size() == 0:
		queue = range(clips.size())
		randomize()
		queue.shuffle()
	
	say_line(queue.pop_back())

