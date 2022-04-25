extends MenuBase

func _ready():
	UI.menu.show = true

func _input(event):
	menu_input(event)

func _physics_process(delta):
	menu_process(delta)

func accept():
	match items[cursor].name.to_lower():
		"play":
			play()
		"options":
			sub_menu(OptionsMenu)
		"exit":
			get_tree().quit()


func play():
	UI.menu.show = false
	Shared.load_data()
	
	if !"worlds" in Shared.next_scene:
		Shared.next_scene = Shared.start_path
		Shared.last_scene = Shared.start_path
		Cutscene.is_start_game = true
	
	Shared.wipe_scene(Shared.next_scene, Shared.last_scene)
	
