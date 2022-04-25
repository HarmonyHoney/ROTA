extends MenuBase

onready var file_menu := $Canvas/FileMenu

func _ready():
	UI.menu.show = true

func _input(event):
	menu_input(event)

func _physics_process(delta):
	menu_process(delta)

func accept():
	match items[cursor].name.to_lower():
		"play":
			sub_menu(file_menu)
			#play()
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
	
