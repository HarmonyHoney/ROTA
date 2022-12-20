extends MenuBase

onready var hub_label := $Control/Menu/List/Items/Hub

func _ready():
	Wipe.connect("complete", self, "wipe_complete")

func _input(event):
	if Wipe.is_wipe: return
	
	if is_open:
		if event.is_action_pressed("ui_pause") and !is_sub_menu and (fade_ease.frac() > 0.5):
			self.is_open = false
		else:
			menu_input(event)
	elif event.is_action_pressed("ui_pause") and !is_sub_menu and "world" in Shared.csfn and !Cutscene.is_playing and !UI.dialog_menu.is_open and !MenuMakeover.is_open:
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

func wipe_complete(arg):
	if is_open:
		# close menu
		set_open(false, false)
		fade_ease.clock = 0

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
		Audio.play("menu_pause", 1.0 if is_open else 0.75)

func back_to_hub():
	if !("hub" in Shared.csfn) and "hub" in Shared.last_scene:
		Shared.wipe_scene(Shared.last_scene)

