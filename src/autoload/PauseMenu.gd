extends CanvasLayer

onready var control := $Control
onready var menu = $Control/Menu
onready var cursor_node = $Control/Menu/List/Cursor
onready var items_node = $Control/Menu/List/Items

var is_paused := false
var cursor := 0 setget set_cursor
var cursor_margin := Vector2(30, 0)

var items = []
var labels = []

var open = EaseMover.new()

var highlight_color := Color("bf6061")
#onready var bg := $BG

func _ready():
	open.node = $Control
	open.from = Vector2(0, 720)
	open.to = Vector2.ZERO
	open.time = 0.25
	
	#open.node.visible = false
	#menu.visible = false
	
	items = items_node.get_children()
	for i in items:
		labels.append(i.get_node("Label"))
	
	Wipe.connect("wipe_out", self, "wipe_out")
	Wipe.connect("start_wipe_out", self, "start_wipe_out")
	
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
		match cursor:
			0:
				press_pause()
			1:
				Shared.reset()
			2:
				options()
			3:
				get_tree().quit()

func _physics_process(delta):
	#open.move(delta, is_paused)
	open.count(delta, is_paused)
	control.modulate.a = lerp(0.0, 1.0, open.clock / open.time)
	#bg.modulate.a = lerp(0.0, 0.3, open.clock / open.time)
	
	
	if !is_paused: return
	cursor_node.rect_global_position = cursor_node.rect_global_position.linear_interpolate(labels[cursor].rect_global_position - cursor_margin, 0.15)
	cursor_node.rect_size = cursor_node.rect_size.linear_interpolate(labels[cursor].rect_size + (cursor_margin * 2.0), 0.15)

func wipe_out():
	if is_paused:
		set_paused(false)
		open.clock = 0
	yield(get_tree().create_timer(0.7), "timeout")
	set_process_input(true)

func start_wipe_out():
	set_process_input(false)

func set_paused(pause := true):
	is_paused = pause
	cursor = 0
	
	#menu.visible = is_paused
	UI.gem.show = is_paused
	UI.top.show = !is_paused
	
	get_tree().paused = is_paused
	
	UI.menu.show = is_paused

func press_pause():
	set_paused(!is_paused)

func options():
	OptionsMenu.show(true)
	is_paused = false

func set_cursor(arg := 0):
	cursor = clamp(arg, 0, items.size() - 1)
	
	for i in labels:
		i.modulate = Color.white
	
	#labels[cursor].modulate = highlight_color

