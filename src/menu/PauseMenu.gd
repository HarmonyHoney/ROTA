extends MenuBase

onready var hub_label := $Control/Menu/List/Items/Hub
onready var audio_open := $Audio/Open

func _ready():
	Wipe.connect("start_wipe_out", self, "start_wipe_out")
	Wipe.connect("wipe_out", self, "wipe_out")
	Wipe.connect("wipe_in", self, "wipe_in")

func _input(event):
	if is_open:
		menu_input(event)
	elif event.is_action_pressed("ui_pause") and !is_sub_menu and Shared.csfn != Shared.title_path:
		self.is_open = true

func _physics_process(delta):
	menu_process(delta)

func accept():
	match items[cursor].name.to_lower():
		"resume":
			back()
		"reset":
			Shared.reset()
		"hub":
			back_to_hub()
		"options":
			sub_menu(OptionsMenu)
		"exit":
			Shared.wipe_scene(Shared.title_path)

func back():
	self.is_open = false
	get_tree().set_input_as_handled()

func start_wipe_out():
	set_process_input(false)

func wipe_out():
	# close menu
	if is_open:
		self.is_open = false
		fade_ease.clock = 0

func wipe_in():
	set_process_input(true)

func set_open(arg := is_open):
	.set_open(arg)
	
	get_tree().paused = is_open
	
	# setup items
	if is_open:
		hub_label.visible = !("hub" in Shared.csfn) and "hub" in Shared.last_scene
		
		items = []
		for i in items_node.get_children():
			if i.visible:
				items.append(i)
	
	audio_open.pitch_scale = 1.0 if is_open else 0.75
	audio_open.play()
	
	UI.menu.show = is_open

func back_to_hub():
	if !("hub" in Shared.csfn) and "hub" in Shared.last_scene:
		Shared.wipe_scene(Shared.last_scene)

