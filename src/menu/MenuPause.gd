extends MenuBase

onready var hub_label := $Control/Menu/List/Items/Hub

func _ready():
	Wipe.connect("start_wipe_out", self, "start_wipe_out")
	Wipe.connect("wipe_out", self, "wipe_out")
	Wipe.connect("wipe_in", self, "wipe_in")

func _input(event):
	if is_open:
		if event.is_action_pressed("ui_pause") and !is_sub_menu and (fade_ease.frac() > 0.5):
			self.is_open = false
		else:
			menu_input(event)
	elif event.is_action_pressed("ui_pause") and !is_sub_menu and "world" in Shared.csfn and !Cutscene.is_playing and !UI.dialog_menu.is_open:
		self.is_open = true

func accept():
	joy = Vector2.ZERO
	match items[cursor].name.to_lower():
		"resume":
			self.is_open = false
		"reset":
			Shared.reset()
		"hub":
			back_to_hub()
		"options":
			sub_menu(MenuOptions)
		"store":
			Shared.store_page()
		"exit":
			Shared.wipe_scene(Shared.title_path)

func start_wipe_out():
	set_process_input(false)

func wipe_out():
	# close menu
	if is_open:
		set_open(false, false)
		fade_ease.clock = 0

func wipe_in():
	set_process_input(true)

func set_open(arg := is_open, is_audio := true):
	.set_open(arg)
	
	get_tree().paused = is_open
	
	# setup items
	if is_open:
		hub_label.visible = !("hub" in Shared.csfn or "start" in Shared.csfn) and "hub" in Shared.last_scene
		
		items = []
		for i in items_node.get_children():
			if i.visible:
				items.append(i)
	
	if is_audio:
		Audio.play(Audio.menu_pause, 1.0 if is_open else 0.75)
	
	UI.keys.show = is_open

func back_to_hub():
	if !("hub" in Shared.csfn) and "hub" in Shared.last_scene:
		Shared.wipe_scene(Shared.last_scene)

