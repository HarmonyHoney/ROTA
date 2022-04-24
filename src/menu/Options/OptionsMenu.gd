extends MenuBase

onready var control := $Control
onready var item_window_size := $Control/Menu/List/Resolution

onready var open = EaseMover.new(control, 0.5, Vector2(0, 720), Vector2.ZERO)

func _ready():
	fill_items()

func _input(event):
	menu_input(event)

func _physics_process(delta):
	open.count(delta, is_open)
	control.modulate.a = lerp(0.0, 1.0, open.clock / open.time)
	control.visible = open.clock > 0
	
	menu_process(delta)

func fill_items():
	if item_window_size:
		item_window_size.visible = !OS.window_fullscreen
	.fill_items()

func show(arg := true):
	is_open = arg

	if is_open:
		self.cursor = 0
		fill_items()
	else:
		emit_signal("signal_close")

func accept():
	if items[cursor].has_method("act"):
		items[cursor].act()

func back():
	get_tree().set_input_as_handled()
	show(false)

func joy_x(arg := 1):
	if items[cursor].has_method("axis_x"):
		items[cursor].axis_x(arg)

func open_remap(is_gamepad := false):
	RemapMenu.is_gamepad = is_gamepad
	sub_menu(RemapMenu)
