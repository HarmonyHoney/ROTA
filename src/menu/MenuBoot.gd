extends MenuBase

export var sub_path : NodePath
onready var main_menu = get_node_or_null(sub_path)

func _ready():
	UI.keys.show = true
	Cam.target_node = null
	Cam.snap_to(main_menu.pos, 0)
	Shared.save_slot = -1
	Shared.player.is_input = false
	randomize()
	MenuMakeover.preset()
	
	if !Music.playing:
		randomize()
		Music.play_song()

func _exit_tree():
	UI.keys.show = false
	Cam.target_node = Shared.player
	Shared.player.is_input = true

func accept():
	sub_menu(main_menu)
