extends CanvasLayer

onready var menu = $Control/Menu
onready var cursor_node = $Control/Menu/List/Cursor
onready var items_node = $Control/Menu/List/Items

var is_paused := false
var cursor := 0
var items = []
var labels = []

func _ready():
	menu.visible = false
	
	items = items_node.get_children()
	for i in items:
		labels.append(i.get_node("Label"))
	
	Wipe.connect("wipe_out", self, "wipe_out")
	Wipe.connect("start_wipe_out", self, "start_wipe_out")

func _input(event):
	var pause = event.is_action_pressed("pause")
	if pause:
		press_pause()
		return
	if !is_paused: return
	
	var up = event.is_action_pressed("up")
	var down = event.is_action_pressed("down")
	#var left = event.is_action_pressed("left")
	#var right = event.is_action_pressed("right")
	var enter = event.is_action_pressed("jump")
	var back = event.is_action_pressed("grab")
	
	if up or down:
		cursor = clamp(cursor + (-1 if up else 1), 0, items.size() - 1)
	
	if back:
		press_pause()
	elif enter:
		match cursor:
			0:
				press_pause()
			1:
				options()
			2:
				pass#exit()

func _physics_process(delta):
	cursor_node.rect_global_position = cursor_node.rect_global_position.linear_interpolate(labels[cursor].rect_global_position - Vector2(10, 0), 0.15)
	cursor_node.rect_size = cursor_node.rect_size.linear_interpolate(labels[cursor].rect_size + Vector2(20, 0), 0.15)

func wipe_out():
	if is_paused:
		set_paused(false)
	yield(get_tree().create_timer(0.7), "timeout")
	set_process_input(true)

func start_wipe_out():
	set_process_input(false)

func set_paused(pause := true):
	is_paused = pause
	cursor = 0
	
	menu.visible = is_paused
	UI.gem.show = is_paused
	UI.top.show = !is_paused
	
	get_tree().paused = is_paused

func press_pause():
	set_paused(!is_paused)


func options():
	OptionsMenu.show(true)
	is_paused = false

