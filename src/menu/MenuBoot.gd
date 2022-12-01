extends MenuBase

export var sub_path : NodePath
onready var main_menu = get_node_or_null(sub_path)

func _ready():
	UI.keys.show = true
	
	Cam.rotation = 0
	Cam.target_pos = main_menu.pos
	Cam.position = Cam.target_pos
	
	Shared.save_slot = -1
	
	if !Music.playing:
		randomize()
		Music.play_song()

func _exit_tree():
	UI.keys.show = false

func accept():
	sub_menu(main_menu)
