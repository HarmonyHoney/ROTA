extends MenuBase

onready var control := $Control

onready var hub_label := $Control/Menu/List/Items/Hub
onready var audio_open := $Audio/Open

var open = EaseMover.new()

func _ready():
	open.node = $Control
	open.from = Vector2(0, 720)
	open.to = Vector2.ZERO
	open.time = 0.25
	
	Wipe.connect("start_wipe_out", self, "start_wipe_out")
	Wipe.connect("wipe_out", self, "wipe_out")
	Wipe.connect("wipe_in", self, "wipe_in")

func _input(event):
	if is_open:
		menu_input(event)
	elif event.is_action_pressed("ui_pause") and !OptionsMenu.is_open and !RemapMenu.is_open and Shared.csfn != Shared.title_path:
		set_paused(true)

func _physics_process(delta):
	open.count(delta, is_open)
	control.modulate.a = lerp(0.0, 1.0, open.clock / open.time)
	
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
			get_tree().quit()

func back():
	set_paused(false)
	get_tree().set_input_as_handled()

func start_wipe_out():
	set_process_input(false)

func wipe_out():
	# close menu
	if is_open:
		set_paused(false)
		open.clock = 0

func wipe_in():
	set_process_input(true)

func set_paused(pause := true):
	is_open = pause
	self.cursor = 0
	
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

