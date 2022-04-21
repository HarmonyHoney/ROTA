extends CanvasLayer

onready var control := $Control
onready var menu = $Control/Menu
onready var cursor_node = $Control/Menu/List/Cursor
onready var items_node = $Control/Menu/List/Items

onready var hub_label := $Control/Menu/List/Items/Hub
onready var audio_open := $Audio/Open

var is_paused := false
var cursor := 0 setget set_cursor
var cursor_margin := Vector2(30, 0)

var items = []

var open = EaseMover.new()

var highlight_color := Color("bf6061")
#onready var bg := $BG

func _ready():
	open.node = $Control
	open.from = Vector2(0, 720)
	open.to = Vector2.ZERO
	open.time = 0.25
	
	items = items_node.get_children()
	
	Wipe.connect("start_wipe_out", self, "start_wipe_out")
	Wipe.connect("wipe_out", self, "wipe_out")
	Wipe.connect("wipe_in", self, "wipe_in")
	
	self.cursor = 0

func _input(event):
	var pause = event.is_action_pressed("ui_pause")
	if pause:
		press_pause()
		return
	if !is_paused: return
	
	var up = event.is_action_pressed("ui_up")
	var down = event.is_action_pressed("ui_down")
	#var left = event.is_action_pressed("left")
	#var right = event.is_action_pressed("right")
	var enter = event.is_action_pressed("ui_accept")
	var back = event.is_action_pressed("ui_cancel")
	
	if up or down:
		self.cursor += -1 if up else 1
	
	if back:
		press_pause()
		get_tree().set_input_as_handled()
	elif enter:
		match items[cursor].name.to_lower():
			"resume":
				press_pause()
			"reset":
				Shared.reset()
			"hub":
				back_to_hub()
			"options":
				options()
			"exit":
				get_tree().quit()

func _physics_process(delta):
	open.count(delta, is_paused)
	control.modulate.a = lerp(0.0, 1.0, open.clock / open.time)
	
	if !is_paused: return
	cursor_node.rect_global_position = cursor_node.rect_global_position.linear_interpolate(items[cursor].rect_global_position - cursor_margin, 0.15)
	cursor_node.rect_size = cursor_node.rect_size.linear_interpolate(items[cursor].rect_size + (cursor_margin * 2.0), 0.15)

func set_cursor(arg := 0):
	cursor = clamp(arg, 0, items.size() - 1)

func start_wipe_out():
	set_process_input(false)

func wipe_out():
	# close menu
	if is_paused:
		set_paused(false)
		open.clock = 0

func wipe_in():
	set_process_input(true)

func set_paused(pause := true):
	is_paused = pause
	self.cursor = 0
	
	get_tree().paused = is_paused
	
	# setup items
	if is_paused:
		hub_label.visible = !("hub" in Shared.csfn) and "hub" in Shared.last_scene
		
		items = []
		for i in items_node.get_children():
			if i.visible:
				items.append(i)
	
	audio_open.pitch_scale = 1.0 if is_paused else 0.75
	audio_open.play()
	
	UI.menu.show = is_paused

func press_pause():
	set_paused(!is_paused)

func options():
	OptionsMenu.show(true)
	is_paused = false

func back_to_hub():
	if !("hub" in Shared.csfn) and "hub" in Shared.last_scene:
		Shared.wipe_scene(Shared.last_scene)

