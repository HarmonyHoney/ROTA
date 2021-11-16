extends CanvasLayer

var cursor := 0
onready var cursor_node = $Parent/Items/Cursor
onready var items_node = $Parent/Items
onready var items = []
onready var parent = $Parent

var is_paused := false

func _ready():
	parent.visible = false
	
	items = items_node.get_children()
	items.remove(0)
	
	#Wipe.connect("wipe_in", self, "wipe_in")
	Wipe.connect("wipe_out", self, "wipe_out")
	#Wipe.connect("start_wipe_in", self, "start_wipe_in")
	Wipe.connect("start_wipe_out", self, "start_wipe_out")

func wipe_out():
	if is_paused:
		set_paused(false)
	yield(get_tree().create_timer(0.7), "timeout")
	set_process_input(true)

func start_wipe_out():
	set_process_input(false)

func _input(event):
	var pause = event.is_action_pressed("pause")
	if pause:
		set_paused(!is_paused)
	if !is_paused: return
	
	var up = event.is_action_pressed("up")
	var down = event.is_action_pressed("down")
	#var left = event.is_action_pressed("left")
	#var right = event.is_action_pressed("right")
	var enter = event.is_action_pressed("jump")
	var back = event.is_action_pressed("action")
	
	if up or down:
		cursor = clamp(cursor + (-1 if up else 1), 0, items.size() - 1)
	
	if back:
		set_paused(false)
	elif enter:
		match cursor:
			0:
				set_paused(false)
			1:
				Shared.reset()
			2:
				Shared.change_scene(Shared.scene_world_select)

func _process(delta):
	var anch = ["left", "top", "right", "bottom"]
	for i in anch:
		var s = "anchor_" + i
		cursor_node.set(s, lerp(cursor_node.get(s), items[cursor].get(s), 0.15))

func set_paused(pause := true):
	is_paused = pause
	parent.visible = is_paused
	if !is_paused:
		yield(get_tree(), "idle_frame")
	get_tree().paused = is_paused
	cursor = 0

